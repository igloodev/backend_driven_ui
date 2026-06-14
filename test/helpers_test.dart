import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:backend_driven_ui/src/utils/helpers.dart';

Widget _wrap(Widget child) =>
    MaterialApp(home: Scaffold(body: Center(child: child)));

void main() {
  group('toStringKeyedMap', () {
    test('returns Map<String, dynamic> unchanged', () {
      final map = {'a': 1, 'b': 'hello'};
      expect(toStringKeyedMap(map), map);
    });

    test('converts Map<dynamic, dynamic> to Map<String, dynamic>', () {
      final raw = <dynamic, dynamic>{'x': 42};
      final result = toStringKeyedMap(raw);
      expect(result, isNotNull);
      expect(result!['x'], 42);
    });

    test('returns null for null input', () {
      expect(toStringKeyedMap(null), isNull);
    });

    test('returns null for non-map input', () {
      expect(toStringKeyedMap('string'), isNull);
      expect(toStringKeyedMap(42), isNull);
    });
  });

  group('evaluateCondition', () {
    testWidgets('true / false literals', (tester) async {
      late BuildContext ctx;
      await tester.pumpWidget(_wrap(Builder(builder: (c) {
        ctx = c;
        return const SizedBox.shrink();
      })));
      expect(evaluateCondition('true', ctx), isTrue);
      expect(evaluateCondition('false', ctx), isFalse);
    });

    testWidgets('unknown condition returns false', (tester) async {
      late BuildContext ctx;
      await tester.pumpWidget(_wrap(Builder(builder: (c) {
        ctx = c;
        return const SizedBox.shrink();
      })));
      expect(evaluateCondition('unknownCondition', ctx), isFalse);
    });

    testWidgets('isWeb returns bool without crashing', (tester) async {
      late BuildContext ctx;
      await tester.pumpWidget(_wrap(Builder(builder: (c) {
        ctx = c;
        return const SizedBox.shrink();
      })));
      // Just verify it doesn't throw — actual value depends on platform
      expect(() => evaluateCondition('isWeb', ctx), returnsNormally);
    });

    testWidgets('screen size conditions evaluate without crashing',
        (tester) async {
      late BuildContext ctx;
      await tester.pumpWidget(_wrap(Builder(builder: (c) {
        ctx = c;
        return const SizedBox.shrink();
      })));
      expect(() => evaluateCondition('isSmallScreen', ctx), returnsNormally);
      expect(() => evaluateCondition('isMediumScreen', ctx), returnsNormally);
      expect(() => evaluateCondition('isLargeScreen', ctx), returnsNormally);
    });

    testWidgets('theme conditions evaluate without crashing', (tester) async {
      late BuildContext ctx;
      await tester.pumpWidget(_wrap(Builder(builder: (c) {
        ctx = c;
        return const SizedBox.shrink();
      })));
      expect(() => evaluateCondition('isDarkMode', ctx), returnsNormally);
      expect(() => evaluateCondition('isLightMode', ctx), returnsNormally);
    });

    testWidgets('condition is case-insensitive', (tester) async {
      late BuildContext ctx;
      await tester.pumpWidget(_wrap(Builder(builder: (c) {
        ctx = c;
        return const SizedBox.shrink();
      })));
      expect(evaluateCondition('TRUE', ctx), isTrue);
      expect(evaluateCondition('False', ctx), isFalse);
    });
  });
}
