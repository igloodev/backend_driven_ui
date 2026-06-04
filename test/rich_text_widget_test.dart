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
  group('RichText widget', () {
    testWidgets('renders with spans', (tester) async {
      await tester.pumpWidget(_build({
        'type': 'RichText',
        'props': {
          'spans': [
            {'text': 'Hello ', 'bold': true, 'color': 'red'},
            {'text': 'World', 'italic': true, 'fontSize': 18},
          ],
        },
      }));
      expect(find.byType(RichText), findsOneWidget);
    });

    testWidgets('empty spans does not crash', (tester) async {
      await tester.pumpWidget(_build({
        'type': 'RichText',
        'props': {'spans': []},
      }));
    });

    testWidgets('no spans prop does not crash', (tester) async {
      await tester.pumpWidget(_build({'type': 'RichText', 'props': {}}));
    });

    testWidgets('underline and strikethrough spans', (tester) async {
      await tester.pumpWidget(_build({
        'type': 'RichText',
        'props': {
          'spans': [
            {'text': 'Underline', 'underline': true},
            {'text': 'Strike', 'strikethrough': true},
            {'text': 'Both', 'underline': true, 'strikethrough': true},
          ],
        },
      }));
    });

    testWidgets('nested spans', (tester) async {
      await tester.pumpWidget(_build({
        'type': 'RichText',
        'props': {
          'spans': [
            {
              'text': 'Parent ',
              'spans': [
                {'text': 'Child', 'bold': true},
              ],
            },
          ],
        },
      }));
    });

    testWidgets('textAlign, maxLines, overflow props', (tester) async {
      await tester.pumpWidget(_build({
        'type': 'RichText',
        'props': {
          'textAlign': 'center',
          'maxLines': 2,
          'overflow': 'ellipsis',
          'spans': [{'text': 'Styled rich text'}],
        },
      }));
    });

    testWidgets('fontFamily, letterSpacing, backgroundColor in span', (tester) async {
      await tester.pumpWidget(_build({
        'type': 'RichText',
        'props': {
          'spans': [
            {
              'text': 'Styled',
              'fontFamily': 'monospace',
              'letterSpacing': 2.0,
              'backgroundColor': 'yellow',
            },
          ],
        },
      }));
    });
  });
}
