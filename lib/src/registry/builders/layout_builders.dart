import 'package:flutter/material.dart';

import '../../models/widget_schema.dart';
import '../../parser/schema_parser.dart';
import '../../utils/bdui_logger.dart';
import '../../utils/schema_converters.dart';
import '../../utils/url_validator.dart';

/// Builders for layout widgets: Container, Column, Row, Stack, Padding,
/// Center, SizedBox, Expanded, Flexible, Wrap, Spacer, AspectRatio.
class LayoutBuilders {
  static Widget buildContainer(
    WidgetSchema schema,
    BuildContext context,
    SchemaParser parser,
  ) {
    final props = schema.props ?? {};

    BoxDecoration? decoration;
    if (props['color'] != null ||
        props['gradient'] != null ||
        props['borderRadius'] != null ||
        props['border'] != null ||
        props['boxShadow'] != null ||
        props['backgroundImage'] != null) {
      DecorationImage? backgroundImage;
      final bgImageUrl = props['backgroundImage'] as String?;
      if (bgImageUrl != null) {
        if (UrlValidator.isUrlSafe(bgImageUrl)) {
          backgroundImage = DecorationImage(
            image: NetworkImage(bgImageUrl),
            fit: SchemaConverters.toBoxFit(props['backgroundFit']),
          );
        } else {
          BduiLogger.warn('Container backgroundImage blocked: URL failed security validation: $bgImageUrl');
        }
      }

      decoration = BoxDecoration(
        color: props['gradient'] == null ? SchemaConverters.toColor(props['color']) : null,
        gradient: SchemaConverters.toGradient(props['gradient']),
        borderRadius: SchemaConverters.toBorderRadius(props['borderRadius']),
        border: props['border'] != null
            ? Border.all(
                color: SchemaConverters.toColor(props['borderColor']) ?? Colors.black,
                width: SchemaConverters.toDouble(props['borderWidth']) ?? 1.0,
              )
            : null,
        boxShadow: SchemaConverters.toBoxShadow(props['boxShadow']),
        image: backgroundImage,
      );
    }

    return Container(
      width: SchemaConverters.toDouble(props['width']),
      height: SchemaConverters.toDouble(props['height']),
      padding: SchemaConverters.toEdgeInsets(props['padding']),
      margin: SchemaConverters.toEdgeInsets(props['margin']),
      alignment: SchemaConverters.toAlignment(props['alignment']),
      decoration: decoration,
      transform: SchemaConverters.toMatrix4(props['transform']),
      child: schema.child != null ? parser.parse(schema.child!, context) : null,
    );
  }

  static Widget buildColumn(
    WidgetSchema schema,
    BuildContext context,
    SchemaParser parser,
  ) {
    final props = schema.props ?? {};
    return Column(
      mainAxisAlignment: SchemaConverters.toMainAxisAlignment(props['mainAxisAlignment']),
      crossAxisAlignment: SchemaConverters.toCrossAxisAlignment(props['crossAxisAlignment']),
      mainAxisSize: SchemaConverters.toMainAxisSize(props['mainAxisSize']),
      children: schema.children?.map((c) => parser.parse(c, context)).toList() ?? [],
    );
  }

  static Widget buildRow(
    WidgetSchema schema,
    BuildContext context,
    SchemaParser parser,
  ) {
    final props = schema.props ?? {};
    return Row(
      mainAxisAlignment: SchemaConverters.toMainAxisAlignment(props['mainAxisAlignment']),
      crossAxisAlignment: SchemaConverters.toCrossAxisAlignment(props['crossAxisAlignment']),
      mainAxisSize: SchemaConverters.toMainAxisSize(props['mainAxisSize']),
      children: schema.children?.map((c) => parser.parse(c, context)).toList() ?? [],
    );
  }

  static Widget buildStack(
    WidgetSchema schema,
    BuildContext context,
    SchemaParser parser,
  ) {
    return Stack(
      children: schema.children?.map((c) => parser.parse(c, context)).toList() ?? [],
    );
  }

  static Widget buildPadding(
    WidgetSchema schema,
    BuildContext context,
    SchemaParser parser,
  ) {
    final props = schema.props ?? {};
    return Padding(
      padding: SchemaConverters.toEdgeInsets(props['padding']) ?? EdgeInsets.zero,
      child: schema.child != null ? parser.parse(schema.child!, context) : null,
    );
  }

  static Widget buildCenter(
    WidgetSchema schema,
    BuildContext context,
    SchemaParser parser,
  ) {
    return Center(
      child: schema.child != null ? parser.parse(schema.child!, context) : null,
    );
  }

  static Widget buildSizedBox(
    WidgetSchema schema,
    BuildContext context,
    SchemaParser parser,
  ) {
    final props = schema.props ?? {};
    return SizedBox(
      width: SchemaConverters.toDouble(props['width']),
      height: SchemaConverters.toDouble(props['height']),
      child: schema.child != null ? parser.parse(schema.child!, context) : null,
    );
  }

  static Widget buildExpanded(
    WidgetSchema schema,
    BuildContext context,
    SchemaParser parser,
  ) {
    final props = schema.props ?? {};
    return Expanded(
      flex: props['flex'] as int? ?? 1,
      child: schema.child != null
          ? parser.parse(schema.child!, context)
          : const SizedBox.shrink(),
    );
  }

  static Widget buildFlexible(
    WidgetSchema schema,
    BuildContext context,
    SchemaParser parser,
  ) {
    final props = schema.props ?? {};
    return Flexible(
      flex: props['flex'] as int? ?? 1,
      fit: props['fit'] == 'loose' ? FlexFit.loose : FlexFit.tight,
      child: schema.child != null
          ? parser.parse(schema.child!, context)
          : const SizedBox.shrink(),
    );
  }

  static Widget buildWrap(
    WidgetSchema schema,
    BuildContext context,
    SchemaParser parser,
  ) {
    final props = schema.props ?? {};
    return Wrap(
      spacing: SchemaConverters.toDouble(props['spacing']) ?? 0.0,
      runSpacing: SchemaConverters.toDouble(props['runSpacing']) ?? 0.0,
      alignment: SchemaConverters.toWrapAlignment(props['alignment']),
      children: schema.children?.map((c) => parser.parse(c, context)).toList() ?? [],
    );
  }

  static Widget buildSpacer(WidgetSchema schema, BuildContext context) {
    final props = schema.props ?? {};
    return Spacer(flex: props['flex'] as int? ?? 1);
  }

  static Widget buildAspectRatio(
    WidgetSchema schema,
    BuildContext context,
    SchemaParser parser,
  ) {
    final props = schema.props ?? {};
    var ratio = SchemaConverters.toDouble(props['ratio']) ?? 1.0;

    if (ratio <= 0 || ratio.isNaN || ratio.isInfinite) {
      BduiLogger.warn('Invalid aspect ratio: $ratio, using 1.0');
      ratio = 1.0;
    } else if (ratio < 0.1) {
      BduiLogger.warn('Aspect ratio too small: $ratio, clamping to 0.1');
      ratio = 0.1;
    } else if (ratio > 10) {
      BduiLogger.warn('Aspect ratio too large: $ratio, clamping to 10');
      ratio = 10.0;
    }

    return AspectRatio(
      aspectRatio: ratio,
      child: schema.child != null
          ? parser.parse(schema.child!, context)
          : const SizedBox.shrink(),
    );
  }
}
