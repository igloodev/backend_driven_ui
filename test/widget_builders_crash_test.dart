/// Comprehensive crash-prevention tests for all widget builders.
///
/// Every test verifies that a given JSON schema — with invalid, missing, or
/// boundary-value props — does NOT crash at runtime. These tests directly
/// exercise the assert-guards and safe-cast fixes applied across all builders.
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:backend_driven_ui/backend_driven_ui.dart';

// ─── Helpers ────────────────────────────────────────────────────────────────

/// Parses [json] and renders it inside MaterialApp > Scaffold.
Widget _build(Map<String, dynamic> json) {
  final parser = SchemaParser();
  final schema = WidgetSchema.fromJson(json);
  return MaterialApp(
    home: Scaffold(
      body: Builder(
        builder: (ctx) => parser.parse(schema, ctx),
      ),
    ),
  );
}

/// Same as [_build] but wraps with a [DefaultTabController].
/// Required for TabBar / TabBarView tests that need a controller in scope.
Widget _buildWithTabController(Map<String, dynamic> json, {int length = 2}) {
  final parser = SchemaParser();
  final schema = WidgetSchema.fromJson(json);
  return MaterialApp(
    home: DefaultTabController(
      length: length,
      child: Scaffold(
        body: Builder(
          builder: (ctx) => parser.parse(schema, ctx),
        ),
      ),
    ),
  );
}

// ─── Tests ──────────────────────────────────────────────────────────────────

