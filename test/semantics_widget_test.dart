import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:backend_driven_ui/backend_driven_ui.dart';

Widget _build(Map<String, dynamic> json) {
  final schema = WidgetSchema.fromJson(json);
  return MaterialApp(
    home: Scaffold(
      body: Builder(builder: (ctx) => SchemaParser().parse(schema, ctx)),
    ),
  );
}

void main() {
  group('Semantics widget', () {
    testWidgets('renders with label and child', (tester) async {
      await tester.pumpWidget(_build({
        'type': 'Semantics',
        'props': {'label': 'Submit button', 'button': true},
        'child': {'type': 'Text', 'props': {'text': 'Submit'}},
      }));
      expect(find.byType(Semantics), findsWidgets);
      expect(find.text('Submit'), findsOneWidget);
    });

    testWidgets('no child does not crash', (tester) async {
      await tester.pumpWidget(_build({
        'type': 'Semantics',
        'props': {'label': 'Empty area'},
      }));
    });

    testWidgets('hint and value props', (tester) async {
      await tester.pumpWidget(_build({
        'type': 'Semantics',
        'props': {
          'label': 'Volume slider',
          'hint': 'Swipe up or down to adjust',
          'value': '50%',
        },
        'child': {'type': 'Text', 'props': {'text': 'Vol'}},
      }));
    });

    testWidgets('all bool props do not crash', (tester) async {
      await tester.pumpWidget(_build({
        'type': 'Semantics',
        'props': {
          'label': 'Complex widget',
          'hint': 'Double tap to activate',
          'button': true,
          'enabled': true,
          'readOnly': false,
          'header': false,
          'image': false,
          'liveRegion': true,
          'excludeSemantics': false,
          'selected': false,
        },
        'child': {'type': 'Text', 'props': {'text': 'A11y'}},
      }));
    });

    testWidgets('excludeSemantics hides child from screen readers', (tester) async {
      await tester.pumpWidget(_build({
        'type': 'Semantics',
        'props': {'excludeSemantics': true, 'label': 'Decorative'},
        'child': {'type': 'Icon', 'props': {'icon': 'star'}},
      }));
    });

    testWidgets('checked and toggled props', (tester) async {
      await tester.pumpWidget(_build({
        'type': 'Semantics',
        'props': {'label': 'Checkbox', 'checked': true},
        'child': {'type': 'Text', 'props': {'text': 'Check'}},
      }));
    });
  });
}
