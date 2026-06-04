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
  group('BduiValidatorMessages — defaults', () {
    tearDown(() => BduiValidatorMessages.reset());

    test('required is English by default', () {
      expect(BduiValidatorMessages.required, 'This field is required');
    });

    test('email default', () {
      expect(BduiValidatorMessages.email, 'Enter a valid email address');
    });

    test('phone default', () {
      expect(BduiValidatorMessages.phone, isNotEmpty);
    });

    test('url default', () {
      expect(BduiValidatorMessages.url, isNotEmpty);
    });

    test('minLength factory produces correct string', () {
      expect(BduiValidatorMessages.minLength(8), 'Minimum 8 characters required');
    });

    test('maxLength factory produces correct string', () {
      expect(BduiValidatorMessages.maxLength(20), 'Maximum 20 characters allowed');
    });

    test('min factory produces correct string', () {
      expect(BduiValidatorMessages.min(10), contains('10'));
    });

    test('max factory produces correct string', () {
      expect(BduiValidatorMessages.max(100), contains('100'));
    });
  });

  group('BduiValidatorMessages — overrides', () {
    tearDown(() => BduiValidatorMessages.reset());

    test('override required message', () {
      BduiValidatorMessages.required = 'Yeh field zaroori hai';
      expect(BduiValidatorMessages.required, 'Yeh field zaroori hai');
    });

    test('override minLength factory', () {
      BduiValidatorMessages.minLength = (n) => 'Kam se kam $n characters chahiye';
      expect(BduiValidatorMessages.minLength(6), 'Kam se kam 6 characters chahiye');
    });

    test('reset restores English defaults', () {
      BduiValidatorMessages.required = 'Custom';
      BduiValidatorMessages.reset();
      expect(BduiValidatorMessages.required, 'This field is required');
    });

    testWidgets('overridden message appears in form validation', (tester) async {
      BduiValidatorMessages.required = 'Zaroori hai!';
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
                    'props': {'formKey': 'i18nForm', 'autovalidateMode': 'always'},
                    'child': {
                      'type': 'TextFormField',
                      'props': {'validators': ['required']},
                    },
                  },
                ],
              }),
              ctx,
            ),
          ),
        ),
      ));

      await tester.pump();
      expect(find.text('Zaroori hai!'), findsOneWidget);
    });
  });

  group('Validators — phone', () {
    testWidgets('invalid phone shows error', (tester) async {
      await tester.pumpWidget(_build({
        'type': 'Form',
        'props': {'formKey': 'ph', 'autovalidateMode': 'always'},
        'child': {
          'type': 'TextFormField',
          'props': {'value': 'not-a-phone', 'validators': ['phone']},
        },
      }));
      await tester.pump();
      expect(find.text(BduiValidatorMessages.phone), findsOneWidget);
    });

    testWidgets('valid phone passes', (tester) async {
      await tester.pumpWidget(_build({
        'type': 'Form',
        'props': {'formKey': 'ph2', 'autovalidateMode': 'always'},
        'child': {
          'type': 'TextFormField',
          'props': {'value': '+919876543210', 'validators': ['phone']},
        },
      }));
      await tester.pump();
      expect(find.text(BduiValidatorMessages.phone), findsNothing);
    });
  });

  group('Validators — url', () {
    testWidgets('url without scheme shows error', (tester) async {
      await tester.pumpWidget(_build({
        'type': 'Form',
        'props': {'formKey': 'u', 'autovalidateMode': 'always'},
        'child': {
          'type': 'TextFormField',
          'props': {'value': 'example.com', 'validators': ['url']},
        },
      }));
      await tester.pump();
      expect(find.text(BduiValidatorMessages.url), findsOneWidget);
    });

    testWidgets('valid https url passes', (tester) async {
      await tester.pumpWidget(_build({
        'type': 'Form',
        'props': {'formKey': 'u2', 'autovalidateMode': 'always'},
        'child': {
          'type': 'TextFormField',
          'props': {'value': 'https://example.com', 'validators': ['url']},
        },
      }));
      await tester.pump();
      expect(find.text(BduiValidatorMessages.url), findsNothing);
    });
  });

  group('Validators — min / max', () {
    testWidgets('min fails when value too low', (tester) async {
      await tester.pumpWidget(_build({
        'type': 'Form',
        'props': {'formKey': 'mn', 'autovalidateMode': 'always'},
        'child': {
          'type': 'TextFormField',
          'props': {'value': '5', 'validators': ['min:10']},
        },
      }));
      await tester.pump();
      expect(find.text(BduiValidatorMessages.min(10)), findsOneWidget);
    });

    testWidgets('min passes when value sufficient', (tester) async {
      await tester.pumpWidget(_build({
        'type': 'Form',
        'props': {'formKey': 'mn2', 'autovalidateMode': 'always'},
        'child': {
          'type': 'TextFormField',
          'props': {'value': '15', 'validators': ['min:10']},
        },
      }));
      await tester.pump();
      expect(find.text(BduiValidatorMessages.min(10)), findsNothing);
    });

    testWidgets('max fails when value too high', (tester) async {
      await tester.pumpWidget(_build({
        'type': 'Form',
        'props': {'formKey': 'mx', 'autovalidateMode': 'always'},
        'child': {
          'type': 'TextFormField',
          'props': {'value': '200', 'validators': ['max:100']},
        },
      }));
      await tester.pump();
      expect(find.text(BduiValidatorMessages.max(100)), findsOneWidget);
    });

    testWidgets('max passes when value within limit', (tester) async {
      await tester.pumpWidget(_build({
        'type': 'Form',
        'props': {'formKey': 'mx2', 'autovalidateMode': 'always'},
        'child': {
          'type': 'TextFormField',
          'props': {'value': '50', 'validators': ['max:100']},
        },
      }));
      await tester.pump();
      expect(find.text(BduiValidatorMessages.max(100)), findsNothing);
    });
  });
}
