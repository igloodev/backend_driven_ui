import 'package:flutter/material.dart';

import '../../models/widget_schema.dart';
import '../../parser/schema_parser.dart';
import '../../utils/schema_converters.dart';

/// Builders for CustomScrollView and its sliver descendants:
/// SliverAppBar, SliverList, SliverGrid, SliverToBoxAdapter,
/// SliverPadding, SliverFillRemaining, SliverFixedExtentList.
class SliverBuilders {
  /// [CustomScrollView] — scrollable area composed of slivers.
  ///
  /// Props: `scrollDirection` (`vertical`|`horizontal`), `reverse`,
  /// `shrinkWrap`, `physics` (`never`|`bouncing`|`clamping`).
  /// Children must be sliver widgets (SliverList, SliverAppBar, etc.).
  static Widget buildCustomScrollView(
    WidgetSchema schema,
    BuildContext context,
    SchemaParser parser,
  ) {
    final props = schema.props ?? {};

    ScrollPhysics? physics;
    switch (props['physics'] as String?) {
      case 'never':
        physics = const NeverScrollableScrollPhysics();
        break;
      case 'bouncing':
        physics = const BouncingScrollPhysics();
        break;
      case 'clamping':
        physics = const ClampingScrollPhysics();
        break;
    }

    return CustomScrollView(
      scrollDirection: props['scrollDirection'] == 'horizontal'
          ? Axis.horizontal
          : Axis.vertical,
      reverse: props['reverse'] as bool? ?? false,
      shrinkWrap: props['shrinkWrap'] as bool? ?? false,
      physics: physics,
      slivers:
          schema.children?.map((c) => parser.parse(c, context)).toList() ?? [],
    );
  }

  /// [SliverAppBar] — collapsible app bar for use inside [CustomScrollView].
  ///
  /// Props: `title`, `expandedHeight`, `floating`, `pinned`, `snap`,
  /// `backgroundColor`, `foregroundColor`, `elevation`, `centerTitle`.
  /// `child` — rendered as `FlexibleSpaceBar.background`.
  static Widget buildSliverAppBar(
    WidgetSchema schema,
    BuildContext context,
    SchemaParser parser,
  ) {
    final props = schema.props ?? {};
    final title = props['title'] as String?;
    final expandedHeight = SchemaConverters.toDouble(props['expandedHeight']);

    return SliverAppBar(
      title: title != null ? Text(title) : null,
      centerTitle: props['centerTitle'] as bool?,
      expandedHeight: expandedHeight,
      floating: props['floating'] as bool? ?? false,
      pinned: props['pinned'] as bool? ?? false,
      snap: (props['snap'] as bool? ?? false) &&
          (props['floating'] as bool? ?? false),
      backgroundColor: SchemaConverters.toColor(props['backgroundColor']),
      foregroundColor: SchemaConverters.toColor(props['foregroundColor']),
      elevation: SchemaConverters.toDouble(props['elevation']),
      flexibleSpace: schema.child != null
          ? FlexibleSpaceBar(
              background: parser.parse(schema.child!, context),
            )
          : null,
    );
  }

