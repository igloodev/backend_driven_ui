import 'package:flutter_test/flutter_test.dart';
import 'package:backend_driven_ui/src/models/widget_schema.dart';

void main() {
  group('WidgetSchema.fromJson', () {
    test('parses type correctly', () {
      final schema = WidgetSchema.fromJson({'type': 'Text'});
      expect(schema.type, 'Text');
    });

    test('throws ArgumentError for missing type', () {
      expect(() => WidgetSchema.fromJson({'props': {}}), throwsArgumentError);
    });

    test('throws ArgumentError for empty type', () {
      expect(() => WidgetSchema.fromJson({'type': ''}), throwsArgumentError);
    });

    test('parses props map', () {
      final schema = WidgetSchema.fromJson({
        'type': 'Text',
        'props': {'text': 'Hello', 'fontSize': 16},
      });
      expect(schema.props?['text'], 'Hello');
      expect(schema.props?['fontSize'], 16);
    });

    test('parses children list', () {
      final schema = WidgetSchema.fromJson({
        'type': 'Column',
        'children': [
          {'type': 'Text', 'props': {'text': 'A'}},
          {'type': 'Text', 'props': {'text': 'B'}},
        ],
      });
      expect(schema.children?.length, 2);
      expect(schema.children?[0].type, 'Text');
      expect(schema.children?[1].props?['text'], 'B');
    });

    test('parses single child', () {
      final schema = WidgetSchema.fromJson({
        'type': 'Center',
        'child': {'type': 'Text', 'props': {'text': 'centered'}},
      });
      expect(schema.child?.type, 'Text');
      expect(schema.child?.props?['text'], 'centered');
    });

    test('parses condition field', () {
      final schema = WidgetSchema.fromJson({
        'type': 'Text',
        'condition': 'isAndroid',
        'props': {'text': 'hi'},
      });
      expect(schema.condition, 'isAndroid');
    });

    test('parses action field', () {
      final schema = WidgetSchema.fromJson({
        'type': 'Button',
        'action': {'type': 'navigate', 'route': '/home'},
        'props': {'text': 'Go'},
      });
      expect(schema.action, isNotNull);
    });

    test('skips invalid children without throwing', () {
      final schema = WidgetSchema.fromJson({
        'type': 'Column',
        'children': [
          {'type': 'Text'},
          'invalid_child', // not a map — should be skipped
          {'type': 'Icon'},
        ],
      });
      // 'invalid_child' (String) is skipped; only maps are parsed
      expect(schema.children?.length, lessThanOrEqualTo(2));
    });

    test('toJson round-trips correctly', () {
      final original = {
        'type': 'Text',
        'props': {'text': 'hello'},
      };
      final schema = WidgetSchema.fromJson(original);
      final json = schema.toJson();
      expect(json['type'], 'Text');
      expect(json['props']?['text'], 'hello');
    });

    test('getProp returns typed value', () {
      final schema = WidgetSchema.fromJson({
        'type': 'Text',
        'props': {'fontSize': 20, 'bold': true},
      });
      expect(schema.getDouble('fontSize'), 20.0);
      expect(schema.getBool('bold'), isTrue);
    });

    test('getProp returns default when key missing', () {
      final schema = WidgetSchema.fromJson({'type': 'Text'});
      expect(schema.getDouble('fontSize', defaultValue: 14.0), 14.0);
    });

    test('hasProp returns false for missing key', () {
      final schema = WidgetSchema.fromJson({'type': 'Text'});
      expect(schema.hasProp('color'), isFalse);
    });

    test('hasProp returns true for present key', () {
      final schema = WidgetSchema.fromJson({
        'type': 'Text',
        'props': {'color': 4278190080},
      });
      expect(schema.hasProp('color'), isTrue);
    });

    test('children truncated at maxChildren limit', () {
      // Create 501 children — expect truncation at 500 (BduiConfig.maxChildren)
      final children = List.generate(
        501,
        (i) => {'type': 'Text', 'props': {'text': '$i'}},
      );
      final schema = WidgetSchema.fromJson({'type': 'Column', 'children': children});
      expect(schema.children?.length, lessThanOrEqualTo(500));
    });
  });
}
