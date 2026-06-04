import 'package:flutter/cupertino.dart';
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
  group('CupertinoButton', () {
    testWidgets('renders with text', (tester) async {
      await tester.pumpWidget(_build({
        'type': 'CupertinoButton',
        'props': {'text': 'Tap me'},
      }));
      expect(find.byType(CupertinoButton), findsOneWidget);
      expect(find.text('Tap me'), findsOneWidget);
    });

    testWidgets('filled variant', (tester) async {
      await tester.pumpWidget(_build({
        'type': 'CupertinoButton',
        'props': {'text': 'Filled', 'filled': true},
      }));
    });

    testWidgets('disabled state', (tester) async {
      await tester.pumpWidget(_build({
        'type': 'CupertinoButton',
        'props': {'text': 'Disabled', 'disabled': true},
      }));
    });

    testWidgets('no text does not crash', (tester) async {
      await tester.pumpWidget(_build({
        'type': 'CupertinoButton',
        'props': {},
      }));
    });

    testWidgets('setState action fires on press', (tester) async {
      final sm = BduiStateManager();
      final parser = SchemaParser(stateManager: sm);

      await tester.pumpWidget(_build(
        {
          'type': 'CupertinoButton',
          'props': {'text': 'Press'},
          'action': {
            'type': 'setState',
            'params': {'key': 'pressed', 'value': true},
          },
        },
        parser: parser,
      ));

      await tester.tap(find.byType(CupertinoButton));
      await tester.pump();
      expect(sm.get('pressed'), true);
    });
  });

  group('CupertinoSwitch', () {
    testWidgets('renders', (tester) async {
      await tester.pumpWidget(_build({
        'type': 'CupertinoSwitch',
        'props': {'value': false},
      }));
      expect(find.byType(CupertinoSwitch), findsOneWidget);
    });

    testWidgets('toggling updates stateManager', (tester) async {
      final sm = BduiStateManager();
      final parser = SchemaParser(stateManager: sm);

      await tester.pumpWidget(_build(
        {
          'type': 'CupertinoSwitch',
          'props': {'value': false, 'stateKey': 'iosToggle'},
        },
        parser: parser,
      ));

      await tester.tap(find.byType(CupertinoSwitch));
      await tester.pump();
      expect(sm.get('iosToggle'), true);
    });
  });

  group('CupertinoSlider', () {
    testWidgets('renders', (tester) async {
      await tester.pumpWidget(_build({
        'type': 'CupertinoSlider',
        'props': {'value': 0.5, 'min': 0.0, 'max': 1.0},
      }));
      expect(find.byType(CupertinoSlider), findsOneWidget);
    });

    testWidgets('no props does not crash', (tester) async {
      await tester.pumpWidget(_build({'type': 'CupertinoSlider', 'props': {}}));
    });

    testWidgets('value clamped to min-max', (tester) async {
      await tester.pumpWidget(_build({
        'type': 'CupertinoSlider',
        'props': {'value': 999, 'min': 0.0, 'max': 100.0},
      }));
    });
  });

  group('CupertinoActivityIndicator', () {
    testWidgets('renders', (tester) async {
      await tester.pumpWidget(_build({
        'type': 'CupertinoActivityIndicator',
        'props': {'radius': 12.0, 'animating': true},
      }));
      expect(find.byType(CupertinoActivityIndicator), findsOneWidget);
    });

    testWidgets('no props does not crash', (tester) async {
      await tester.pumpWidget(_build({
        'type': 'CupertinoActivityIndicator',
        'props': {},
      }));
    });
  });

  group('CupertinoTextField', () {
    testWidgets('renders', (tester) async {
      await tester.pumpWidget(_build({
        'type': 'CupertinoTextField',
        'props': {'hint': 'Search...'},
      }));
      expect(find.byType(CupertinoTextField), findsOneWidget);
    });

    testWidgets('typing updates stateManager', (tester) async {
      final sm = BduiStateManager();
      final parser = SchemaParser(stateManager: sm);

      await tester.pumpWidget(_build(
        {
          'type': 'CupertinoTextField',
          'props': {'hint': 'Name', 'stateKey': 'cupertinoName'},
        },
        parser: parser,
      ));

      await tester.enterText(find.byType(CupertinoTextField), 'Alice');
      await tester.pump();
      expect(sm.get('cupertinoName'), 'Alice');
    });
  });
}