  /// [SliverList] — scrollable list of slivers rendered via
  /// [SliverChildBuilderDelegate].
  ///
  /// Use `children` to define list items.
  static Widget buildSliverList(
    WidgetSchema schema,
    BuildContext context,
    SchemaParser parser,
  ) {
    final children = schema.children ?? [];

    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (ctx, index) {
          final child = children[index];
          final itemKey =
              child.props?['id']?.toString() ?? 'sliver_item_$index';
          return KeyedSubtree(
            key: ValueKey(itemKey),
            child: parser.parse(child, ctx),
          );
        },
        childCount: children.length,
      ),
    );
  }

  /// [SliverGrid] — scrollable grid of slivers.
  ///
  /// Props: `crossAxisCount` (fixed) or `maxCrossAxisExtent` (extent-based),
  /// `mainAxisSpacing`, `crossAxisSpacing`, `childAspectRatio`.
  static Widget buildSliverGrid(
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
                (SchemaConverters.toDouble(props['childAspectRatio']) ?? 1.0)
                    .clamp(0.01, double.infinity),
          )
        : SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount:
                (SchemaConverters.toDouble(props['crossAxisCount'])?.toInt() ??
                        2)
                    .clamp(1, 99999),
            mainAxisSpacing:
                SchemaConverters.toDouble(props['mainAxisSpacing']) ?? 0.0,
            crossAxisSpacing:
                SchemaConverters.toDouble(props['crossAxisSpacing']) ?? 0.0,
            childAspectRatio:
                (SchemaConverters.toDouble(props['childAspectRatio']) ?? 1.0)
                    .clamp(0.01, double.infinity),
          );

    return SliverGrid(
      gridDelegate: gridDelegate,
      delegate: SliverChildBuilderDelegate(
        (ctx, index) {
          final child = children[index];
          final itemKey =
              child.props?['id']?.toString() ?? 'sliver_grid_$index';
          return KeyedSubtree(
            key: ValueKey(itemKey),
            child: parser.parse(child, ctx),
          );
        },
        childCount: children.length,
      ),
    );
  }

  /// [SliverToBoxAdapter] — wraps a regular (box) widget inside a sliver.
  ///
  /// Use `child` for the wrapped widget.
  static Widget buildSliverToBoxAdapter(
    WidgetSchema schema,
    BuildContext context,
    SchemaParser parser,
  ) {
    return SliverToBoxAdapter(
      child: schema.child != null
          ? parser.parse(schema.child!, context)
          : const SizedBox.shrink(),
    );
  }

  /// [SliverPadding] — adds padding around another sliver.
  ///
  /// Props: `padding` (same format as other widgets).
  /// `child` — the sliver to pad.
  static Widget buildSliverPadding(
    WidgetSchema schema,
    BuildContext context,
    SchemaParser parser,
  ) {
    final props = schema.props ?? {};
    return SliverPadding(
      padding:
          SchemaConverters.toEdgeInsets(props['padding']) ?? EdgeInsets.zero,
      sliver:
          schema.child != null ? parser.parse(schema.child!, context) : null,
    );
  }

  /// [SliverFillRemaining] — fills the remaining space in the viewport.
  ///
  /// Props: `hasScrollBody` (default `false`), `fillOverscroll` (default `false`).
  /// `child` — the widget to fill with.
  static Widget buildSliverFillRemaining(
    WidgetSchema schema,
    BuildContext context,
    SchemaParser parser,
  ) {
    final props = schema.props ?? {};
    return SliverFillRemaining(
      hasScrollBody: props['hasScrollBody'] as bool? ?? false,
      fillOverscroll: props['fillOverscroll'] as bool? ?? false,
      child: schema.child != null ? parser.parse(schema.child!, context) : null,
    );
  }

  /// [SliverFixedExtentList] — list where every item has the same main-axis extent.
  ///
  /// Props: `itemExtent` (required, defaults to 56).
  /// Use `children` to define list items.
  static Widget buildSliverFixedExtentList(
    WidgetSchema schema,
    BuildContext context,
    SchemaParser parser,
  ) {
    final props = schema.props ?? {};
    final children = schema.children ?? [];

    return SliverFixedExtentList(
      itemExtent: (SchemaConverters.toDouble(props['itemExtent']) ?? 56.0)
          .clamp(0.1, double.infinity),
      delegate: SliverChildBuilderDelegate(
        (ctx, index) {
          final child = children[index];
          final itemKey = child.props?['id']?.toString() ?? 'fixed_item_$index';
          return KeyedSubtree(
            key: ValueKey(itemKey),
            child: parser.parse(child, ctx),
          );
        },
        childCount: children.length,
      ),
    );
  }
}
