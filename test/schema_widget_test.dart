import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:backend_driven_ui/backend_driven_ui.dart';

Widget _wrap(Widget child) =>
    MaterialApp(home: Scaffold(body: Center(child: child)));

void main() {
  group('SchemaWidget', () {
    testWidgets('renders Text from JSON schema', (tester) async {
      await tester.pumpWidget(_wrap(
        SchemaWidget.fromJson(const {
          'type': 'Text',
          'props': {'text': 'Hello Backend'},
        }),
      ));
      expect(find.text('Hello Backend'), findsOneWidget);
    });

    testWidgets('renders Column with children', (tester) async {
      await tester.pumpWidget(_wrap(
        SchemaWidget.fromJson(const {
          'type': 'Column',
          'children': [
            {'type': 'Text', 'props': {'text': 'First'}},
            {'type': 'Text', 'props': {'text': 'Second'}},
          ],
        }),
      ));
      expect(find.text('First'), findsOneWidget);
      expect(find.text('Second'), findsOneWidget);
    });

    testWidgets('renders SizedBox with child', (tester) async {
      await tester.pumpWidget(_wrap(
        SchemaWidget.fromJson(const {
          'type': 'SizedBox',
          'props': {'width': 100, 'height': 50},
          'child': {'type': 'Text', 'props': {'text': 'Inside'}},
        }),
      ));
      expect(find.text('Inside'), findsOneWidget);
    });

    testWidgets('renders Center wrapping Text', (tester) async {
      await tester.pumpWidget(_wrap(
        SchemaWidget.fromJson(const {
          'type': 'Center',
          'child': {'type': 'Text', 'props': {'text': 'Centered'}},
        }),
      ));
      expect(find.text('Centered'), findsOneWidget);
      expect(find.byType(Center), findsWidgets);
    });

    testWidgets('unknown widget type shows fallback, does not crash', (tester) async {
      await tester.pumpWidget(_wrap(
        SchemaWidget.fromJson(const {'type': 'UnknownWidget123'}),
      ));
      expect(find.byType(SchemaWidget), findsOneWidget);
    });

    testWidgets('conditional rendering hides widget when false', (tester) async {
      await tester.pumpWidget(_wrap(
        SchemaWidget.fromJson(const {
          'type': 'Text',
          'props': {'text': 'Conditional'},
          'condition': 'false',
        }),
      ));
      expect(find.text('Conditional'), findsNothing);
    });

    testWidgets('conditional rendering shows widget when true', (tester) async {
      await tester.pumpWidget(_wrap(
        SchemaWidget.fromJson(const {
          'type': 'Text',
          'props': {'text': 'Shown'},
          'condition': 'true',
        }),
      ));
      expect(find.text('Shown'), findsOneWidget);
    });

    testWidgets('Text with hex color does not crash', (tester) async {
      await tester.pumpWidget(_wrap(
        SchemaWidget.fromJson(const {
          'type': 'Text',
          'props': {'text': 'Colored', 'color': '#FF0000'},
        }),
      ));
      expect(find.text('Colored'), findsOneWidget);
    });

    testWidgets('Text with named color does not crash', (tester) async {
      await tester.pumpWidget(_wrap(
        SchemaWidget.fromJson(const {
          'type': 'Text',
          'props': {'text': 'Named', 'color': 'blue'},
        }),
      ));
      expect(find.text('Named'), findsOneWidget);
    });

    testWidgets('Text with Colors.x notation does not crash', (tester) async {
      await tester.pumpWidget(_wrap(
        SchemaWidget.fromJson(const {
          'type': 'Text',
          'props': {'text': 'Flutter color', 'color': 'Colors.red'},
        }),
      ));
      expect(find.text('Flutter color'), findsOneWidget);
    });

    testWidgets('Text with int color does not crash', (tester) async {
      await tester.pumpWidget(_wrap(
        SchemaWidget.fromJson(const {
          'type': 'Text',
          'props': {'text': 'Int color', 'color': 4278190335}, // blue ARGB
        }),
      ));
      expect(find.text('Int color'), findsOneWidget);
    });

    testWidgets('Container with padding renders child', (tester) async {
      await tester.pumpWidget(_wrap(
        SchemaWidget.fromJson(const {
          'type': 'Container',
          'props': {'padding': 16},
          'child': {'type': 'Text', 'props': {'text': 'Padded'}},
        }),
      ));
      expect(find.text('Padded'), findsOneWidget);
    });

    testWidgets('Row renders multiple children horizontally', (tester) async {
      await tester.pumpWidget(_wrap(
        SchemaWidget.fromJson(const {
          'type': 'Row',
          'children': [
            {'type': 'Text', 'props': {'text': 'Left'}},
            {'type': 'Text', 'props': {'text': 'Right'}},
          ],
        }),
      ));
      expect(find.text('Left'), findsOneWidget);
      expect(find.text('Right'), findsOneWidget);
    });

    testWidgets('Padding widget renders child', (tester) async {
      await tester.pumpWidget(_wrap(
        SchemaWidget.fromJson(const {
          'type': 'Padding',
          'props': {'padding': 8},
          'child': {'type': 'Text', 'props': {'text': 'Padded Text'}},
        }),
      ));
      expect(find.text('Padded Text'), findsOneWidget);
    });

    testWidgets('Icon renders without crash', (tester) async {
      await tester.pumpWidget(_wrap(
        SchemaWidget.fromJson(const {
          'type': 'Icon',
          'props': {'icon': 'home'},
        }),
      ));
      expect(find.byType(Icon), findsWidgets);
    });

    testWidgets('Divider renders without crash', (tester) async {
      await tester.pumpWidget(_wrap(
        SchemaWidget.fromJson(const {'type': 'Divider'}),
      ));
      expect(find.byType(Divider), findsOneWidget);
    });

    testWidgets('Opacity renders child', (tester) async {
      await tester.pumpWidget(_wrap(
        SchemaWidget.fromJson(const {
          'type': 'Opacity',
          'props': {'opacity': 0.5},
          'child': {'type': 'Text', 'props': {'text': 'Faded'}},
        }),
      ));
      expect(find.text('Faded'), findsOneWidget);
    });

    testWidgets('deeply nested schema does not crash', (tester) async {
      // Build a 10-level deep nesting dynamically — cannot be const
      Map<String, dynamic> nested = {
        'type': 'Text',
        'props': {'text': 'Deep'},
      };
      for (var i = 0; i < 10; i++) {
        nested = {'type': 'Center', 'child': nested};
      }
      await tester.pumpWidget(_wrap(SchemaWidget.fromJson(nested)));
      expect(find.text('Deep'), findsOneWidget);
    });
  });

  group('WidgetRegistry custom registration', () {
    testWidgets('custom widget is rendered from schema', (tester) async {
      final parser = SchemaParser();
      parser.register('CustomBadge', (schema, ctx) {
        final label = schema.props?['label'] as String? ?? '';
        return Chip(label: Text(label));
      });

      await tester.pumpWidget(_wrap(
        SchemaWidget(
          schema: WidgetSchema.fromJson(const {
            'type': 'CustomBadge',
            'props': {'label': 'VIP'},
          }),
          parser: parser,
        ),
      ));
      expect(find.text('VIP'), findsOneWidget);
    });

    testWidgets('overriding a built-in type uses custom builder', (tester) async {
      final parser = SchemaParser();
      parser.register(
        'Text',
        (schema, ctx) => const Text('OVERRIDDEN'),
      );

      await tester.pumpWidget(_wrap(
        SchemaWidget(
          schema: WidgetSchema.fromJson(const {
            'type': 'Text',
            'props': {'text': 'original'},
          }),
          parser: parser,
        ),
      ));
      expect(find.text('OVERRIDDEN'), findsOneWidget);
      expect(find.text('original'), findsNothing);
    });
  });
}
