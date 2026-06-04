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
  group('BduiStateManager', () {
    test('get returns null for unknown key', () {
      final sm = BduiStateManager();
      expect(sm.get('missing'), isNull);
    });

    test('set stores value and get retrieves it', () {
      final sm = BduiStateManager();
      sm.set('name', 'Alice');
      expect(sm.get('name'), 'Alice');
    });

    test('set overwrites existing value', () {
      final sm = BduiStateManager();
      sm.set('count', 1);
      sm.set('count', 2);
      expect(sm.get('count'), 2);
    });

    test('setAll merges values', () {
      final sm = BduiStateManager();
      sm.set('a', 1);
      sm.setAll({'b': 2, 'c': 3});
      expect(sm.get('a'), 1);
      expect(sm.get('b'), 2);
      expect(sm.get('c'), 3);
    });

    test('remove deletes a key', () {
      final sm = BduiStateManager();
      sm.set('x', 42);
      sm.remove('x');
      expect(sm.get('x'), isNull);
    });

    test('reset clears all state', () {
      final sm = BduiStateManager();
      sm.set('a', 1);
      sm.set('b', 2);
      sm.reset();
      expect(sm.get('a'), isNull);
      expect(sm.get('b'), isNull);
    });

    test('snapshot returns unmodifiable copy', () {
      final sm = BduiStateManager();
      sm.set('key', 'value');
      final snap = sm.snapshot;
      expect(snap['key'], 'value');
      expect(() => (snap as dynamic)['key'] = 'other', throwsA(anything));
    });

    test('notifies listeners on set', () {
      final sm = BduiStateManager();
      int notifyCount = 0;
      sm.addListener(() => notifyCount++);
      sm.set('x', 1);
      sm.set('x', 2);
      expect(notifyCount, 2);
    });

    test('notifies listeners on setAll', () {
      final sm = BduiStateManager();
      int notifyCount = 0;
      sm.addListener(() => notifyCount++);
      sm.setAll({'a': 1, 'b': 2});
      expect(notifyCount, 1);
    });

    test('notifies listeners on remove', () {
      final sm = BduiStateManager();
      sm.set('k', 'v');
      int notifyCount = 0;
      sm.addListener(() => notifyCount++);
      sm.remove('k');
      expect(notifyCount, 1);
    });

    test('notifies listeners on reset', () {
      final sm = BduiStateManager();
      sm.set('k', 'v');
      int notifyCount = 0;
      sm.addListener(() => notifyCount++);
      sm.reset();
      expect(notifyCount, 1);
    });
  });

  group('SchemaParser — stateManager', () {
    test('auto-creates a BduiStateManager when not provided', () {
      final parser = SchemaParser();
      expect(parser.stateManager, isA<BduiStateManager>());
    });

    test('uses the provided BduiStateManager', () {
      final sm = BduiStateManager();
      final parser = SchemaParser(stateManager: sm);
      expect(parser.stateManager, same(sm));
    });
  });

  group('State binding — \${state.key} interpolation', () {
    testWidgets('Text with state ref renders current value', (tester) async {
      final sm = BduiStateManager();
      sm.set('name', 'Alice');
      final parser = SchemaParser(stateManager: sm);

      await tester.pumpWidget(_build(
        {'type': 'Text', 'props': {r'text': r'${state.name}'}},
        parser: parser,
      ));

      expect(find.text('Alice'), findsOneWidget);
    });

    testWidgets('Text with state ref updates when state changes', (tester) async {
      final sm = BduiStateManager();
      sm.set('greeting', 'Hello');
      final parser = SchemaParser(stateManager: sm);

      await tester.pumpWidget(_build(
        {'type': 'Text', 'props': {r'text': r'${state.greeting}'}},
        parser: parser,
      ));

      expect(find.text('Hello'), findsOneWidget);

      sm.set('greeting', 'Goodbye');
      await tester.pump();

      expect(find.text('Hello'), findsNothing);
      expect(find.text('Goodbye'), findsOneWidget);
    });

    testWidgets('unknown state ref renders empty string', (tester) async {
      await tester.pumpWidget(_build(
        {'type': 'Text', 'props': {r'text': r'${state.missing}'}},
      ));
      expect(find.text(''), findsOneWidget);
    });

    testWidgets('interpolation with surrounding text', (tester) async {
      final sm = BduiStateManager();
      sm.set('user', 'Bob');
      final parser = SchemaParser(stateManager: sm);

      await tester.pumpWidget(_build(
        {'type': 'Text', 'props': {r'text': r'Hello, ${state.user}!'}},
        parser: parser,
      ));

      expect(find.text('Hello, Bob!'), findsOneWidget);
    });

    testWidgets('multiple state refs in one prop', (tester) async {
      final sm = BduiStateManager();
      sm.set('first', 'Jane');
      sm.set('last', 'Doe');
      final parser = SchemaParser(stateManager: sm);

      await tester.pumpWidget(_build(
        {'type': 'Text', 'props': {r'text': r'${state.first} ${state.last}'}},
        parser: parser,
      ));

      expect(find.text('Jane Doe'), findsOneWidget);
    });

    testWidgets('non-string props are not interpolated', (tester) async {
      await tester.pumpWidget(_build(
        {'type': 'Text', 'props': {'text': 'hello', 'fontSize': 14}},
      ));
      expect(find.text('hello'), findsOneWidget);
    });
  });

  group('stateKey — TextField', () {
    testWidgets('typing updates stateManager', (tester) async {
      final sm = BduiStateManager();
      final parser = SchemaParser(stateManager: sm);

      await tester.pumpWidget(_build(
        {'type': 'TextField', 'props': {'stateKey': 'email'}},
        parser: parser,
      ));

      await tester.enterText(find.byType(TextField), 'user@example.com');
      await tester.pump();

      expect(sm.get('email'), 'user@example.com');
    });

    testWidgets('initialises from stateManager when value prop absent', (tester) async {
      final sm = BduiStateManager();
      sm.set('name', 'Prefilled');
      final parser = SchemaParser(stateManager: sm);

      await tester.pumpWidget(_build(
        {'type': 'TextField', 'props': {'stateKey': 'name'}},
        parser: parser,
      ));

      expect(find.text('Prefilled'), findsOneWidget);
    });

    testWidgets('no stateKey — typing does not crash', (tester) async {
      await tester.pumpWidget(_build({'type': 'TextField', 'props': {}}));
      await tester.enterText(find.byType(TextField), 'anything');
      await tester.pump();
    });
  });

  group('stateKey — TextFormField', () {
    testWidgets('typing updates stateManager', (tester) async {
      final sm = BduiStateManager();
      final parser = SchemaParser(stateManager: sm);

      await tester.pumpWidget(_build(
        {'type': 'TextFormField', 'props': {'stateKey': 'username'}},
        parser: parser,
      ));

      await tester.enterText(find.byType(TextFormField), 'charlie');
      await tester.pump();

      expect(sm.get('username'), 'charlie');
    });
  });

  group('stateKey — Switch', () {
    testWidgets('toggling updates stateManager', (tester) async {
      final sm = BduiStateManager();
      final parser = SchemaParser(stateManager: sm);

      await tester.pumpWidget(_build(
        {'type': 'Switch', 'props': {'value': false, 'stateKey': 'rememberMe'}},
        parser: parser,
      ));

      await tester.tap(find.byType(Switch));
      await tester.pump();

      expect(sm.get('rememberMe'), true);
    });
  });

  group('stateKey — Checkbox', () {
    testWidgets('toggling updates stateManager', (tester) async {
      final sm = BduiStateManager();
      final parser = SchemaParser(stateManager: sm);

      await tester.pumpWidget(_build(
        {'type': 'Checkbox', 'props': {'value': false, 'stateKey': 'agreed'}},
        parser: parser,
      ));

      await tester.tap(find.byType(Checkbox));
      await tester.pump();

      expect(sm.get('agreed'), true);
    });
  });

  group('setState action', () {
    testWidgets('ElevatedButton with setState action updates state', (tester) async {
      final sm = BduiStateManager();
      final parser = SchemaParser(stateManager: sm);

      await tester.pumpWidget(_build(
        {
          'type': 'ElevatedButton',
          'props': {'text': 'Press'},
          'action': {'type': 'setState', 'params': {'key': 'clicked', 'value': true}},
        },
        parser: parser,
      ));

      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();

      expect(sm.get('clicked'), true);
    });

    testWidgets('setState with string value', (tester) async {
      final sm = BduiStateManager();
      final parser = SchemaParser(stateManager: sm);

      await tester.pumpWidget(_build(
        {
          'type': 'ElevatedButton',
          'props': {'text': 'Set'},
          'action': {'type': 'setState', 'params': {'key': 'status', 'value': 'active'}},
        },
        parser: parser,
      ));

      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();

      expect(sm.get('status'), 'active');
    });

    testWidgets('setState missing key does not crash', (tester) async {
      await tester.pumpWidget(_build(
        {
          'type': 'ElevatedButton',
          'props': {'text': 'Go'},
          'action': {'type': 'setState', 'params': {'value': 'oops'}},
        },
      ));

      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();
    });
  });

  group('Regression — state binding changes do not affect existing widgets', () {
    testWidgets('Text still renders without animate or stateKey', (tester) async {
      await tester.pumpWidget(_build(
        {'type': 'Text', 'props': {'text': 'Static'}},
      ));
      expect(find.text('Static'), findsOneWidget);
    });

    testWidgets('TextField without stateKey still works', (tester) async {
      await tester.pumpWidget(_build(
        {'type': 'TextField', 'props': {'hint': 'Enter text'}},
      ));
      expect(find.byType(TextField), findsOneWidget);
    });

    testWidgets('Column with children still works', (tester) async {
      await tester.pumpWidget(_build({
        'type': 'Column',
        'children': [
          {'type': 'Text', 'props': {'text': 'A'}},
          {'type': 'Text', 'props': {'text': 'B'}},
        ],
      }));
      expect(find.text('A'), findsOneWidget);
      expect(find.text('B'), findsOneWidget);
    });
  });
}
