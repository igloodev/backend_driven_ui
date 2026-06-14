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
    // Flutter asserts: !maintainSize || maintainAnimation
    //                  !maintainAnimation || maintainState
    // Cascade so any combination the user provides is valid.
    final maintainSize = props['maintainSize'] as bool? ?? false;
    final maintainAnimation =
        (props['maintainAnimation'] as bool? ?? false) || maintainSize;
    final maintainState =
        (props['maintainState'] as bool? ?? false) || maintainAnimation;
    return Visibility(
      visible: props['visible'] as bool? ?? true,
      maintainSize: maintainSize,
      maintainAnimation: maintainAnimation,
      maintainState: maintainState,
      child: schema.child != null
          ? parser.parse(schema.child!, context)
          : const SizedBox.shrink(),
    );
  }

  /// [Semantics] — annotates the widget tree for accessibility tools.
  ///
  /// Props: `label`, `hint`, `value` (current value announced by screen reader),
  /// `button`, `enabled`, `readOnly`, `checked`, `toggled`, `selected`,
  /// `header`, `image`, `liveRegion`, `excludeSemantics`.
  static Widget buildSemantics(
    WidgetSchema schema,
    BuildContext context,
    SchemaParser parser,
  ) {
    final props = schema.props ?? {};
    return Semantics(
      label: props['label'] as String?,
      hint: props['hint'] as String?,
      value: props['value']?.toString(),
      button: props['button'] as bool? ?? false,
      enabled: props['enabled'] as bool?,
      readOnly: props['readOnly'] as bool? ?? false,
      checked: props['checked'] as bool?,
      toggled: props['toggled'] as bool?,
      selected: props['selected'] as bool? ?? false,
      header: props['header'] as bool? ?? false,
      image: props['image'] as bool? ?? false,
      liveRegion: props['liveRegion'] as bool? ?? false,
      excludeSemantics: props['excludeSemantics'] as bool? ?? false,
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
      opacity:
          (SchemaConverters.toDouble(props['opacity']) ?? 1.0).clamp(0.0, 1.0),
      child: schema.child != null
          ? parser.parse(schema.child!, context)
          : const SizedBox.shrink(),
    );
  }
}
