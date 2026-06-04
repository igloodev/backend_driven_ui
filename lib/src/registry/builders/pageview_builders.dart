import 'package:flutter/material.dart';

import '../../models/widget_schema.dart';
import '../../parser/schema_parser.dart';

/// Builders for PageView and PageView.builder widgets.
class PageViewBuilders {
  static Widget buildPageView(
    WidgetSchema schema,
    BuildContext context,
    SchemaParser parser,
  ) {
    final props = schema.props ?? {};
    final children = schema.children ?? [];

    return PageView(
      scrollDirection: _toAxis(props['scrollDirection'] as String?),
      reverse: props['reverse'] as bool? ?? false,
      physics: _toScrollPhysics(props['physics'] as String?),
      padEnds: props['padEnds'] as bool? ?? true,
      children: children.map((c) => parser.parse(c, context)).toList(),
    );
  }

  static Widget buildPageViewBuilder(
    WidgetSchema schema,
    BuildContext context,
    SchemaParser parser,
  ) {
    final props = schema.props ?? {};
    final itemSchema = schema.child;
    final itemCount = (props['itemCount'] as num?)?.toInt();

    return PageView.builder(
      scrollDirection: _toAxis(props['scrollDirection'] as String?),
      reverse: props['reverse'] as bool? ?? false,
      physics: _toScrollPhysics(props['physics'] as String?),
      padEnds: props['padEnds'] as bool? ?? true,
      itemCount: itemCount,
      itemBuilder: (ctx, index) {
        if (itemSchema == null) return const SizedBox.shrink();
        return parser.parse(itemSchema, ctx);
      },
    );
  }

  static Axis _toAxis(String? value) {
    return value == 'vertical' ? Axis.vertical : Axis.horizontal;
  }

  static ScrollPhysics? _toScrollPhysics(String? value) {
    switch (value) {
      case 'never':
        return const NeverScrollableScrollPhysics();
      case 'bouncing':
        return const BouncingScrollPhysics();
      case 'clamping':
        return const ClampingScrollPhysics();
      default:
        return null;
    }
  }
}
