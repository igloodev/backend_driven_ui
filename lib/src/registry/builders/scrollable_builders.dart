import 'package:flutter/material.dart';

import '../../models/widget_schema.dart';
import '../../parser/schema_parser.dart';
import '../../utils/schema_converters.dart';

/// Builders for scrollable widgets: ListView variants, GridView variants,
/// SingleChildScrollView.
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

  /// [ListView.separated] — renders children with a separator between each item.
  ///
  /// Props:
  /// - `separator` — optional widget schema map for the separator (defaults to `Divider`)
  /// - `shrinkWrap`, `physics`, `padding` — same as [buildListView]
  static Widget buildListViewSeparated(
    WidgetSchema schema,
    BuildContext context,
    SchemaParser parser,
  ) {
    final props = schema.props ?? {};
    final children = schema.children;
    if (children == null || children.isEmpty) return const SizedBox.shrink();

    final separatorSchema = props['separator'];

    return ListView.separated(
      shrinkWrap: props['shrinkWrap'] as bool? ?? false,
      physics: props['physics'] == 'never'
          ? const NeverScrollableScrollPhysics()
          : null,
      padding: SchemaConverters.toEdgeInsets(props['padding']),
      itemCount: children.length,
      itemBuilder: (ctx, index) {
        final child = children[index];
        final itemKey = child.props?['id']?.toString() ?? 'item_$index';
        return KeyedSubtree(
          key: ValueKey(itemKey),
          child: parser.parse(child, ctx),
        );
      },
      separatorBuilder: (ctx, index) {
        if (separatorSchema is Map<String, dynamic>) {
          try {
            return parser.parse(WidgetSchema.fromJson(separatorSchema), ctx);
          } catch (_) {}
        }
        return const Divider(height: 1);
      },
    );
  }

  /// [ListView.custom] — renders children via [SliverChildBuilderDelegate].
  ///
  /// Supports `shrinkWrap`, `physics`, `padding` props.
  static Widget buildListViewCustom(
    WidgetSchema schema,
    BuildContext context,
    SchemaParser parser,
  ) {
    final props = schema.props ?? {};
    final children = schema.children ?? [];

    return ListView.custom(
      shrinkWrap: props['shrinkWrap'] as bool? ?? false,
      physics: props['physics'] == 'never'
          ? const NeverScrollableScrollPhysics()
          : null,
      padding: SchemaConverters.toEdgeInsets(props['padding']),
      childrenDelegate: SliverChildBuilderDelegate(
        (ctx, index) {
          final child = children[index];
          final itemKey = child.props?['id']?.toString() ?? 'item_$index';
          return KeyedSubtree(
            key: ValueKey(itemKey),
            child: parser.parse(child, ctx),
          );
        },
        childCount: children.length,
      ),
    );
  }

  static Widget buildGridView(
    WidgetSchema schema,
    BuildContext context,
    SchemaParser parser,
  ) {
    final props = schema.props ?? {};
    final children = schema.children;
    final crossAxisCount = (SchemaConverters.toDouble(props['crossAxisCount'])?.toInt() ?? 2).clamp(1, 99999);

    if (children == null || children.isEmpty) return const SizedBox.shrink();

    return GridView.builder(
      shrinkWrap: props['shrinkWrap'] as bool? ?? false,
      physics: props['physics'] == 'never' ? const NeverScrollableScrollPhysics() : null,
      padding: SchemaConverters.toEdgeInsets(props['padding']),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        mainAxisSpacing: SchemaConverters.toDouble(props['mainAxisSpacing']) ?? 0.0,
        crossAxisSpacing: SchemaConverters.toDouble(props['crossAxisSpacing']) ?? 0.0,
        childAspectRatio: (SchemaConverters.toDouble(props['childAspectRatio']) ?? 1.0).clamp(0.01, double.infinity),
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

  /// [GridView.count] — fixed cross-axis count grid using `children` list.
  ///
  /// Props: `crossAxisCount`, `mainAxisSpacing`, `crossAxisSpacing`,
  /// `childAspectRatio`, `shrinkWrap`, `physics`, `padding`.
  static Widget buildGridViewCount(
    WidgetSchema schema,
    BuildContext context,
    SchemaParser parser,
  ) {
    final props = schema.props ?? {};
    final children = schema.children ?? [];

    return GridView.count(
      shrinkWrap: props['shrinkWrap'] as bool? ?? false,
      physics: props['physics'] == 'never'
          ? const NeverScrollableScrollPhysics()
          : null,
      padding: SchemaConverters.toEdgeInsets(props['padding']),
      crossAxisCount: (SchemaConverters.toDouble(props['crossAxisCount'])?.toInt() ?? 2).clamp(1, 99999),
      mainAxisSpacing:
          SchemaConverters.toDouble(props['mainAxisSpacing']) ?? 0.0,
      crossAxisSpacing:
          SchemaConverters.toDouble(props['crossAxisSpacing']) ?? 0.0,
      childAspectRatio:
          (SchemaConverters.toDouble(props['childAspectRatio']) ?? 1.0).clamp(0.01, double.infinity),
      children: children.map((c) => parser.parse(c, context)).toList(),
    );
  }

  /// [GridView.extent] — grid with a maximum cross-axis extent per tile.
  ///
  /// Props: `maxCrossAxisExtent` (required), `mainAxisSpacing`,
  /// `crossAxisSpacing`, `childAspectRatio`, `shrinkWrap`, `physics`, `padding`.
  static Widget buildGridViewExtent(
    WidgetSchema schema,
    BuildContext context,
    SchemaParser parser,
  ) {
    final props = schema.props ?? {};
    final children = schema.children ?? [];

    return GridView.extent(
      shrinkWrap: props['shrinkWrap'] as bool? ?? false,
      physics: props['physics'] == 'never'
          ? const NeverScrollableScrollPhysics()
          : null,
      padding: SchemaConverters.toEdgeInsets(props['padding']),
      maxCrossAxisExtent:
          (SchemaConverters.toDouble(props['maxCrossAxisExtent']) ?? 200.0)
              .clamp(0.1, double.infinity),
      mainAxisSpacing:
          SchemaConverters.toDouble(props['mainAxisSpacing']) ?? 0.0,
      crossAxisSpacing:
          SchemaConverters.toDouble(props['crossAxisSpacing']) ?? 0.0,
      childAspectRatio:
          (SchemaConverters.toDouble(props['childAspectRatio']) ?? 1.0).clamp(0.01, double.infinity),
      children: children.map((c) => parser.parse(c, context)).toList(),
    );
  }

  /// [GridView.custom] — grid with a custom [SliverGridDelegate] and
  /// [SliverChildBuilderDelegate].
  ///
  /// Provide either `crossAxisCount` (fixed count) or `maxCrossAxisExtent`
  /// (extent-based) to select the grid delegate.
  static Widget buildGridViewCustom(
    WidgetSchema schema,
    BuildContext context,
    SchemaParser parser,
  ) {
    final props = schema.props ?? {};
    final children = schema.children ?? [];
    final maxCrossAxisExtent =
        SchemaConverters.toDouble(props['maxCrossAxisExtent'])
            ?.clamp(0.1, double.infinity);

    final SliverGridDelegate gridDelegate = maxCrossAxisExtent != null
        ? SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: maxCrossAxisExtent,
            mainAxisSpacing:
                SchemaConverters.toDouble(props['mainAxisSpacing']) ?? 0.0,
            crossAxisSpacing:
                SchemaConverters.toDouble(props['crossAxisSpacing']) ?? 0.0,
            childAspectRatio:
                (SchemaConverters.toDouble(props['childAspectRatio']) ?? 1.0).clamp(0.01, double.infinity),
          )
        : SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: (SchemaConverters.toDouble(props['crossAxisCount'])?.toInt() ?? 2).clamp(1, 99999),
            mainAxisSpacing:
                SchemaConverters.toDouble(props['mainAxisSpacing']) ?? 0.0,
            crossAxisSpacing:
                SchemaConverters.toDouble(props['crossAxisSpacing']) ?? 0.0,
            childAspectRatio:
                (SchemaConverters.toDouble(props['childAspectRatio']) ?? 1.0).clamp(0.01, double.infinity),
          );

    return GridView.custom(
      shrinkWrap: props['shrinkWrap'] as bool? ?? false,
      physics: props['physics'] == 'never'
          ? const NeverScrollableScrollPhysics()
          : null,
      padding: SchemaConverters.toEdgeInsets(props['padding']),
      gridDelegate: gridDelegate,
      childrenDelegate: SliverChildBuilderDelegate(
        (ctx, index) {
          final child = children[index];
          final itemKey = child.props?['id']?.toString() ?? 'grid_$index';
          return KeyedSubtree(
            key: ValueKey(itemKey),
            child: parser.parse(child, ctx),
          );
        },
        childCount: children.length,
      ),
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
