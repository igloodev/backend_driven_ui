import 'package:flutter/material.dart';

import '../../models/widget_schema.dart';
import '../../utils/bdui_logger.dart';
import '../../utils/schema_converters.dart';
import '../../utils/url_validator.dart';

/// Builders for display widgets: Text, Icon, Image, Divider.
class DisplayBuilders {
  static Widget buildText(WidgetSchema schema, BuildContext context) {
    final props = schema.props ?? {};
    return Text(
      props['text']?.toString() ?? '',
      style: TextStyle(
        fontSize: SchemaConverters.toDouble(props['fontSize']),
        fontWeight: SchemaConverters.toFontWeight(props['fontWeight']),
        color: SchemaConverters.toColor(props['color']),
        backgroundColor: SchemaConverters.toColor(props['backgroundColor']),
        letterSpacing: SchemaConverters.toDouble(props['letterSpacing']),
        wordSpacing: SchemaConverters.toDouble(props['wordSpacing']),
        height: SchemaConverters.toDouble(props['lineHeight']),
        fontStyle: props['fontStyle'] == 'italic' ? FontStyle.italic : null,
        decoration: SchemaConverters.toTextDecoration(props['decoration']),
        decorationColor: SchemaConverters.toColor(props['decorationColor']),
        decorationStyle: SchemaConverters.toTextDecorationStyle(props['decorationStyle']),
        decorationThickness: SchemaConverters.toDouble(props['decorationThickness']),
        fontFamily: props['fontFamily'] as String?,
      ),
      textAlign: SchemaConverters.toTextAlign(props['align']),
      maxLines: props['maxLines'] as int?,
      overflow: SchemaConverters.toTextOverflow(props['overflow']),
      softWrap: props['softWrap'] as bool?,
      textDirection: SchemaConverters.toTextDirection(props['textDirection']),
    );
  }

  static Widget buildIcon(WidgetSchema schema, BuildContext context) {
    final props = schema.props ?? {};
    return Icon(
      SchemaConverters.toIconData(props['icon']),
      size: SchemaConverters.toDouble(props['size']),
      color: SchemaConverters.toColor(props['color']),
    );
  }

  static Widget buildImage(WidgetSchema schema, BuildContext context) {
    final props = schema.props ?? {};
    final url = props['url'] as String?;

    if (url == null) return const SizedBox.shrink();

    if (!UrlValidator.isUrlSafe(url)) {
      BduiLogger.warn('Image blocked: URL failed security validation: $url');
      return Container(
        width: SchemaConverters.toDouble(props['width']),
        height: SchemaConverters.toDouble(props['height']),
        color: Colors.grey[200],
        child: const Center(child: Icon(Icons.block, color: Colors.red)),
      );
    }

    return Image.network(
      url,
      width: SchemaConverters.toDouble(props['width']),
      height: SchemaConverters.toDouble(props['height']),
      fit: SchemaConverters.toBoxFit(props['fit']),
      errorBuilder: (context, error, stackTrace) => Container(
        width: SchemaConverters.toDouble(props['width']),
        height: SchemaConverters.toDouble(props['height']),
        color: Colors.grey[200],
        child: const Center(child: Icon(Icons.broken_image, color: Colors.grey)),
      ),
    );
  }

  static Widget buildDivider(WidgetSchema schema, BuildContext context) {
    final props = schema.props ?? {};
    return Divider(
      height: SchemaConverters.toDouble(props['height']),
      thickness: SchemaConverters.toDouble(props['thickness']),
      color: SchemaConverters.toColor(props['color']),
    );
  }
}
