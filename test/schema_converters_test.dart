import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:backend_driven_ui/src/utils/schema_converters.dart';

void main() {
  group('SchemaConverters.toDouble', () {
    test('returns null for null', () {
      expect(SchemaConverters.toDouble(null), isNull);
    });

    test('returns double as-is', () {
      expect(SchemaConverters.toDouble(3.14), 3.14);
    });

    test('converts int to double', () {
      expect(SchemaConverters.toDouble(16), 16.0);
    });

    test('parses numeric string', () {
      expect(SchemaConverters.toDouble('12.5'), 12.5);
    });

    test('returns null for non-numeric string', () {
      expect(SchemaConverters.toDouble('abc'), isNull);
    });

    test('returns null for unsupported type', () {
      expect(SchemaConverters.toDouble(true), isNull);
    });
  });

  group('SchemaConverters.toColor', () {
    test('returns null for null', () {
      expect(SchemaConverters.toColor(null), isNull);
    });

    test('converts int ARGB value', () {
      expect(SchemaConverters.toColor(0xFF0000FF), const Color(0xFF0000FF));
    });

    test('converts #RRGGBB hex string (adds FF alpha)', () {
      expect(SchemaConverters.toColor('#0000FF'), const Color(0xFF0000FF));
    });

    test('converts #AARRGGBB hex string', () {
      expect(SchemaConverters.toColor('#800000FF'), const Color(0x800000FF));
    });

    test('returns null for malformed hex', () {
      expect(SchemaConverters.toColor('#ZZZZZZ'), isNull);
    });

    test('returns null for wrong hex length', () {
      expect(SchemaConverters.toColor('#ABC'), isNull);
    });

    test('named color "red" resolves', () {
      expect(SchemaConverters.toColor('red'), Colors.red);
    });

    test('named color "blue" resolves', () {
      expect(SchemaConverters.toColor('blue'), Colors.blue);
    });

    test('named color "transparent" resolves', () {
      expect(SchemaConverters.toColor('transparent'), Colors.transparent);
    });

    test('Colors.x prefix stripped before lookup', () {
      expect(SchemaConverters.toColor('Colors.red'), Colors.red);
    });

    test('case-insensitive named color', () {
      expect(SchemaConverters.toColor('RED'), Colors.red);
      expect(SchemaConverters.toColor('Blue'), Colors.blue);
    });

    test('numeric string parsed as ARGB int', () {
      expect(SchemaConverters.toColor('4278190335'), const Color(0xFF0000FF));
    });

    test('unknown named color returns null', () {
      expect(SchemaConverters.toColor('notacolor'), isNull);
    });
  });

  group('SchemaConverters.toIconData', () {
    test('returns null for null', () {
      expect(SchemaConverters.toIconData(null), isNull);
    });

    test('known icon "home" resolves', () {
      expect(SchemaConverters.toIconData('home'), Icons.home);
    });

    test('known icon "search" resolves', () {
      expect(SchemaConverters.toIconData('search'), Icons.search);
    });

    test('known icon "back" resolves to arrow_back', () {
      expect(SchemaConverters.toIconData('back'), Icons.arrow_back);
    });

    test('unknown icon returns help_outline fallback', () {
      expect(SchemaConverters.toIconData('nonexistent'), Icons.help_outline);
    });
  });

  group('SchemaConverters.toEdgeInsets', () {
    test('returns null for null', () {
      expect(SchemaConverters.toEdgeInsets(null), isNull);
    });

    test('numeric value creates symmetric insets', () {
      expect(SchemaConverters.toEdgeInsets(16), const EdgeInsets.all(16));
    });

    test('double value creates symmetric insets', () {
      expect(SchemaConverters.toEdgeInsets(8.0), const EdgeInsets.all(8));
    });

    test('map with all creates EdgeInsets.all', () {
      expect(
        SchemaConverters.toEdgeInsets({'all': 12}),
        const EdgeInsets.all(12),
      );
    });

    test('map with individual sides', () {
      expect(
        SchemaConverters.toEdgeInsets(
            {'top': 4, 'bottom': 8, 'left': 2, 'right': 6}),
        const EdgeInsets.fromLTRB(2, 4, 6, 8),
      );
    });

    test('map with horizontal/vertical', () {
      expect(
        SchemaConverters.toEdgeInsets({'horizontal': 16, 'vertical': 8}),
        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      );
    });
  });

  group('SchemaConverters.toFontWeight', () {
    test('returns null for null', () {
      expect(SchemaConverters.toFontWeight(null), isNull);
    });

    test('"bold" resolves', () {
      expect(SchemaConverters.toFontWeight('bold'), FontWeight.bold);
    });

    test('int 700 resolves to w700', () {
      expect(SchemaConverters.toFontWeight(700), FontWeight.w700);
    });

    test('int 400 resolves to w400 (normal)', () {
      expect(SchemaConverters.toFontWeight(400), FontWeight.w400);
    });

    test('unknown string returns null', () {
      expect(SchemaConverters.toFontWeight('heavy'), isNull);
    });
  });

  group('SchemaConverters.toTextAlign', () {
    test('returns null for null', () {
      expect(SchemaConverters.toTextAlign(null), isNull);
    });

    test('"center" resolves', () {
      expect(SchemaConverters.toTextAlign('center'), TextAlign.center);
    });

    test('"left" resolves', () {
      expect(SchemaConverters.toTextAlign('left'), TextAlign.left);
    });

    test('"right" resolves', () {
      expect(SchemaConverters.toTextAlign('right'), TextAlign.right);
    });

    test('unknown returns null', () {
      expect(SchemaConverters.toTextAlign('justify_all'), isNull);
    });
  });

  group('SchemaConverters.toMainAxisAlignment', () {
    test('"center" resolves', () {
      expect(
        SchemaConverters.toMainAxisAlignment('center'),
        MainAxisAlignment.center,
      );
    });

    test('"spaceBetween" resolves', () {
      expect(
        SchemaConverters.toMainAxisAlignment('spaceBetween'),
        MainAxisAlignment.spaceBetween,
      );
    });

    test('unknown falls back to start', () {
      expect(
        SchemaConverters.toMainAxisAlignment('unknown'),
        MainAxisAlignment.start,
      );
    });
  });

  group('SchemaConverters.toBorderRadius', () {
    test('returns null for null', () {
      expect(SchemaConverters.toBorderRadius(null), isNull);
    });

    test('numeric value creates circular radius', () {
      expect(
        SchemaConverters.toBorderRadius(8),
        BorderRadius.circular(8),
      );
    });
  });
}
