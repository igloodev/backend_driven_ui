import 'package:flutter/material.dart';

import '../../models/widget_schema.dart';
import '../../parser/schema_parser.dart';
import '../../utils/schema_converters.dart';

/// Builders for scrollable widgets: ListView, GridView, SingleChildScrollView.
class ScrollableBuilders {
  static Widget buildListView(
    WidgetSchema schema,
    BuildContext context,
    SchemaParser parser,
  ) {
    final props = schema.props ?? {};
    final children = schema.children;

    if (children == null || children.isEmpty) return const SizedBox.shrink();

    return ListView.builder(
      shrinkWrap: props['shrinkWrap'] as bool? ?? false,
      physics: props['physics'] == 'never' ? const NeverScrollableScrollPhysics() : null,
      padding: SchemaConverters.toEdgeInsets(props['padding']),
      itemCount: children.length,
      itemBuilder: (context, index) {
        final child = children[index];
        final itemKey = child.props?['id']?.toString() ?? 'item_$index';
        return KeyedSubtree(
          key: ValueKey(itemKey),
          child: parser.parse(child, context),
        );
      },
    );
  }

  static Widget buildGridView(
    WidgetSchema schema,
    BuildContext context,
    SchemaParser parser,
  ) {
    final props = schema.props ?? {};
    final children = schema.children;
    final crossAxisCount = props['crossAxisCount'] as int? ?? 2;

    if (children == null || children.isEmpty) return const SizedBox.shrink();

    return GridView.builder(
      shrinkWrap: props['shrinkWrap'] as bool? ?? false,
      physics: props['physics'] == 'never' ? const NeverScrollableScrollPhysics() : null,
      padding: SchemaConverters.toEdgeInsets(props['padding']),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        mainAxisSpacing: SchemaConverters.toDouble(props['mainAxisSpacing']) ?? 0.0,
        crossAxisSpacing: SchemaConverters.toDouble(props['crossAxisSpacing']) ?? 0.0,
        childAspectRatio: SchemaConverters.toDouble(props['childAspectRatio']) ?? 1.0,
      ),
      itemCount: children.length,
      itemBuilder: (context, index) {
        final child = children[index];
        final itemKey = child.props?['id']?.toString() ?? 'grid_$index';
        return KeyedSubtree(
          key: ValueKey(itemKey),
          child: parser.parse(child, context),
        );
      },
    );
  }

  static Widget buildSingleChildScrollView(
    WidgetSchema schema,
    BuildContext context,
    SchemaParser parser,
  ) {
    final props = schema.props ?? {};
    return SingleChildScrollView(
      scrollDirection: props['scrollDirection'] == 'horizontal'
          ? Axis.horizontal
          : Axis.vertical,
      padding: SchemaConverters.toEdgeInsets(props['padding']),
      child: schema.child != null
          ? parser.parse(schema.child!, context)
          : const SizedBox.shrink(),
    );
  }
}
