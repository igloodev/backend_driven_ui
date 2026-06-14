import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:backend_driven_ui/backend_driven_ui.dart';

Widget _build(Map<String, dynamic> json, {SchemaParser? parser}) {
  final p = parser ?? SchemaParser();
  final schema = WidgetSchema.fromJson(json);
  return MaterialApp(
    home: Scaffold(
      body: Builder(builder: (ctx) => p.parse(schema, ctx)),
    ),
  );
}

void main() {
  group('Dismissible widget', () {
    testWidgets('renders with child', (tester) async {
      await tester.pumpWidget(_build({
        'type': 'Dismissible',
        'props': {'dismissKey': 'item-1'},
        'child': {
          'type': 'Text',
          'props': {'text': 'Swipe me'}
        },
      }));
      expect(find.byType(Dismissible), findsOneWidget);
      expect(find.text('Swipe me'), findsOneWidget);
    });

    testWidgets('no child does not crash', (tester) async {
      await tester.pumpWidget(_build({
        'type': 'Dismissible',
        'props': {'dismissKey': 'item-empty'},
      }));
    });

    testWidgets('endToStart direction', (tester) async {
      await tester.pumpWidget(_build({
        'type': 'Dismissible',
        'props': {'dismissKey': 'item-2', 'direction': 'endToStart'},
        'child': {
          'type': 'Text',
          'props': {'text': 'Delete'}
        },
      }));
      expect(find.byType(Dismissible), findsOneWidget);
    });

    testWidgets('startToEnd direction', (tester) async {
      await tester.pumpWidget(_build({
        'type': 'Dismissible',
        'props': {'dismissKey': 'item-3', 'direction': 'startToEnd'},
        'child': {
          'type': 'Text',
          'props': {'text': 'Archive'}
        },
      }));
    });

    testWidgets('custom background slot', (tester) async {
      await tester.pumpWidget(_build({
        'type': 'Dismissible',
        'props': {
          'dismissKey': 'item-4',
          'background': {
            'type': 'Container',
            'props': {'color': 'green'},
          },
        },
        'child': {
          'type': 'Text',
          'props': {'text': 'Custom bg'}
        },
      }));
    });

    testWidgets('setState action fires on dismiss', (tester) async {
      final sm = BduiStateManager();
      final parser = SchemaParser(stateManager: sm);

      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (ctx) => parser.parse(
              WidgetSchema.fromJson({
                'type': 'Dismissible',
                'props': {'dismissKey': 'item-5'},
                'child': {
                  'type': 'Container',
                  'props': {'height': 80, 'color': 'blue'},
                },
                'action': {
                  'type': 'setState',
                  'params': {'key': 'dismissed', 'value': true},
                },
              }),
              ctx,
            ),
          ),
        ),
      ));

      await tester.drag(find.byType(Dismissible), const Offset(-400, 0));
      await tester.pumpAndSettle();

      expect(sm.get('dismissed'), true);
    });
  });
}
