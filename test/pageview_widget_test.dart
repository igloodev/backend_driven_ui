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
  group('PageView', () {
    testWidgets('renders with children', (tester) async {
      await tester.pumpWidget(_build({
        'type': 'PageView',
        'children': [
          {'type': 'Text', 'props': {'text': 'Page 1'}},
          {'type': 'Text', 'props': {'text': 'Page 2'}},
          {'type': 'Text', 'props': {'text': 'Page 3'}},
        ],
      }));

      expect(find.byType(PageView), findsOneWidget);
      expect(find.text('Page 1'), findsOneWidget);
    });

    testWidgets('no children does not crash', (tester) async {
      await tester.pumpWidget(_build({'type': 'PageView'}));
      expect(find.byType(PageView), findsOneWidget);
    });

    testWidgets('vertical scrollDirection does not crash', (tester) async {
      await tester.pumpWidget(_build({
        'type': 'PageView',
        'props': {'scrollDirection': 'vertical'},
        'children': [
          {'type': 'Text', 'props': {'text': 'A'}},
        ],
      }));
    });

    testWidgets('reverse prop does not crash', (tester) async {
      await tester.pumpWidget(_build({
        'type': 'PageView',
        'props': {'reverse': true},
        'children': [
          {'type': 'Text', 'props': {'text': 'R'}},
        ],
      }));
    });
  });

  group('PageView.builder', () {
    testWidgets('renders with itemCount and child template', (tester) async {
      await tester.pumpWidget(_build({
        'type': 'PageView.builder',
        'props': {'itemCount': 3},
        'child': {'type': 'Text', 'props': {'text': 'item'}},
      }));

      expect(find.byType(PageView), findsOneWidget);
    });

    testWidgets('no child does not crash', (tester) async {
      await tester.pumpWidget(_build({
        'type': 'PageView.builder',
        'props': {'itemCount': 2},
      }));
    });

    testWidgets('null itemCount (infinite) does not crash', (tester) async {
      await tester.pumpWidget(_build({
        'type': 'PageView.builder',
        'child': {'type': 'Text', 'props': {'text': 'x'}},
      }));
    });
  });
}
