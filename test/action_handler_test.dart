import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:backend_driven_ui/src/handlers/action_handler.dart';
import 'package:backend_driven_ui/src/models/action_schema.dart';

// ── Helper ────────────────────────────────────────────────────────────────────

/// Builds a full MaterialApp with Navigator and Scaffold so ActionHandler
/// has a valid BuildContext for navigation, dialogs, and snackbars.
Widget _app(Widget Function(BuildContext context) builder) {
  return MaterialApp(
    routes: {
      '/home': (_) => const Scaffold(body: Text('Home')),
      '/detail': (_) => const Scaffold(body: Text('Detail')),
    },
    home: Builder(builder: builder),
  );
}

// ── Tests ─────────────────────────────────────────────────────────────────────

void main() {
  group('ActionHandler', () {
    group('navigate', () {
      testWidgets('pushes named route', (tester) async {
        late ActionHandler handler;

        await tester.pumpWidget(_app((ctx) {
          handler = ActionHandler(context: ctx);
          return const Scaffold(body: Text('Start'));
        }));

        await handler.execute(const ActionSchema(
          type: 'navigate',
          route: '/detail',
        ));
        await tester.pumpAndSettle();

        expect(find.text('Detail'), findsOneWidget);
      });

      testWidgets(
          'onNavigate callback is called instead of Navigator when provided',
          (tester) async {
        String? navigatedRoute;
        late ActionHandler handler;

        await tester.pumpWidget(_app((ctx) {
          handler = ActionHandler(
            context: ctx,
            onNavigate: (route, _) async => navigatedRoute = route,
          );
          return const Scaffold(body: Text('Start'));
        }));

        await handler.execute(const ActionSchema(
          type: 'navigate',
          route: '/detail',
        ));

        expect(navigatedRoute, '/detail');
      });

      testWidgets('navigate without route logs warning and does not throw',
          (tester) async {
        late ActionHandler handler;

        await tester.pumpWidget(_app((ctx) {
          handler = ActionHandler(context: ctx);
          return const Scaffold(body: Text('Start'));
        }));

        // Should complete without throwing
        await handler.execute(const ActionSchema(type: 'navigate'));
        await tester.pumpAndSettle();
        expect(find.text('Start'), findsOneWidget);
      });
    });

    group('pop', () {
      testWidgets('pops route when navigator can pop', (tester) async {
        late ActionHandler handler;

        await tester.pumpWidget(_app((ctx) {
          return Scaffold(
            body: ElevatedButton(
              onPressed: () async {
                await Navigator.of(ctx).pushNamed('/detail');
              },
              child: const Text('Go'),
            ),
          );
        }));

        await tester.tap(find.text('Go'));
        await tester.pumpAndSettle();
        expect(find.text('Detail'), findsOneWidget);

        // Get context from detail page
        final ctx = tester.element(find.text('Detail'));
        handler = ActionHandler(context: ctx);
        await handler.execute(const ActionSchema(type: 'pop'));
        await tester.pumpAndSettle();

        expect(find.text('Detail'), findsNothing);
      });
    });

    group('showSnackBar', () {
      testWidgets('displays snackbar with message', (tester) async {
        late ActionHandler handler;

        await tester.pumpWidget(_app((ctx) {
          handler = ActionHandler(context: ctx);
          return const Scaffold(body: Text('Start'));
        }));

        handler.execute(const ActionSchema(
          type: 'showSnackBar',
          params: {'message': 'Hello from action'},
        ));
        await tester.pumpAndSettle();

        expect(find.text('Hello from action'), findsOneWidget);
      });

      testWidgets('snackbar with empty message does not crash', (tester) async {
        late ActionHandler handler;

        await tester.pumpWidget(_app((ctx) {
          handler = ActionHandler(context: ctx);
          return const Scaffold(body: Text('Start'));
        }));

        await handler.execute(const ActionSchema(
          type: 'showSnackBar',
          params: {},
        ));
        await tester.pumpAndSettle();
        // No crash is the assertion
      });
    });

    group('copy', () {
      testWidgets('copies text to clipboard and shows feedback snackbar',
          (tester) async {
        // Mock clipboard platform channel so Clipboard.setData doesn't hang
        tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
          SystemChannels.platform,
          (call) async => call.method == 'Clipboard.setData' ? null : null,
        );

        late ActionHandler handler;

        await tester.pumpWidget(_app((ctx) {
          handler = ActionHandler(context: ctx);
          return const Scaffold(body: Text('Start'));
        }));

        await handler.execute(const ActionSchema(
          type: 'copy',
          params: {'text': 'copied content'},
        ));
        await tester.pumpAndSettle();

        expect(find.text('Copied to clipboard'), findsOneWidget);

        // Restore
        tester.binding.defaultBinaryMessenger
            .setMockMethodCallHandler(SystemChannels.platform, null);
      });

      testWidgets('copy without text logs warning and does not crash',
          (tester) async {
        late ActionHandler handler;

        await tester.pumpWidget(_app((ctx) {
          handler = ActionHandler(context: ctx);
          return const Scaffold(body: Text('Start'));
        }));

        await handler.execute(const ActionSchema(type: 'copy', params: {}));
        await tester.pumpAndSettle();
        // No crash is the assertion
      });
    });

    group('sequence', () {
      testWidgets('executes all actions in order', (tester) async {
        final executed = <String>[];
        late ActionHandler handler;

        await tester.pumpWidget(_app((ctx) {
          handler = ActionHandler(
            context: ctx,
            onCustomAction: (name, _) async => executed.add(name),
          );
          return const Scaffold(body: Text('Start'));
        }));

        await handler.execute(const ActionSchema(
          type: 'sequence',
          actions: [
            ActionSchema(type: 'custom', params: {'name': 'first'}),
            ActionSchema(type: 'custom', params: {'name': 'second'}),
            ActionSchema(type: 'custom', params: {'name': 'third'}),
          ],
        ));

        expect(executed, ['first', 'second', 'third']);
      });

      testWidgets('empty actions list does not crash', (tester) async {
        late ActionHandler handler;

        await tester.pumpWidget(_app((ctx) {
          handler = ActionHandler(context: ctx);
          return const Scaffold(body: Text('Start'));
        }));

        await handler.execute(const ActionSchema(
          type: 'sequence',
          actions: [],
        ));
        // No crash is the assertion
      });
    });

    group('custom', () {
      testWidgets('onCustomAction callback is invoked with name and params',
          (tester) async {
        String? receivedName;
        Map<String, dynamic>? receivedParams;
        late ActionHandler handler;

        await tester.pumpWidget(_app((ctx) {
          handler = ActionHandler(
            context: ctx,
            onCustomAction: (name, params) async {
              receivedName = name;
              receivedParams = params;
            },
          );
          return const Scaffold(body: Text('Start'));
        }));

        await handler.execute(const ActionSchema(
          type: 'custom',
          params: {'name': 'myAction', 'key': 'value'},
        ));

        expect(receivedName, 'myAction');
        expect(receivedParams?['key'], 'value');
      });

      testWidgets('no handler registered does not crash', (tester) async {
        late ActionHandler handler;

        await tester.pumpWidget(_app((ctx) {
          handler = ActionHandler(context: ctx);
          return const Scaffold(body: Text('Start'));
        }));

        await handler.execute(const ActionSchema(
          type: 'custom',
          params: {'name': 'unhandled'},
        ));
        // No crash is the assertion
      });
    });

    group('onSuccess / onError chaining', () {
      testWidgets('onSuccess action executes after action completes',
          (tester) async {
        final executed = <String>[];
        late ActionHandler handler;

        await tester.pumpWidget(_app((ctx) {
          handler = ActionHandler(
            context: ctx,
            onCustomAction: (name, _) async => executed.add(name),
          );
          return const Scaffold(body: Text('Start'));
        }));

        await handler.execute(const ActionSchema(
          type: 'custom',
          params: {'name': 'main'},
          onSuccess: ActionSchema(
            type: 'custom',
            params: {'name': 'success'},
          ),
        ));

        expect(executed, ['main', 'success']);
      });
    });

    group('unknown action type', () {
      testWidgets('logs warning and does not throw', (tester) async {
        late ActionHandler handler;

        await tester.pumpWidget(_app((ctx) {
          handler = ActionHandler(context: ctx);
          return const Scaffold(body: Text('Start'));
        }));

        await handler.execute(const ActionSchema(type: 'unknownActionType'));
        // No crash is the assertion
      });
    });

    group('executeFromMap', () {
      testWidgets('parses map and executes action', (tester) async {
        String? receivedName;
        late ActionHandler handler;

        await tester.pumpWidget(_app((ctx) {
          handler = ActionHandler(
            context: ctx,
            onCustomAction: (name, _) async => receivedName = name,
          );
          return const Scaffold(body: Text('Start'));
        }));

        await handler.executeFromMap({
          'type': 'custom',
          'name': 'fromMap',
        });

        expect(receivedName, 'fromMap');
      });

      testWidgets('invalid map logs error and does not throw', (tester) async {
        late ActionHandler handler;

        await tester.pumpWidget(_app((ctx) {
          handler = ActionHandler(context: ctx);
          return const Scaffold(body: Text('Start'));
        }));

        // Missing required 'type' field
        await handler.executeFromMap({'route': '/detail'});
        // No crash is the assertion
      });
    });
  });
}