void main() {
  // ═══════════════════════════════════════════════════════════════════════════
  // LAYOUT BUILDERS
  // ═══════════════════════════════════════════════════════════════════════════

  group('LayoutBuilders — Padding all cases', () {
    testWidgets('no padding prop uses EdgeInsets.zero', (t) async {
      await t.pumpWidget(_build({
        'type': 'Padding',
        'props': {},
        'child': {'type': 'Text', 'props': {'text': 'hi'}},
      }));
      expect(t.takeException(), isNull);
    });

    testWidgets('numeric padding', (t) async {
      await t.pumpWidget(_build({
        'type': 'Padding',
        'props': {'padding': 16},
        'child': {'type': 'Text', 'props': {'text': 'hi'}},
      }));
      expect(t.takeException(), isNull);
    });

    testWidgets('padding with all key', (t) async {
      await t.pumpWidget(_build({
        'type': 'Padding',
        'props': {'padding': {'all': 12}},
        'child': {'type': 'Text', 'props': {'text': 'hi'}},
      }));
      expect(t.takeException(), isNull);
    });

    testWidgets('padding horizontal and vertical', (t) async {
      await t.pumpWidget(_build({
        'type': 'Padding',
        'props': {
          'padding': {'horizontal': 20, 'vertical': 8},
        },
        'child': {'type': 'Text', 'props': {'text': 'hi'}},
      }));
      expect(t.takeException(), isNull);
    });

    testWidgets('padding individual sides', (t) async {
      await t.pumpWidget(_build({
        'type': 'Padding',
        'props': {
          'padding': {'left': 4, 'top': 8, 'right': 4, 'bottom': 16},
        },
        'child': {'type': 'Text', 'props': {'text': 'hi'}},
      }));
      expect(t.takeException(), isNull);
    });

    testWidgets('no child does not crash', (t) async {
      await t.pumpWidget(_build({'type': 'Padding', 'props': {'padding': 8}}));
      expect(t.takeException(), isNull);
    });
  });

  group('LayoutBuilders — Expanded / Flexible / Spacer outside Flex fallback', () {
    testWidgets('Expanded outside Column renders child directly', (t) async {
      await t.pumpWidget(_build({
        'type': 'Container',
        'child': {
          'type': 'Expanded',
          'props': {'flex': 1},
          'child': {'type': 'Text', 'props': {'text': 'hi'}},
        },
      }));
      expect(t.takeException(), isNull);
      expect(find.text('hi'), findsOneWidget);
    });

    testWidgets('Flexible outside Row renders child directly', (t) async {
      await t.pumpWidget(_build({
        'type': 'Container',
        'child': {
          'type': 'Flexible',
          'props': {'flex': 1},
          'child': {'type': 'Text', 'props': {'text': 'hi'}},
        },
      }));
      expect(t.takeException(), isNull);
      expect(find.text('hi'), findsOneWidget);
    });

    testWidgets('Spacer outside Row renders SizedBox.shrink', (t) async {
      await t.pumpWidget(_build({
        'type': 'Container',
        'child': {'type': 'Spacer', 'props': {}},
      }));
      expect(t.takeException(), isNull);
    });

    testWidgets('Expanded at top level renders child directly', (t) async {
      await t.pumpWidget(_build({
        'type': 'Expanded',
        'props': {'flex': 1},
        'child': {'type': 'Text', 'props': {'text': 'top'}},
      }));
      expect(t.takeException(), isNull);
    });
  });

  group('LayoutBuilders — Expanded / Flexible / Spacer flex clamp', () {
    testWidgets('Expanded flex 0 clamped to 1', (t) async {
      await t.pumpWidget(_build({
        'type': 'Column',
        'children': [
          {
            'type': 'Expanded',
            'props': {'flex': 0},
            'child': {'type': 'Text', 'props': {'text': 'a'}},
          },
        ],
      }));
      expect(t.takeException(), isNull);
    });

    testWidgets('Expanded flex -5 clamped to 1', (t) async {
      await t.pumpWidget(_build({
        'type': 'Column',
        'children': [
          {
            'type': 'Expanded',
            'props': {'flex': -5},
            'child': {'type': 'Text', 'props': {'text': 'a'}},
          },
        ],
      }));
      expect(t.takeException(), isNull);
    });

    testWidgets('Expanded flex null defaults to 1', (t) async {
      await t.pumpWidget(_build({
        'type': 'Column',
        'children': [
          {
            'type': 'Expanded',
            'props': {},
            'child': {'type': 'Text', 'props': {'text': 'a'}},
          },
        ],
      }));
      expect(t.takeException(), isNull);
    });

    testWidgets('Flexible flex 0 clamped to 1', (t) async {
      await t.pumpWidget(_build({
        'type': 'Row',
        'children': [
          {
            'type': 'Flexible',
            'props': {'flex': 0},
            'child': {'type': 'Text', 'props': {'text': 'a'}},
          },
        ],
      }));
      expect(t.takeException(), isNull);
    });

    testWidgets('Spacer flex 0 clamped to 1', (t) async {
      await t.pumpWidget(_build({
        'type': 'Row',
        'children': [
          {'type': 'Text', 'props': {'text': 'a'}},
          {'type': 'Spacer', 'props': {'flex': 0}},
          {'type': 'Text', 'props': {'text': 'b'}},
        ],
      }));
      expect(t.takeException(), isNull);
    });
  });

  group('LayoutBuilders — AspectRatio ratio guard', () {
    testWidgets('ratio 0 falls back to 1.0', (t) async {
      await t.pumpWidget(_build({
        'type': 'AspectRatio',
        'props': {'ratio': 0},
        'child': {'type': 'SizedBox', 'props': {}},
      }));
      expect(t.takeException(), isNull);
    });

    testWidgets('ratio negative falls back to 1.0', (t) async {
      await t.pumpWidget(_build({
        'type': 'AspectRatio',
        'props': {'ratio': -3},
        'child': {'type': 'SizedBox', 'props': {}},
      }));
      expect(t.takeException(), isNull);
    });

    testWidgets('ratio null defaults to 1.0', (t) async {
      await t.pumpWidget(_build({
        'type': 'AspectRatio',
        'props': {},
        'child': {'type': 'SizedBox', 'props': {}},
      }));
      expect(t.takeException(), isNull);
    });

    testWidgets('ratio extremely large clamped to 10.0', (t) async {
      await t.pumpWidget(_build({
        'type': 'AspectRatio',
        'props': {'ratio': 999},
        'child': {'type': 'SizedBox', 'props': {}},
      }));
      expect(t.takeException(), isNull);
    });

    testWidgets('ratio valid 16/9 renders correctly', (t) async {
      await t.pumpWidget(_build({
        'type': 'AspectRatio',
        'props': {'ratio': 1.777},
        'child': {'type': 'SizedBox', 'props': {}},
      }));
      expect(t.takeException(), isNull);
    });
  });

  // ═══════════════════════════════════════════════════════════════════════════
  // SCROLLABLE BUILDERS
  // ═══════════════════════════════════════════════════════════════════════════

  group('ScrollableBuilders — ListView', () {
    testWidgets('empty children returns SizedBox', (t) async {
      await t.pumpWidget(_build({'type': 'ListView', 'children': []}));
      expect(t.takeException(), isNull);
    });

    testWidgets('with children renders', (t) async {
      await t.pumpWidget(_build({
        'type': 'ListView',
        'children': [
          {'type': 'Text', 'props': {'text': 'item 1'}},
          {'type': 'Text', 'props': {'text': 'item 2'}},
        ],
      }));
      expect(t.takeException(), isNull);
    });

    testWidgets('ListView.separated empty children', (t) async {
      await t.pumpWidget(_build({'type': 'ListView.separated', 'children': []}));
      expect(t.takeException(), isNull);
    });

    testWidgets('ListView.custom empty children', (t) async {
      await t.pumpWidget(_build({'type': 'ListView.custom', 'children': []}));
      expect(t.takeException(), isNull);
    });

    testWidgets('SingleChildScrollView no child', (t) async {
      await t.pumpWidget(_build({'type': 'SingleChildScrollView', 'props': {}}));
      expect(t.takeException(), isNull);
    });
  });

  group('ScrollableBuilders — GridView assert guards', () {
    testWidgets('GridView crossAxisCount 0 clamped to 1', (t) async {
      await t.pumpWidget(_build({
        'type': 'GridView',
        'props': {'crossAxisCount': 0},
        'children': [{'type': 'Text', 'props': {'text': 'item'}}],
      }));
      expect(t.takeException(), isNull);
    });

    testWidgets('GridView crossAxisCount negative clamped to 1', (t) async {
      await t.pumpWidget(_build({
        'type': 'GridView',
        'props': {'crossAxisCount': -2},
        'children': [{'type': 'Text', 'props': {'text': 'item'}}],
      }));
      expect(t.takeException(), isNull);
    });

    testWidgets('GridView childAspectRatio 0 clamped to 0.01', (t) async {
      await t.pumpWidget(_build({
        'type': 'GridView',
        'props': {'crossAxisCount': 2, 'childAspectRatio': 0},
        'children': [{'type': 'Text', 'props': {'text': 'item'}}],
      }));
      expect(t.takeException(), isNull);
    });

    testWidgets('GridView childAspectRatio negative clamped', (t) async {
      await t.pumpWidget(_build({
        'type': 'GridView',
        'props': {'crossAxisCount': 2, 'childAspectRatio': -1},
        'children': [{'type': 'Text', 'props': {'text': 'item'}}],
      }));
      expect(t.takeException(), isNull);
    });

    testWidgets('GridView empty children', (t) async {
      await t.pumpWidget(_build({
        'type': 'GridView',
        'props': {'crossAxisCount': 2},
        'children': [],
      }));
      expect(t.takeException(), isNull);
    });

    testWidgets('GridView.count crossAxisCount 0 clamped to 1', (t) async {
      await t.pumpWidget(_build({
        'type': 'GridView.count',
        'props': {'crossAxisCount': 0},
        'children': [{'type': 'Text', 'props': {'text': 'item'}}],
      }));
      expect(t.takeException(), isNull);
    });

    testWidgets('GridView.extent maxCrossAxisExtent 0 clamped to 0.1', (t) async {
      await t.pumpWidget(_build({
        'type': 'GridView.extent',
        'props': {'maxCrossAxisExtent': 0},
        'children': [{'type': 'Text', 'props': {'text': 'item'}}],
      }));
      expect(t.takeException(), isNull);
    });

    testWidgets('GridView.custom crossAxisCount 0 clamped to 1', (t) async {
      await t.pumpWidget(_build({
        'type': 'GridView.custom',
        'props': {'crossAxisCount': 0},
        'children': [{'type': 'Text', 'props': {'text': 'item'}}],
      }));
      expect(t.takeException(), isNull);
    });

    testWidgets('GridView.custom maxCrossAxisExtent 0 clamped to 0.1', (t) async {
      await t.pumpWidget(_build({
        'type': 'GridView.custom',
        'props': {'maxCrossAxisExtent': 0},
        'children': [{'type': 'Text', 'props': {'text': 'item'}}],
      }));
      expect(t.takeException(), isNull);
    });
  });

  // ═══════════════════════════════════════════════════════════════════════════
  // EFFECTS BUILDERS
  // ═══════════════════════════════════════════════════════════════════════════

  group('EffectsBuilders — Opacity clamp guard', () {
    testWidgets('opacity 1.5 clamped to 1.0', (t) async {
      await t.pumpWidget(_build({
        'type': 'Opacity',
        'props': {'opacity': 1.5},
        'child': {'type': 'Text', 'props': {'text': 'hi'}},
      }));
      expect(t.takeException(), isNull);
    });

    testWidgets('opacity -0.5 clamped to 0.0', (t) async {
      await t.pumpWidget(_build({
        'type': 'Opacity',
        'props': {'opacity': -0.5},
        'child': {'type': 'Text', 'props': {'text': 'hi'}},
      }));
      expect(t.takeException(), isNull);
    });

    testWidgets('opacity null defaults to 1.0', (t) async {
      await t.pumpWidget(_build({
        'type': 'Opacity',
        'props': {},
        'child': {'type': 'Text', 'props': {'text': 'hi'}},
      }));
      expect(t.takeException(), isNull);
    });

    testWidgets('opacity 0.0 valid boundary', (t) async {
      await t.pumpWidget(_build({
        'type': 'Opacity',
        'props': {'opacity': 0},
        'child': {'type': 'Text', 'props': {'text': 'hi'}},
      }));
      expect(t.takeException(), isNull);
    });

    testWidgets('opacity 1.0 valid boundary', (t) async {
      await t.pumpWidget(_build({
        'type': 'Opacity',
        'props': {'opacity': 1},
        'child': {'type': 'Text', 'props': {'text': 'hi'}},
      }));
      expect(t.takeException(), isNull);
    });
  });

  group('EffectsBuilders — Visibility cascade guard', () {
    testWidgets('maintainSize true forces maintainAnimation and maintainState', (t) async {
      await t.pumpWidget(_build({
        'type': 'Visibility',
        'props': {
          'visible': true,
          'maintainSize': true,
          'maintainAnimation': false, // would violate assert without cascade
          'maintainState': false,     // same
        },
        'child': {'type': 'Text', 'props': {'text': 'hi'}},
      }));
      expect(t.takeException(), isNull);
    });

    testWidgets('all props false — valid', (t) async {
      await t.pumpWidget(_build({
        'type': 'Visibility',
        'props': {
          'maintainSize': false,
          'maintainAnimation': false,
          'maintainState': false,
        },
        'child': {'type': 'Text', 'props': {'text': 'hi'}},
      }));
      expect(t.takeException(), isNull);
    });

    testWidgets('visible false does not crash', (t) async {
      await t.pumpWidget(_build({
        'type': 'Visibility',
        'props': {'visible': false},
        'child': {'type': 'Text', 'props': {'text': 'hi'}},
      }));
      expect(t.takeException(), isNull);
    });

    testWidgets('no props uses all defaults', (t) async {
      await t.pumpWidget(_build({
        'type': 'Visibility',
        'props': {},
        'child': {'type': 'Text', 'props': {'text': 'hi'}},
      }));
      expect(t.takeException(), isNull);
    });

    testWidgets('all maintainX true — valid', (t) async {
      await t.pumpWidget(_build({
        'type': 'Visibility',
        'props': {
          'maintainSize': true,
          'maintainAnimation': true,
          'maintainState': true,
        },
        'child': {'type': 'Text', 'props': {'text': 'hi'}},
      }));
      expect(t.takeException(), isNull);
    });
  });

  // ═══════════════════════════════════════════════════════════════════════════
  // SLIVER BUILDERS
  // ═══════════════════════════════════════════════════════════════════════════

  group('SliverBuilders — assert guards', () {
    testWidgets('SliverFixedExtentList itemExtent 0 clamped to 0.1', (t) async {
      await t.pumpWidget(_build({
        'type': 'CustomScrollView',
        'children': [
          {
            'type': 'SliverFixedExtentList',
            'props': {'itemExtent': 0},
            'children': [{'type': 'Text', 'props': {'text': 'item'}}],
          },
        ],
      }));
      expect(t.takeException(), isNull);
    });

    testWidgets('SliverFixedExtentList itemExtent negative clamped', (t) async {
      await t.pumpWidget(_build({
        'type': 'CustomScrollView',
        'children': [
          {
            'type': 'SliverFixedExtentList',
            'props': {'itemExtent': -10},
            'children': [{'type': 'Text', 'props': {'text': 'item'}}],
          },
        ],
      }));
      expect(t.takeException(), isNull);
    });

    testWidgets('SliverGrid crossAxisCount 0 clamped to 1', (t) async {
      await t.pumpWidget(_build({
        'type': 'CustomScrollView',
        'children': [
          {
            'type': 'SliverGrid',
            'props': {'crossAxisCount': 0},
            'children': [{'type': 'Text', 'props': {'text': 'item'}}],
          },
        ],
      }));
      expect(t.takeException(), isNull);
    });

    testWidgets('SliverGrid childAspectRatio 0 clamped to 0.01', (t) async {
      await t.pumpWidget(_build({
        'type': 'CustomScrollView',
        'children': [
          {
            'type': 'SliverGrid',
            'props': {'crossAxisCount': 2, 'childAspectRatio': 0},
            'children': [{'type': 'Text', 'props': {'text': 'item'}}],
          },
        ],
      }));
      expect(t.takeException(), isNull);
    });

    testWidgets('SliverGrid maxCrossAxisExtent 0 clamped to 0.1', (t) async {
      await t.pumpWidget(_build({
        'type': 'CustomScrollView',
        'children': [
          {
            'type': 'SliverGrid',
            'props': {'maxCrossAxisExtent': 0},
            'children': [{'type': 'Text', 'props': {'text': 'item'}}],
          },
        ],
      }));
      expect(t.takeException(), isNull);
    });

    testWidgets('SliverAppBar snap true without floating does not assert', (t) async {
      await t.pumpWidget(_build({
        'type': 'CustomScrollView',
        'children': [
          {
            'type': 'SliverAppBar',
            'props': {'title': 'Test', 'snap': true, 'floating': false},
          },
          {
            'type': 'SliverToBoxAdapter',
            'child': {'type': 'SizedBox', 'props': {'height': 100}},
          },
        ],
      }));
      expect(t.takeException(), isNull);
    });

    testWidgets('SliverList empty children no crash', (t) async {
      await t.pumpWidget(_build({
        'type': 'CustomScrollView',
        'children': [
          {'type': 'SliverList', 'children': []},
        ],
      }));
      expect(t.takeException(), isNull);
    });

    testWidgets('SliverToBoxAdapter no child no crash', (t) async {
      await t.pumpWidget(_build({
        'type': 'CustomScrollView',
        'children': [
          {'type': 'SliverToBoxAdapter'},
        ],
      }));
      expect(t.takeException(), isNull);
    });

    testWidgets('SliverPadding no padding uses EdgeInsets.zero', (t) async {
      await t.pumpWidget(_build({
        'type': 'CustomScrollView',
        'children': [
          {
            'type': 'SliverPadding',
            'props': {},
            'child': {
              'type': 'SliverToBoxAdapter',
              'child': {'type': 'Text', 'props': {'text': 'hi'}},
            },
          },
        ],
      }));
      expect(t.takeException(), isNull);
    });

    testWidgets('SliverFillRemaining no child no crash', (t) async {
      await t.pumpWidget(_build({
        'type': 'CustomScrollView',
        'children': [
          {'type': 'SliverFillRemaining', 'props': {}},
        ],
      }));
      expect(t.takeException(), isNull);
    });
  });

  // ═══════════════════════════════════════════════════════════════════════════
  // NAVIGATION BUILDERS
  // ═══════════════════════════════════════════════════════════════════════════

  group('NavigationBuilders — BottomNavigationBar item count guard', () {
    testWidgets('0 items returns SizedBox', (t) async {
      await t.pumpWidget(_build({'type': 'BottomNavigationBar', 'children': []}));
      expect(t.takeException(), isNull);
    });

    testWidgets('1 item returns SizedBox', (t) async {
      await t.pumpWidget(_build({
        'type': 'BottomNavigationBar',
        'children': [
          {'type': 'Item', 'props': {'icon': 'home', 'label': 'Home'}},
        ],
      }));
      expect(t.takeException(), isNull);
    });

    testWidgets('2 items renders correctly', (t) async {
      await t.pumpWidget(_build({
        'type': 'BottomNavigationBar',
        'children': [
          {'type': 'Item', 'props': {'icon': 'home', 'label': 'Home'}},
          {'type': 'Item', 'props': {'icon': 'search', 'label': 'Search'}},
        ],
      }));
      expect(t.takeException(), isNull);
    });

    testWidgets('3 items with unknown icon falls back gracefully', (t) async {
      await t.pumpWidget(_build({
        'type': 'BottomNavigationBar',
        'children': [
          {'type': 'Item', 'props': {'icon': 'home', 'label': 'Home'}},
          {'type': 'Item', 'props': {'icon': 'search', 'label': 'Search'}},
          {'type': 'Item', 'props': {'icon': 'xyz_unknown', 'label': 'More'}},
        ],
      }));
      expect(t.takeException(), isNull);
    });
  });

  group('NavigationBuilders — TabBar guard', () {
    testWidgets('empty tabs returns SizedBox', (t) async {
      await t.pumpWidget(_build({'type': 'TabBar', 'children': []}));
      expect(t.takeException(), isNull);
    });

    testWidgets('indicatorWeight 0 clamped to 0.1', (t) async {
      await t.pumpWidget(_buildWithTabController({
        'type': 'TabBar',
        'props': {'indicatorWeight': 0},
        'children': [
          {'type': 'Tab', 'props': {'text': 'A'}},
          {'type': 'Tab', 'props': {'text': 'B'}},
        ],
      }));
      expect(t.takeException(), isNull);
    });

    testWidgets('indicatorWeight negative clamped to 0.1', (t) async {
      await t.pumpWidget(_buildWithTabController({
        'type': 'TabBar',
        'props': {'indicatorWeight': -5},
        'children': [
          {'type': 'Tab', 'props': {'text': 'A'}},
          {'type': 'Tab', 'props': {'text': 'B'}},
        ],
      }));
      expect(t.takeException(), isNull);
    });

    testWidgets('valid 2 tabs renders', (t) async {
      await t.pumpWidget(_buildWithTabController({
        'type': 'TabBar',
        'children': [
          {'type': 'Tab', 'props': {'text': 'Home'}},
          {'type': 'Tab', 'props': {'text': 'Search'}},
        ],
      }));
      expect(t.takeException(), isNull);
    });
  });

  group('NavigationBuilders — DefaultTabController length guard', () {
    testWidgets('length 0 clamped to 1', (t) async {
      await t.pumpWidget(_build({
        'type': 'DefaultTabController',
        'props': {'length': 0},
        'child': {'type': 'SizedBox', 'props': {}},
      }));
      expect(t.takeException(), isNull);
    });

    testWidgets('length negative clamped to 1', (t) async {
      await t.pumpWidget(_build({
        'type': 'DefaultTabController',
        'props': {'length': -1},
        'child': {'type': 'SizedBox', 'props': {}},
      }));
      expect(t.takeException(), isNull);
    });

    testWidgets('length null defaults to 1', (t) async {
      await t.pumpWidget(_build({
        'type': 'DefaultTabController',
        'props': {},
        'child': {'type': 'SizedBox', 'props': {}},
      }));
      expect(t.takeException(), isNull);
    });

    testWidgets('initialIndex out of range clamped', (t) async {
      await t.pumpWidget(_build({
        'type': 'DefaultTabController',
        'props': {'length': 2, 'initialIndex': 99},
        'child': {'type': 'SizedBox', 'props': {}},
      }));
      expect(t.takeException(), isNull);
    });
  });

  group('NavigationBuilders — NavigationBar and TabBarView guards', () {
    testWidgets('NavigationBar empty destinations returns SizedBox', (t) async {
      await t.pumpWidget(_build({'type': 'NavigationBar', 'children': []}));
      expect(t.takeException(), isNull);
    });

    testWidgets('NavigationBar 2 destinations renders', (t) async {
      await t.pumpWidget(_build({
        'type': 'NavigationBar',
        'children': [
          {'type': 'Dest', 'props': {'icon': 'home', 'label': 'Home'}},
          {'type': 'Dest', 'props': {'icon': 'search', 'label': 'Search'}},
        ],
      }));
      expect(t.takeException(), isNull);
    });

    testWidgets('TabBarView empty views returns SizedBox', (t) async {
      await t.pumpWidget(_build({'type': 'TabBarView', 'children': []}));
      expect(t.takeException(), isNull);
    });
  });

  // ═══════════════════════════════════════════════════════════════════════════
  // INPUT BUILDERS
  // ═══════════════════════════════════════════════════════════════════════════

  group('InputBuilders — obscureText + maxLines guard', () {
    testWidgets('TextField obscureText true with maxLines 5 forces maxLines 1', (t) async {
      await t.pumpWidget(_build({
        'type': 'TextField',
        'props': {'obscureText': true, 'maxLines': 5},
      }));
      expect(t.takeException(), isNull);
    });

    testWidgets('TextField obscureText true maxLines 1 is valid', (t) async {
      await t.pumpWidget(_build({
        'type': 'TextField',
        'props': {'obscureText': true, 'maxLines': 1},
      }));
      expect(t.takeException(), isNull);
    });

    testWidgets('TextField no props no crash', (t) async {
      await t.pumpWidget(_build({'type': 'TextField', 'props': {}}));
      expect(t.takeException(), isNull);
    });

    testWidgets('TextFormField obscureText true with maxLines 3 forces maxLines 1', (t) async {
      await t.pumpWidget(_build({
        'type': 'TextFormField',
        'props': {'obscureText': true, 'maxLines': 3},
      }));
      expect(t.takeException(), isNull);
    });

    testWidgets('TextFormField no props no crash', (t) async {
      await t.pumpWidget(_build({'type': 'TextFormField', 'props': {}}));
      expect(t.takeException(), isNull);
    });

    testWidgets('Switch no props no crash', (t) async {
      await t.pumpWidget(_build({'type': 'Switch', 'props': {}}));
      expect(t.takeException(), isNull);
    });

    testWidgets('Checkbox no props no crash', (t) async {
      await t.pumpWidget(_build({'type': 'Checkbox', 'props': {}}));
      expect(t.takeException(), isNull);
    });
  });

  // ═══════════════════════════════════════════════════════════════════════════
  // MATERIAL BUILDERS
  // ═══════════════════════════════════════════════════════════════════════════

  group('MaterialBuilders — ListTile isThreeLine guard', () {
    testWidgets('isThreeLine true without subtitle does not crash', (t) async {
      await t.pumpWidget(_build({
        'type': 'ListTile',
        'props': {'title': 'Title', 'isThreeLine': true},
      }));
      expect(t.takeException(), isNull);
    });

    testWidgets('isThreeLine true with subtitle is valid', (t) async {
      await t.pumpWidget(_build({
        'type': 'ListTile',
        'props': {'title': 'Title', 'subtitle': 'Sub', 'isThreeLine': true},
      }));
      expect(t.takeException(), isNull);
    });

    testWidgets('no props no crash', (t) async {
      await t.pumpWidget(_build({'type': 'ListTile', 'props': {}}));
      expect(t.takeException(), isNull);
    });
  });

  group('MaterialBuilders — general no crash', () {
    testWidgets('Card no props', (t) async {
      await t.pumpWidget(_build({'type': 'Card', 'props': {}}));
      expect(t.takeException(), isNull);
    });

    testWidgets('Chip no props', (t) async {
      await t.pumpWidget(_build({'type': 'Chip', 'props': {}}));
      expect(t.takeException(), isNull);
    });

    testWidgets('CircleAvatar no props', (t) async {
      await t.pumpWidget(_build({'type': 'CircleAvatar', 'props': {}}));
      expect(t.takeException(), isNull);
    });
  });

  // ═══════════════════════════════════════════════════════════════════════════
  // DISPLAY BUILDERS
  // ═══════════════════════════════════════════════════════════════════════════

  group('DisplayBuilders — no crash', () {
    testWidgets('Text no props renders empty string', (t) async {
      await t.pumpWidget(_build({'type': 'Text', 'props': {}}));
      expect(t.takeException(), isNull);
    });

    testWidgets('Text with content renders correctly', (t) async {
      await t.pumpWidget(_build({'type': 'Text', 'props': {'text': 'Hello'}}));
      expect(t.takeException(), isNull);
      expect(find.text('Hello'), findsOneWidget);
    });

    testWidgets('Icon no props no crash', (t) async {
      await t.pumpWidget(_build({'type': 'Icon', 'props': {}}));
      expect(t.takeException(), isNull);
    });

    testWidgets('Icon unknown name falls back to help_outline', (t) async {
      await t.pumpWidget(
        _build({'type': 'Icon', 'props': {'icon': 'totally_unknown_xyz'}}),
      );
      expect(t.takeException(), isNull);
    });

    testWidgets('CircularProgressIndicator no props', (t) async {
      await t.pumpWidget(_build({'type': 'CircularProgressIndicator', 'props': {}}));
      expect(t.takeException(), isNull);
    });

    testWidgets('LinearProgressIndicator no props', (t) async {
      await t.pumpWidget(_build({'type': 'LinearProgressIndicator', 'props': {}}));
      expect(t.takeException(), isNull);
    });

    testWidgets('Divider no props', (t) async {
      await t.pumpWidget(_build({'type': 'Divider', 'props': {}}));
      expect(t.takeException(), isNull);
    });
  });

  // ═══════════════════════════════════════════════════════════════════════════
  // INTERACTIVE BUILDERS
  // ═══════════════════════════════════════════════════════════════════════════

  group('InteractiveBuilders — no crash', () {
    testWidgets('ElevatedButton no props', (t) async {
      await t.pumpWidget(_build({'type': 'ElevatedButton', 'props': {}}));
      expect(t.takeException(), isNull);
    });

    testWidgets('ElevatedButton with text', (t) async {
      await t.pumpWidget(_build({'type': 'ElevatedButton', 'props': {'text': 'Click'}}));
      expect(t.takeException(), isNull);
    });

    testWidgets('TextButton no props', (t) async {
      await t.pumpWidget(_build({'type': 'TextButton', 'props': {}}));
      expect(t.takeException(), isNull);
    });

    testWidgets('OutlinedButton no props', (t) async {
      await t.pumpWidget(_build({'type': 'OutlinedButton', 'props': {}}));
      expect(t.takeException(), isNull);
    });

    testWidgets('IconButton unknown icon falls back', (t) async {
      await t.pumpWidget(_build({'type': 'IconButton', 'props': {'icon': 'xyz_unknown'}}));
      expect(t.takeException(), isNull);
    });

    testWidgets('GestureDetector no child', (t) async {
      await t.pumpWidget(_build({'type': 'GestureDetector', 'props': {}}));
      expect(t.takeException(), isNull);
    });

    testWidgets('InkWell no child', (t) async {
      await t.pumpWidget(_build({'type': 'InkWell', 'props': {}}));
      expect(t.takeException(), isNull);
    });
  });

  // ═══════════════════════════════════════════════════════════════════════════
  // SCHEMA PARSER — fallback + depth guard
  // ═══════════════════════════════════════════════════════════════════════════

  group('SchemaParser — unknown widget fallback', () {
    testWidgets('unknown type shows fallback without crashing', (t) async {
      await t.pumpWidget(_build({'type': 'CompletelyUnknownWidget123', 'props': {}}));
      expect(t.takeException(), isNull);
    });

    testWidgets('unknown type with children shows fallback', (t) async {
      await t.pumpWidget(_build({
        'type': 'UnknownParent',
        'children': [
          {'type': 'Text', 'props': {'text': 'visible child'}},
        ],
      }));
      expect(t.takeException(), isNull);
    });
  });

  // ═══════════════════════════════════════════════════════════════════════════
  // MODEL SAFE-CAST GUARDS (unit tests — no widget pump needed)
  // ═══════════════════════════════════════════════════════════════════════════

  group('WidgetSchema — condition safe casting', () {
    test('condition bool true converts to "true"', () {
      final schema = WidgetSchema.fromJson({
        'type': 'Text',
        'condition': true,
        'props': {'text': 'hi'},
      });
      expect(schema.condition, 'true');
    });

    test('condition int 1 converts to "1"', () {
      final schema = WidgetSchema.fromJson({
        'type': 'Text',
        'condition': 1,
        'props': {'text': 'hi'},
      });
      expect(schema.condition, '1');
    });

    test('condition string passes through unchanged', () {
      final schema = WidgetSchema.fromJson({
        'type': 'Text',
        'condition': 'isLoggedIn',
        'props': {'text': 'hi'},
      });
      expect(schema.condition, 'isLoggedIn');
    });

    test('condition null stays null', () {
      final schema = WidgetSchema.fromJson({'type': 'Text', 'props': {}});
      expect(schema.condition, isNull);
    });
  });

  group('ActionSchema — unsafe cast guards', () {
    test('params as non-map string does not crash', () {
      final schema = ActionSchema.fromJson({
        'type': 'navigate',
        'params': 'not_a_map',
        'route': '/home',
      });
      expect(schema.type, 'navigate');
      expect(schema.route, '/home');
    });

    test('condition bool true converts to "true"', () {
      final schema = ActionSchema.fromJson({
        'type': 'navigate',
        'condition': true,
        'route': '/home',
      });
      expect(schema.condition, 'true');
    });

    test('condition int converts to string', () {
      final schema = ActionSchema.fromJson({
        'type': 'navigate',
        'condition': 0,
        'route': '/home',
      });
      expect(schema.condition, '0');
    });

    test('route as int converts to string', () {
      final schema = ActionSchema.fromJson({'type': 'navigate', 'route': 123});
      expect(schema.route, '123');
    });

    test('endpoint as int converts to string', () {
      final schema = ActionSchema.fromJson({'type': 'api', 'endpoint': 42});
      expect(schema.endpoint, '42');
    });

    test('method as int converts to string', () {
      final schema = ActionSchema.fromJson({'type': 'api', 'method': 1});
      expect(schema.method, '1');
    });

    test('condition null stays null', () {
      final schema = ActionSchema.fromJson({'type': 'navigate', 'route': '/x'});
      expect(schema.condition, isNull);
    });
  });
}
