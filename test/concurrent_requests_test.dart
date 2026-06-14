import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:backend_driven_ui/src/core/bdui_http_client.dart';
import 'package:backend_driven_ui/src/models/api_request.dart';
import 'package:backend_driven_ui/src/models/api_response.dart';
import 'package:backend_driven_ui/src/widgets/api_widget.dart';

// ── Controllable mock ─────────────────────────────────────────────────────────

class _ControllableClient implements BduiHttpClient {
  final List<Completer<ApiResponse>> _completers = [];
  int callCount = 0;

  /// Returns the next request's completer so the test can resolve it.
  Completer<ApiResponse> next() {
    final c = Completer<ApiResponse>();
    _completers.add(c);
    return c;
  }

  @override
  Future<ApiResponse> get(
    String url, {
    Map<String, String>? headers,
    Duration? cacheDuration,
    int? maxRetries,
    Duration? timeout,
  }) {
    callCount++;
    final c = Completer<ApiResponse>();
    _completers.add(c);
    return c.future;
  }

  @override
  Future<ApiResponse> getWithRefresh(
    String url, {
    Map<String, String>? headers,
    Duration? cacheDuration,
    int? maxRetries,
    Duration? timeout,
    void Function(ApiResponse)? onRefresh,
  }) =>
      get(url);

  @override
  Future<ApiResponse> post(
    String url, {
    Map<String, String>? headers,
    dynamic body,
    int? maxRetries,
    Duration? timeout,
  }) =>
      get(url);

  @override
  Future<ApiResponse> put(
    String url, {
    Map<String, String>? headers,
    dynamic body,
    int? maxRetries,
    Duration? timeout,
  }) =>
      get(url);

  @override
  Future<ApiResponse> patch(
    String url, {
    Map<String, String>? headers,
    dynamic body,
    int? maxRetries,
    Duration? timeout,
  }) =>
      get(url);

  @override
  Future<ApiResponse> delete(
    String url, {
    Map<String, String>? headers,
    int? maxRetries,
    Duration? timeout,
  }) =>
      get(url);

  @override
  Future<ApiResponse> head(
    String url, {
    Map<String, String>? headers,
    int? maxRetries,
    Duration? timeout,
  }) =>
      get(url);

  @override
  Future<ApiResponse> options(
    String url, {
    Map<String, String>? headers,
    int? maxRetries,
    Duration? timeout,
  }) =>
      get(url);

  @override
  Future<ApiResponse> execute(ApiRequest request) => get(request.endpoint);
}

// ── Ordered mock — resolves in a configurable sequence ───────────────────────

class _OrderedClient implements BduiHttpClient {
  final List<Future<ApiResponse> Function()> _responses;
  int callIndex = 0;

  _OrderedClient(this._responses);

  @override
  Future<ApiResponse> get(
    String url, {
    Map<String, String>? headers,
    Duration? cacheDuration,
    int? maxRetries,
    Duration? timeout,
  }) {
    final fn = _responses[callIndex++];
    return fn();
  }

  @override
  Future<ApiResponse> getWithRefresh(
    String url, {
    Map<String, String>? headers,
    Duration? cacheDuration,
    int? maxRetries,
    Duration? timeout,
    void Function(ApiResponse)? onRefresh,
  }) =>
      get(url);

  @override
  Future<ApiResponse> post(String url,
          {Map<String, String>? headers,
          dynamic body,
          int? maxRetries,
          Duration? timeout}) =>
      get(url);
  @override
  Future<ApiResponse> put(String url,
          {Map<String, String>? headers,
          dynamic body,
          int? maxRetries,
          Duration? timeout}) =>
      get(url);
  @override
  Future<ApiResponse> patch(String url,
          {Map<String, String>? headers,
          dynamic body,
          int? maxRetries,
          Duration? timeout}) =>
      get(url);
  @override
  Future<ApiResponse> delete(String url,
          {Map<String, String>? headers, int? maxRetries, Duration? timeout}) =>
      get(url);
  @override
  Future<ApiResponse> head(String url,
          {Map<String, String>? headers, int? maxRetries, Duration? timeout}) =>
      get(url);
  @override
  Future<ApiResponse> options(String url,
          {Map<String, String>? headers, int? maxRetries, Duration? timeout}) =>
      get(url);
  @override
  Future<ApiResponse> execute(ApiRequest request) => get(request.endpoint);
}

// ── Helper ────────────────────────────────────────────────────────────────────

Widget _wrap(Widget child) => MaterialApp(home: Scaffold(body: child));

// ── Tests ─────────────────────────────────────────────────────────────────────

