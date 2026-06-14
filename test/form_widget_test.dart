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
  group('Form widget', () {
    testWidgets('renders without crashing — no children', (tester) async {
      await tester.pumpWidget(_build({
        'type': 'Form',
        'props': {'formKey': 'test'},
      }));
    });

    testWidgets('renders with child', (tester) async {
      await tester.pumpWidget(_build({
        'type': 'Form',
        'props': {'formKey': 'login'},
        'child': {
          'type': 'TextFormField',
          'props': {'hint': 'Email'}
        },
      }));

      expect(find.byType(Form), findsOneWidget);
      expect(find.byType(TextFormField), findsOneWidget);
    });

    testWidgets('renders with multiple children wrapped in Column',
        (tester) async {
      await tester.pumpWidget(_build({
        'type': 'Form',
        'props': {'formKey': 'signup'},
        'children': [
          {
            'type': 'TextFormField',
            'props': {'hint': 'Name'}
          },
          {
            'type': 'TextFormField',
            'props': {'hint': 'Email'}
          },
        ],
      }));

      expect(find.byType(Form), findsOneWidget);
      expect(find.byType(TextFormField), findsNWidgets(2));
    });

    testWidgets('uses default formKey "_default" when not specified',
        (tester) async {
      final parser = SchemaParser();

      await tester.pumpWidget(_build(
        {
          'type': 'Form',
          'child': {
            'type': 'TextFormField',
            'props': {'hint': 'Field'}
          },
        },
        parser: parser,
      ));

      expect(parser.getFormKey('_default').currentState, isNotNull);
    });

    testWidgets('getFormKey returns the same key object on repeated calls',
        (tester) async {
      final parser = SchemaParser();
      final key1 = parser.getFormKey('form1');
      final key2 = parser.getFormKey('form1');
      expect(key1, same(key2));
    });

    testWidgets(
        'submitForm action validates form — fails without required field',
        (tester) async {
      final parser = SchemaParser();

      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (ctx) => parser.parse(
              WidgetSchema.fromJson({
                'type': 'Column',
                'children': [
                  {
                    'type': 'Form',
                    'props': {'formKey': 'myForm'},
                    'child': {
                      'type': 'TextFormField',
                      'props': {
                        'hint': 'Required',
                        'validators': ['required'],
                      },
                    },
                  },
                  {
                    'type': 'ElevatedButton',
                    'props': {'text': 'Submit'},
                    'action': {
                      'type': 'submitForm',
                      'params': {'formKey': 'myForm'},
                    },
                  },
                ],
              }),
              ctx,
            ),
          ),
        ),
      ));

      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();

      expect(find.text('This field is required'), findsOneWidget);
    });

    testWidgets('autovalidateMode always shows error immediately',
        (tester) async {
      await tester.pumpWidget(_build({
        'type': 'Form',
        'props': {'formKey': 'av', 'autovalidateMode': 'always'},
        'child': {
          'type': 'TextFormField',
          'props': {
            'hint': 'Email',
            'validators': ['required']
          },
        },
      }));

      await tester.pump();
      expect(find.text('This field is required'), findsOneWidget);
    });
  });
}
