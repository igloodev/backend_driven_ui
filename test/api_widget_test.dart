import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:backend_driven_ui/src/core/bdui_http_client.dart';
import 'package:backend_driven_ui/src/models/api_request.dart';
import 'package:backend_driven_ui/src/models/api_response.dart';
import 'package:backend_driven_ui/src/widgets/api_widget.dart';

// ── Mock ─────────────────────────────────────────────────────────────────────

class _MockHttpClient implements BduiHttpClient {
  final Future<ApiResponse> Function(String url) _handler;
  int callCount = 0;
  String? lastUrl;

  _MockHttpClient(this._handler);

  @override
  Future<ApiResponse> get(String url, {
    Map<String, String>? headers,
    Duration? cacheDuration,
    int? maxRetries,
    Duration? timeout,
  }) {
    callCount++;
    lastUrl = url;
    return _handler(url);
  }

  @override
  Future<ApiResponse> getWithRefresh(String url, {
    Map<String, String>? headers,
    Duration? cacheDuration,
    int? maxRetries,
    Duration? timeout,
    void Function(ApiResponse)? onRefresh,
  }) => get(url);

  @override
  Future<ApiResponse> post(String url, {
    Map<String, String>? headers,
    dynamic body,
    int? maxRetries,
    Duration? timeout,
  }) {
    callCount++;
    lastUrl = url;
    return _handler(url);
  }

  @override
  Future<ApiResponse> put(String url, {
    Map<String, String>? headers,
    dynamic body,
    int? maxRetries,
    Duration? timeout,
  }) {
    callCount++;
    lastUrl = url;
    return _handler(url);
  }

  @override
  Future<ApiResponse> patch(String url, {
    Map<String, String>? headers,
    dynamic body,
    int? maxRetries,
    Duration? timeout,
  }) {
    callCount++;
    lastUrl = url;
    return _handler(url);
  }

  @override
  Future<ApiResponse> delete(String url, {
    Map<String, String>? headers,
    int? maxRetries,
    Duration? timeout,
  }) {
    callCount++;
    lastUrl = url;
    return _handler(url);
  }

  @override
  Future<ApiResponse> execute(ApiRequest request) => get(request.endpoint);
}

// ── Helper ────────────────────────────────────────────────────────────────────

Widget _wrap(Widget child) => MaterialApp(home: Scaffold(body: child));

// ── Tests ─────────────────────────────────────────────────────────────────────

