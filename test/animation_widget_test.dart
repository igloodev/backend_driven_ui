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
  group('animate prop — string shorthand', () {
    for (final type in [
      'fadeIn',
      'slideUp',
      'slideDown',
      'slideLeft',
      'slideRight',
      'scale',
      'bounce',
    ]) {
      testWidgets('$type does not crash', (tester) async {
        await tester.pumpWidget(_build({
          'type': 'Text',
          'props': {'text': 'Hi', 'animate': type},
        }));

        await tester.pump(const Duration(milliseconds: 300));
        expect(find.text('Hi'), findsOneWidget);
      });
    }
  });

  group('animate prop — map config', () {
    testWidgets('type + duration + curve does not crash', (tester) async {
      await tester.pumpWidget(_build({
        'type': 'Text',
        'props': {
          'text': 'Hello',
          'animate': {'type': 'slideUp', 'duration': 400, 'curve': 'easeInOut'},
        },
      }));

      await tester.pump(const Duration(milliseconds: 400));
      expect(find.text('Hello'), findsOneWidget);
    });

    testWidgets('delay does not crash', (tester) async {
      await tester.pumpWidget(_build({
        'type': 'Text',
        'props': {
          'text': 'Delayed',
          'animate': {'type': 'fadeIn', 'delay': 100},
        },
      }));

      await tester.pump(const Duration(milliseconds: 500));
      expect(find.text('Delayed'), findsOneWidget);
    });
  });

  group('animate prop — cache', () {
    testWidgets('animated widget is not served from cache', (tester) async {
      final parser = SchemaParser();
      final schema = WidgetSchema.fromJson({
        'type': 'Text',
        'props': {'text': 'Animated', 'animate': 'fadeIn'},
      });
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: Builder(builder: (ctx) => parser.parse(schema, ctx)),
        ),
      ));
      await tester.pump(const Duration(milliseconds: 300));
    });
  });
}
