import 'package:flutter/material.dart';

import '../models/widget_schema.dart';
import '../parser/schema_parser.dart';
import 'builders/display_builders.dart';
import 'builders/effects_builders.dart';
import 'builders/interactive_builders.dart';
import 'builders/layout_builders.dart';
import 'builders/material_builders.dart';
import 'builders/input_builders.dart';
import 'builders/navigation_builders.dart';
import 'builders/scaffold_builders.dart';
import 'builders/scrollable_builders.dart';
import 'builders/sliver_builders.dart';

/// Registers all built-in widget builders with the [SchemaParser].
///
/// Each entry maps a JSON `type` string to a builder function.
/// Add new built-in widget types here; implement their builders in the
/// appropriate file under `registry/builders/`.
class BuiltinWidgets {
  static Map<String, Widget Function(WidgetSchema, BuildContext)> getBuilders(
    SchemaParser parser,
  ) {
    return {
      // Scaffold
      'Scaffold':  (s, c) => ScaffoldBuilders.buildScaffold(s, c, parser),
      'AppBar':    (s, c) => ScaffoldBuilders.buildAppBar(s, c, parser),
      'SafeArea':  (s, c) => ScaffoldBuilders.buildSafeArea(s, c, parser),

      // Display
      'Text':                        (s, c) => DisplayBuilders.buildText(s, c),
      'Icon':                        (s, c) => DisplayBuilders.buildIcon(s, c),
      'Image':                       (s, c) => DisplayBuilders.buildImage(s, c),
      'Divider':                     (s, c) => DisplayBuilders.buildDivider(s, c),
      'CircularProgressIndicator':   (s, c) => DisplayBuilders.buildCircularProgressIndicator(s, c),
      'LinearProgressIndicator':     (s, c) => DisplayBuilders.buildLinearProgressIndicator(s, c),

      // Layout
      'Container':   (s, c) => LayoutBuilders.buildContainer(s, c, parser),
      'Column':      (s, c) => LayoutBuilders.buildColumn(s, c, parser),
      'Row':         (s, c) => LayoutBuilders.buildRow(s, c, parser),
      'Stack':       (s, c) => LayoutBuilders.buildStack(s, c, parser),
      'Positioned':  (s, c) => LayoutBuilders.buildPositioned(s, c, parser),
      'Padding':     (s, c) => LayoutBuilders.buildPadding(s, c, parser),
      'Center':      (s, c) => LayoutBuilders.buildCenter(s, c, parser),
      'SizedBox':    (s, c) => LayoutBuilders.buildSizedBox(s, c, parser),
      'Expanded':    (s, c) => LayoutBuilders.buildExpanded(s, c, parser),
      'Flexible':    (s, c) => LayoutBuilders.buildFlexible(s, c, parser),
      'Wrap':        (s, c) => LayoutBuilders.buildWrap(s, c, parser),
      'Spacer':      (s, c) => LayoutBuilders.buildSpacer(s, c),
      'AspectRatio': (s, c) => LayoutBuilders.buildAspectRatio(s, c, parser),

      // Material
      'Card':         (s, c) => MaterialBuilders.buildCard(s, c, parser),
      'ListTile':     (s, c) => MaterialBuilders.buildListTile(s, c, parser),
      'CircleAvatar': (s, c) => MaterialBuilders.buildCircleAvatar(s, c, parser),
      'Chip':         (s, c) => MaterialBuilders.buildChip(s, c),
      'ClipRRect':               (s, c) => MaterialBuilders.buildClipRRect(s, c, parser),
      'FloatingActionButton':    (s, c) => MaterialBuilders.buildFloatingActionButton(s, c, parser),
      'ExpansionTile':           (s, c) => MaterialBuilders.buildExpansionTile(s, c, parser),

      // Input
      'TextField':     (s, c) => InputBuilders.buildTextField(s, c, parser),
      'TextFormField': (s, c) => InputBuilders.buildTextFormField(s, c, parser),
      'Switch':        (s, c) => InputBuilders.buildSwitch(s, c, parser),
      'Checkbox':      (s, c) => InputBuilders.buildCheckbox(s, c, parser),

      // Interactive
      'Button':          (s, c) => InteractiveBuilders.buildButton(s, c, parser),
      'ElevatedButton':  (s, c) => InteractiveBuilders.buildButton(s, c, parser, buttonType: 'elevated'),
      'TextButton':      (s, c) => InteractiveBuilders.buildButton(s, c, parser, buttonType: 'text'),
      'OutlinedButton':  (s, c) => InteractiveBuilders.buildButton(s, c, parser, buttonType: 'outlined'),
      'IconButton':      (s, c) => InteractiveBuilders.buildIconButton(s, c, parser),
      'GestureDetector': (s, c) => InteractiveBuilders.buildGestureDetector(s, c, parser),
      'InkWell':         (s, c) => InteractiveBuilders.buildInkWell(s, c, parser),

      // Scrollable — ListView variants
      'ListView':               (s, c) => ScrollableBuilders.buildListView(s, c, parser),
      'ListView.builder':       (s, c) => ScrollableBuilders.buildListView(s, c, parser),
      'ListView.separated':     (s, c) => ScrollableBuilders.buildListViewSeparated(s, c, parser),
      'ListView.custom':        (s, c) => ScrollableBuilders.buildListViewCustom(s, c, parser),

      // Scrollable — GridView variants
      'GridView':               (s, c) => ScrollableBuilders.buildGridView(s, c, parser),
      'GridView.builder':       (s, c) => ScrollableBuilders.buildGridView(s, c, parser),
      'GridView.count':         (s, c) => ScrollableBuilders.buildGridViewCount(s, c, parser),
      'GridView.extent':        (s, c) => ScrollableBuilders.buildGridViewExtent(s, c, parser),
      'GridView.custom':        (s, c) => ScrollableBuilders.buildGridViewCustom(s, c, parser),

      'SingleChildScrollView':  (s, c) => ScrollableBuilders.buildSingleChildScrollView(s, c, parser),

      // Slivers
      'CustomScrollView':       (s, c) => SliverBuilders.buildCustomScrollView(s, c, parser),
      'SliverAppBar':           (s, c) => SliverBuilders.buildSliverAppBar(s, c, parser),
      'SliverList':             (s, c) => SliverBuilders.buildSliverList(s, c, parser),
      'SliverGrid':             (s, c) => SliverBuilders.buildSliverGrid(s, c, parser),
      'SliverToBoxAdapter':     (s, c) => SliverBuilders.buildSliverToBoxAdapter(s, c, parser),
      'SliverPadding':          (s, c) => SliverBuilders.buildSliverPadding(s, c, parser),
      'SliverFillRemaining':    (s, c) => SliverBuilders.buildSliverFillRemaining(s, c, parser),
      'SliverFixedExtentList':  (s, c) => SliverBuilders.buildSliverFixedExtentList(s, c, parser),

      // Navigation
      'BottomNavigationBar':    (s, c) => NavigationBuilders.buildBottomNavigationBar(s, c, parser),
      'NavigationBar':          (s, c) => NavigationBuilders.buildNavigationBar(s, c, parser),
      'DefaultTabController':   (s, c) => NavigationBuilders.buildDefaultTabController(s, c, parser),
      'TabBar':                 (s, c) => NavigationBuilders.buildTabBar(s, c, parser),
      'TabBarView':             (s, c) => NavigationBuilders.buildTabBarView(s, c, parser),

      // Effects
      'Visibility': (s, c) => EffectsBuilders.buildVisibility(s, c, parser),
      'Opacity':    (s, c) => EffectsBuilders.buildOpacity(s, c, parser),
    };
  }
}