void main() {
  group('ApiWidget', () {
    group('empty endpoint guard', () {
      testWidgets('shows error state when endpoint is empty and no request provided',
          (tester) async {
        final client = _MockHttpClient((_) async =>
            const ApiResponse(statusCode: 200, data: {'key': 'value'}));

        await tester.pumpWidget(_wrap(ApiWidget(
          endpoint: '',
          httpClient: client,
          showRetryButton: false,
        )));

        await tester.pumpAndSettle();
        tester.takeException(); // consume zone-reported error (expected)

        expect(find.text('Something went wrong'), findsOneWidget);
        expect(client.callCount, 0);
      });

      testWidgets('does not throw when valid endpoint is provided',
          (tester) async {
        final client = _MockHttpClient((_) async =>
            const ApiResponse(statusCode: 200, data: {'name': 'test'}));

        await tester.pumpWidget(_wrap(ApiWidget(
          endpoint: 'https://api.example.com/data',
          httpClient: client,
          showRetryButton: false,
        )));

        await tester.pumpAndSettle();
        expect(client.callCount, 1);
      });

      testWidgets('does not throw when ApiRequest is provided with empty string endpoint',
          (tester) async {
        // ApiRequest path bypasses the empty-endpoint guard
        final client = _MockHttpClient((_) async =>
            const ApiResponse(statusCode: 200, data: {'key': 'val'}));

        await tester.pumpWidget(_wrap(ApiWidget(
          request: const ApiRequest(endpoint: 'https://api.example.com/data'),
          httpClient: client,
          showRetryButton: false,
        )));

        await tester.pumpAndSettle();
        expect(client.callCount, 1);
      });
    });

    group('didUpdateWidget refetch', () {
      testWidgets('refetches when endpoint changes', (tester) async {
        final client = _MockHttpClient((_) async =>
            const ApiResponse(statusCode: 200, data: {'v': 1}));

        await tester.pumpWidget(_wrap(ApiWidget(
          endpoint: 'https://api.example.com/v1',
          httpClient: client,
          showRetryButton: false,
        )));
        await tester.pumpAndSettle();
        expect(client.callCount, 1);

        await tester.pumpWidget(_wrap(ApiWidget(
          endpoint: 'https://api.example.com/v2',
          httpClient: client,
          showRetryButton: false,
        )));
        await tester.pumpAndSettle();
        expect(client.callCount, 2);
        expect(client.lastUrl, 'https://api.example.com/v2');
      });

      testWidgets('refetches when ApiRequest changes', (tester) async {
        final client = _MockHttpClient((_) async =>
            const ApiResponse(statusCode: 200, data: {'v': 1}));

        const req1 = ApiRequest(endpoint: 'https://api.example.com/a');
        const req2 = ApiRequest(endpoint: 'https://api.example.com/b');

        await tester.pumpWidget(_wrap(ApiWidget(
          request: req1,
          httpClient: client,
          showRetryButton: false,
        )));
        await tester.pumpAndSettle();
        expect(client.callCount, 1);

        await tester.pumpWidget(_wrap(ApiWidget(
          request: req2,
          httpClient: client,
          showRetryButton: false,
        )));
        await tester.pumpAndSettle();
        expect(client.callCount, 2);
        expect(client.lastUrl, 'https://api.example.com/b');
      });

      testWidgets('does not refetch when unrelated props change', (tester) async {
        final client = _MockHttpClient((_) async =>
            const ApiResponse(statusCode: 200, data: {'v': 1}));

        await tester.pumpWidget(_wrap(ApiWidget(
          endpoint: 'https://api.example.com/data',
          httpClient: client,
          showRetryButton: false,
        )));
        await tester.pumpAndSettle();
        expect(client.callCount, 1);

        // Change only showRetryButton — should not trigger refetch
        await tester.pumpWidget(_wrap(ApiWidget(
          endpoint: 'https://api.example.com/data',
          httpClient: client,
          showRetryButton: true,
        )));
        await tester.pumpAndSettle();
        expect(client.callCount, 1);
      });
    });

    group('error callback deduplication', () {
      testWidgets('onError called once per unique error', (tester) async {
        int errorCallCount = 0;

        final client = _MockHttpClient((_) async =>
            throw Exception('network failure'));

        await tester.pumpWidget(_wrap(ApiWidget(
          endpoint: 'https://api.example.com/data',
          httpClient: client,
          showRetryButton: false,
          onError: (_) => errorCallCount++,
        )));

        await tester.pumpAndSettle();
        tester.takeException(); // consume zone-reported error (expected)
        expect(errorCallCount, 1);

        // Rebuild with same error — callback must not fire again
        await tester.pump();
        await tester.pumpAndSettle();
        expect(errorCallCount, 1);
      });

      testWidgets('onError fires again for a different error', (tester) async {
        int errorCallCount = 0;

        // First endpoint → error A
        await tester.pumpWidget(_wrap(ApiWidget(
          endpoint: 'https://api.example.com/v1',
          httpClient: _MockHttpClient((_) async => throw Exception('error v1')),
          showRetryButton: false,
          onError: (_) => errorCallCount++,
        )));
        await tester.pumpAndSettle();
        tester.takeException(); // consume zone-reported error (expected)
        expect(errorCallCount, 1);

        // Change endpoint (triggers didUpdateWidget → refetch) → error B
        // Different error message → different hash → callback fires again
        await tester.pumpWidget(_wrap(ApiWidget(
          endpoint: 'https://api.example.com/v2',
          httpClient: _MockHttpClient((_) async => throw Exception('error v2')),
          showRetryButton: false,
          onError: (_) => errorCallCount++,
        )));
        await tester.pumpAndSettle();
        tester.takeException(); // consume zone-reported error (expected)
        expect(errorCallCount, 2);
      });
    });

    group('success callback', () {
      testWidgets('onSuccess called with response data', (tester) async {
        dynamic received;

        final client = _MockHttpClient((_) async =>
            const ApiResponse(statusCode: 200, data: {'name': 'Flutter'}));

        await tester.pumpWidget(_wrap(ApiWidget(
          endpoint: 'https://api.example.com/data',
          httpClient: client,
          showRetryButton: false,
          onSuccess: (data) => received = data,
        )));

        await tester.pumpAndSettle();
        expect(received, {'name': 'Flutter'});
      });

      testWidgets('onSuccess not called again on rebuild with same data',
          (tester) async {
        int callCount = 0;

        final client = _MockHttpClient((_) async =>
            const ApiResponse(statusCode: 200, data: {'id': 1}));

        await tester.pumpWidget(_wrap(ApiWidget(
          endpoint: 'https://api.example.com/data',
          httpClient: client,
          showRetryButton: false,
          onSuccess: (_) => callCount++,
        )));

        await tester.pumpAndSettle();
        expect(callCount, 1);

        await tester.pump();
        await tester.pumpAndSettle();
        expect(callCount, 1);
      });
    });

    group('loading and empty states', () {
      testWidgets('shows custom loading widget while fetching', (tester) async {
        final completer = Completer<ApiResponse>();
        final client = _MockHttpClient((_) => completer.future);

        await tester.pumpWidget(_wrap(ApiWidget(
          endpoint: 'https://api.example.com/data',
          httpClient: client,
          loadingWidget: const Text('Fetching...'),
          showRetryButton: false,
        )));

        await tester.pump();
        expect(find.text('Fetching...'), findsOneWidget);
        completer.complete(const ApiResponse(statusCode: 200, data: {'x': 1}));
        await tester.pumpAndSettle();
      });

      testWidgets('shows empty widget for empty map response', (tester) async {
        final client = _MockHttpClient((_) async =>
            const ApiResponse(statusCode: 200, data: {}));

        await tester.pumpWidget(_wrap(ApiWidget(
          endpoint: 'https://api.example.com/data',
          httpClient: client,
          emptyWidget: const Text('Nothing here'),
          showRetryButton: false,
        )));

        await tester.pumpAndSettle();
        expect(find.text('Nothing here'), findsOneWidget);
      });

      testWidgets('shows empty widget for null data', (tester) async {
        final client = _MockHttpClient((_) async =>
            const ApiResponse(statusCode: 200, data: null));

        await tester.pumpWidget(_wrap(ApiWidget(
          endpoint: 'https://api.example.com/data',
          httpClient: client,
          emptyWidget: const Text('Empty'),
          showRetryButton: false,
        )));

        await tester.pumpAndSettle();
        expect(find.text('Empty'), findsOneWidget);
      });
    });

    group('retry button', () {
      testWidgets('retry button triggers refetch on error', (tester) async {
        int callCount = 0;
        final client = _MockHttpClient((_) async {
          callCount++;
          if (callCount == 1) throw Exception('first failure');
          return const ApiResponse(statusCode: 200, data: {'ok': true});
        });

        await tester.pumpWidget(_wrap(ApiWidget(
          endpoint: 'https://api.example.com/data',
          httpClient: client,
          showRetryButton: true,
        )));

        await tester.pumpAndSettle();
        tester.takeException(); // consume zone-reported error (expected)
        expect(find.text('Retry'), findsOneWidget);

        await tester.tap(find.text('Retry'));
        await tester.pumpAndSettle();
        expect(callCount, 2);
        expect(find.text('Retry'), findsNothing);
      });
    });
  });
}
