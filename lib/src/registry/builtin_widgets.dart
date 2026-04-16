import 'package:flutter/material.dart';

import '../models/widget_schema.dart';
import '../parser/schema_parser.dart';
import 'builders/display_builders.dart';
import 'builders/effects_builders.dart';
import 'builders/interactive_builders.dart';
import 'builders/layout_builders.dart';
import 'builders/material_builders.dart';
import 'builders/scrollable_builders.dart';

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
      // Display
      'Text':    (s, c) => DisplayBuilders.buildText(s, c),
      'Icon':    (s, c) => DisplayBuilders.buildIcon(s, c),
      'Image':   (s, c) => DisplayBuilders.buildImage(s, c),
      'Divider': (s, c) => DisplayBuilders.buildDivider(s, c),

      // Layout
      'Container':   (s, c) => LayoutBuilders.buildContainer(s, c, parser),
      'Column':      (s, c) => LayoutBuilders.buildColumn(s, c, parser),
      'Row':         (s, c) => LayoutBuilders.buildRow(s, c, parser),
      'Stack':       (s, c) => LayoutBuilders.buildStack(s, c, parser),
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
      'ClipRRect':    (s, c) => MaterialBuilders.buildClipRRect(s, c, parser),

      // Interactive
      'Button':          (s, c) => InteractiveBuilders.buildButton(s, c, parser),
      'ElevatedButton':  (s, c) => InteractiveBuilders.buildButton(s, c, parser, buttonType: 'elevated'),
      'TextButton':      (s, c) => InteractiveBuilders.buildButton(s, c, parser, buttonType: 'text'),
      'OutlinedButton':  (s, c) => InteractiveBuilders.buildButton(s, c, parser, buttonType: 'outlined'),
      'IconButton':      (s, c) => InteractiveBuilders.buildIconButton(s, c, parser),
      'GestureDetector': (s, c) => InteractiveBuilders.buildGestureDetector(s, c, parser),
      'InkWell':         (s, c) => InteractiveBuilders.buildInkWell(s, c, parser),

      // Scrollable
      'ListView':               (s, c) => ScrollableBuilders.buildListView(s, c, parser),
      'GridView':               (s, c) => ScrollableBuilders.buildGridView(s, c, parser),
      'SingleChildScrollView':  (s, c) => ScrollableBuilders.buildSingleChildScrollView(s, c, parser),

      // Effects
      'Visibility': (s, c) => EffectsBuilders.buildVisibility(s, c, parser),
      'Opacity':    (s, c) => EffectsBuilders.buildOpacity(s, c, parser),
    };
  }
}