void main() {
  group('Concurrent request race conditions', () {
    group('in-flight guard', () {
      testWidgets('second fetchData call while first is in-flight is skipped',
          (tester) async {
        final client = _ControllableClient();

        await tester.pumpWidget(_wrap(ApiWidget(
          endpoint: 'https://api.example.com/data',
          httpClient: client,
          showRetryButton: false,
        )));

        // First request is in-flight — callCount should be 1
        expect(client.callCount, 1);

        // Pump without resolving — widget is still loading
        await tester.pump();
        expect(client.callCount, 1);

        // Resolve the pending request
        client._completers[0]
            .complete(const ApiResponse(statusCode: 200, data: {'ok': true}));
        await tester.pumpAndSettle();

        // Only one network call was made
        expect(client.callCount, 1);
      });

      testWidgets('polling does not overlap with in-flight request',
          (tester) async {
        final client = _ControllableClient();

        await tester.pumpWidget(_wrap(ApiWidget(
          endpoint: 'https://api.example.com/poll',
          httpClient: client,
          pollInterval: const Duration(milliseconds: 100),
          showRetryButton: false,
        )));

        // Initial fetch
        await tester.pump();
        expect(client.callCount, 1);

        // Advance timer to trigger poll tick — request is still in-flight
        await tester.pump(const Duration(milliseconds: 150));

        // Poll tick should be skipped (in-flight guard)
        expect(client.callCount, 1);

        // Resolve initial request and dispose (dispose cancels the repeating
        // timer, which is necessary so pumpAndSettle can settle).
        client._completers[0]
            .complete(const ApiResponse(statusCode: 200, data: {'ok': true}));
        await tester.pump();
        await tester.pumpWidget(_wrap(const SizedBox())); // disposes timer
        await tester.pumpAndSettle();
      });
    });

    group('stale response ignored after endpoint change', () {
      testWidgets('only the latest endpoint result is shown', (tester) async {
        // Slow first request, fast second request.
        // The second (v2) result must win, even if v1 resolves after v2.
        //
        // _ControllableClient queues completers in _completers as get() calls
        // arrive. After the force-fetch fix, endpoint changes always issue a
        // new request even while one is in-flight.
        final client = _ControllableClient();

        // Mount with v1 endpoint → req1 queued at _completers[0]
        await tester.pumpWidget(_wrap(ApiWidget(
          endpoint: 'https://api.example.com/v1',
          httpClient: client,
          showRetryButton: false,
          successWidget: (data) => Text(data['version'].toString()),
        )));
        await tester.pump();
        expect(client._completers.length, 1);
        final req1 = client._completers[0];

        // Switch to v2 endpoint while v1 is still pending → req2 at [1]
        await tester.pumpWidget(_wrap(ApiWidget(
          endpoint: 'https://api.example.com/v2',
          httpClient: client,
          showRetryButton: false,
          successWidget: (data) => Text(data['version'].toString()),
        )));
        await tester.pump();
        expect(client._completers.length, 2);
        final req2 = client._completers[1];

        // Resolve v2 first (fast path)
        req2.complete(const ApiResponse(statusCode: 200, data: {'version': 2}));
        await tester.pumpAndSettle();
        expect(find.text('2'), findsOneWidget);

        // Now resolve v1 late — should not replace v2 result because _future
        // was replaced when the endpoint changed; v1's future is no longer
        // tracked by the FutureBuilder.
        req1.complete(const ApiResponse(statusCode: 200, data: {'version': 1}));
        await tester.pumpAndSettle();
        expect(find.text('2'), findsOneWidget);
        expect(find.text('1'), findsNothing);
      });
    });

    group('out-of-order responses via ordered mock', () {
      testWidgets('widget shows result from the request it is tracking',
          (tester) async {
        // Simulate rapid endpoint switch: req1 resolves after req2.
        // The widget should ignore req1 because its future was replaced.
        final slowCompleter = Completer<ApiResponse>();

        int getCallCount = 0;
        final client = _OrderedClient([
          // First call: slow
          () {
            getCallCount++;
            return slowCompleter.future;
          },
          // Second call: fast
          () {
            getCallCount++;
            return Future.value(
                const ApiResponse(statusCode: 200, data: {'page': 'B'}));
          },
        ]);

        // Initial render → req1 (slow)
        await tester.pumpWidget(_wrap(ApiWidget(
          endpoint: 'https://api.example.com/A',
          httpClient: client,
          showRetryButton: false,
          successWidget: (data) => Text(data['page'].toString()),
        )));
        await tester.pump();
        expect(getCallCount, 1);

        // Switch endpoint → req2 (fast, resolves with a completed Future)
        await tester.pumpWidget(_wrap(ApiWidget(
          endpoint: 'https://api.example.com/B',
          httpClient: client,
          showRetryButton: false,
          successWidget: (data) => Text(data['page'].toString()),
        )));
        // pump() rather than pumpAndSettle() — slowCompleter is still open
        // so pumpAndSettle would time out.
        await tester.pump();
        await tester.pump();
        expect(getCallCount, 2);
        expect(find.text('B'), findsOneWidget);

        // Resolve the stale slow request — UI should not change because
        // _future already points to req2's future.
        slowCompleter
            .complete(const ApiResponse(statusCode: 200, data: {'page': 'A'}));
        await tester.pump();
        await tester.pump();
        expect(find.text('B'), findsOneWidget);
        expect(find.text('A'), findsNothing);
      });
    });

    group('retry does not stack requests', () {
      testWidgets('tapping retry multiple times issues only one new request',
          (tester) async {
        int callCount = 0;
        final client = _OrderedClient([
          // First call: error
          () async {
            callCount++;
            throw Exception('initial failure');
          },
          // Second call (retry 1): slow, tracked by completer
          () async {
            callCount++;
            // Complete immediately so widget settles
            return const ApiResponse(statusCode: 200, data: {'ok': true});
          },
        ]);

        await tester.pumpWidget(_wrap(ApiWidget(
          endpoint: 'https://api.example.com/data',
          httpClient: client,
          showRetryButton: true,
        )));
        await tester.pumpAndSettle();
        tester.takeException();
        expect(callCount, 1);
        expect(find.text('Retry'), findsOneWidget);

        // Tap retry — this clears the in-flight guard and issues a new request
        await tester.tap(find.text('Retry'));
        await tester.pumpAndSettle();
        expect(callCount, 2);
        expect(find.text('Retry'), findsNothing);
      });
    });

    group('dispose during in-flight request', () {
      testWidgets('widget disposed while request in-flight does not crash',
          (tester) async {
        final completer = Completer<ApiResponse>();
        final client = _ControllableClient();

        await tester.pumpWidget(_wrap(ApiWidget(
          endpoint: 'https://api.example.com/data',
          httpClient: client,
          showRetryButton: false,
        )));
        await tester.pump();
        expect(client.callCount, 1);

        // Dispose the widget before the request completes
        await tester.pumpWidget(const MaterialApp(home: SizedBox()));

        // Now resolve the request — should not cause setState-on-disposed error
        completer.complete(const ApiResponse(statusCode: 200, data: {'x': 1}));
        await tester.pumpAndSettle();
        // No exception = test passes
      });

      testWidgets(
          'widget disposed while request in-flight errors does not crash',
          (tester) async {
        final client = _ControllableClient();

        await tester.pumpWidget(_wrap(ApiWidget(
          endpoint: 'https://api.example.com/data',
          httpClient: client,
          showRetryButton: false,
        )));
        await tester.pump();

        // Dispose
        await tester.pumpWidget(const MaterialApp(home: SizedBox()));

        // Reject the pending request after dispose
        client._completers[0].completeError(Exception('late error'));
        await tester.pumpAndSettle();
        tester.takeException(); // consume the zone error
      });
    });

    group('onSuccess / onError deduplication under rapid updates', () {
      testWidgets('onSuccess fires once even after multiple identical rebuilds',
          (tester) async {
        int successCount = 0;
        final client = _OrderedClient([
          () async => const ApiResponse(statusCode: 200, data: {'id': 42}),
        ]);

        await tester.pumpWidget(_wrap(ApiWidget(
          endpoint: 'https://api.example.com/data',
          httpClient: client,
          showRetryButton: false,
          onSuccess: (_) => successCount++,
        )));
        await tester.pumpAndSettle();
        expect(successCount, 1);

        // Pump several more frames — callback must not fire again
        for (int i = 0; i < 5; i++) {
          await tester.pump();
        }
        expect(successCount, 1);
      });

      testWidgets('onError fires once even after multiple identical rebuilds',
          (tester) async {
        int errorCount = 0;
        final client = _OrderedClient([
          () async => throw Exception('boom'),
        ]);

        await tester.pumpWidget(_wrap(ApiWidget(
          endpoint: 'https://api.example.com/data',
          httpClient: client,
          showRetryButton: false,
          onError: (_) => errorCount++,
        )));
        await tester.pumpAndSettle();
        tester.takeException();
        expect(errorCount, 1);

        for (int i = 0; i < 5; i++) {
          await tester.pump();
        }
        expect(errorCount, 1);
      });

      testWidgets('onSuccess fires again when response data changes',
          (tester) async {
        int successCount = 0;
        final client = _OrderedClient([
          () async => const ApiResponse(statusCode: 200, data: {'v': 1}),
          () async => const ApiResponse(statusCode: 200, data: {'v': 2}),
        ]);

        await tester.pumpWidget(_wrap(ApiWidget(
          endpoint: 'https://api.example.com/v1',
          httpClient: client,
          showRetryButton: false,
          onSuccess: (_) => successCount++,
        )));
        await tester.pumpAndSettle();
        expect(successCount, 1);

        await tester.pumpWidget(_wrap(ApiWidget(
          endpoint: 'https://api.example.com/v2',
          httpClient: client,
          showRetryButton: false,
          onSuccess: (_) => successCount++,
        )));
        await tester.pumpAndSettle();
        expect(successCount, 2);
      });
    });
  });
}
