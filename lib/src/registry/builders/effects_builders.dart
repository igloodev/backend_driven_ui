import 'package:flutter/material.dart';

import '../../models/widget_schema.dart';
import '../../parser/schema_parser.dart';
import '../../utils/schema_converters.dart';

/// Builders for effect widgets: Visibility, Opacity.
class EffectsBuilders {
  static Widget buildVisibility(
    WidgetSchema schema,
    BuildContext context,
    SchemaParser parser,
  ) {
    final props = schema.props ?? {};
    return Visibility(
      visible: props['visible'] as bool? ?? true,
      maintainSize: props['maintainSize'] as bool? ?? false,
      maintainAnimation: props['maintainAnimation'] as bool? ?? false,
      maintainState: props['maintainState'] as bool? ?? false,
      child: schema.child != null
          ? parser.parse(schema.child!, context)
          : const SizedBox.shrink(),
    );
  }

  static Widget buildOpacity(
    WidgetSchema schema,
    BuildContext context,
    SchemaParser parser,
  ) {
    final props = schema.props ?? {};
    return Opacity(
      opacity: SchemaConverters.toDouble(props['opacity']) ?? 1.0,
      child: schema.child != null
          ? parser.parse(schema.child!, context)
          : const SizedBox.shrink(),
    );
  }
}
