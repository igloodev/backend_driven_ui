import 'package:flutter/material.dart';

import '../../models/widget_schema.dart';
import '../../utils/bdui_logger.dart';
import '../../utils/schema_converters.dart';
import '../../utils/url_validator.dart';

/// Builders for display widgets: Text, Icon, Image, Divider,
/// CircularProgressIndicator, LinearProgressIndicator.
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
        decorationStyle:
            SchemaConverters.toTextDecorationStyle(props['decorationStyle']),
        decorationThickness:
            SchemaConverters.toDouble(props['decorationThickness']),
        fontFamily: props['fontFamily'] as String?,
      ),
      textAlign: SchemaConverters.toTextAlign(props['textAlign']),
      maxLines: SchemaConverters.toDouble(props['maxLines'])?.toInt(),
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
        child:
            const Center(child: Icon(Icons.broken_image, color: Colors.grey)),
      ),
    );
  }

  /// [RichText] — inline text with mixed styles using `TextSpan` children.
  ///
  /// Props:
  /// - `spans` (List) — each item is a map with: `text`, `color`, `fontSize`,
  ///   `bold`, `italic`, `underline`, `strikethrough`, `letterSpacing`,
  ///   `fontFamily`, `backgroundColor`. Nested `spans` are supported.
  /// - `textAlign`, `maxLines`, `overflow`, `softWrap`, `textDirection`.
  static Widget buildRichText(WidgetSchema schema, BuildContext context) {
    final props = schema.props ?? {};
    final spansList = props['spans'] as List<dynamic>? ?? const [];

    return RichText(
      text: TextSpan(
        children: spansList.map(_parseSpan).toList(),
      ),
      textAlign:
          SchemaConverters.toTextAlign(props['textAlign']) ?? TextAlign.start,
      maxLines: SchemaConverters.toDouble(props['maxLines'])?.toInt(),
      overflow: SchemaConverters.toTextOverflow(props['overflow']) ??
          TextOverflow.clip,
      softWrap: props['softWrap'] as bool? ?? true,
      textDirection: SchemaConverters.toTextDirection(props['textDirection']),
    );
  }

  static TextSpan _parseSpan(dynamic raw) {
    if (raw is! Map) return const TextSpan();
    final m = raw.map((k, v) => MapEntry(k.toString(), v));
    final text = m['text']?.toString();
    final childSpans = (m['spans'] as List<dynamic>?)?.map(_parseSpan).toList();
    final style = TextStyle(
      color: SchemaConverters.toColor(m['color']),
      fontSize: SchemaConverters.toDouble(m['fontSize']),
      fontWeight: m['bold'] == true ? FontWeight.bold : null,
      fontStyle: m['italic'] == true ? FontStyle.italic : null,
      decoration: _spanDecoration(m),
      letterSpacing: SchemaConverters.toDouble(m['letterSpacing']),
      fontFamily: m['fontFamily'] as String?,
      backgroundColor: SchemaConverters.toColor(m['backgroundColor']),
    );
    return TextSpan(text: text, style: style, children: childSpans);
  }

  static TextDecoration? _spanDecoration(Map<String, dynamic> m) {
    final underline = m['underline'] == true;
    final strikethrough = m['strikethrough'] == true;
    if (underline && strikethrough) {
      return TextDecoration.combine(
          [TextDecoration.underline, TextDecoration.lineThrough]);
    }
    if (underline) return TextDecoration.underline;
    if (strikethrough) return TextDecoration.lineThrough;
    return null;
  }

  static Widget buildDivider(WidgetSchema schema, BuildContext context) {
    final props = schema.props ?? {};
    return Divider(
      height: SchemaConverters.toDouble(props['height']),
      thickness: SchemaConverters.toDouble(props['thickness']),
      indent: SchemaConverters.toDouble(props['indent']),
      endIndent: SchemaConverters.toDouble(props['endIndent']),
      color: SchemaConverters.toColor(props['color']),
    );
  }

  /// [CircularProgressIndicator] — spinning progress ring.
  ///
  /// Props: `value` (0.0–1.0; omit for indeterminate), `color`,
  /// `backgroundColor`, `strokeWidth` (default 4.0),
  /// `strokeCap` (`butt` | `round` | `square`).
  static Widget buildCircularProgressIndicator(
    WidgetSchema schema,
    BuildContext context,
  ) {
    final props = schema.props ?? {};

    StrokeCap? strokeCap;
    switch (props['strokeCap'] as String?) {
      case 'round':
        strokeCap = StrokeCap.round;
        break;
      case 'square':
        strokeCap = StrokeCap.square;
        break;
      case 'butt':
        strokeCap = StrokeCap.butt;
        break;
    }

    return CircularProgressIndicator(
      value: SchemaConverters.toDouble(props['value']),
      color: SchemaConverters.toColor(props['color']),
      backgroundColor: SchemaConverters.toColor(props['backgroundColor']),
      strokeWidth: SchemaConverters.toDouble(props['strokeWidth']) ?? 4.0,
      strokeCap: strokeCap,
    );
  }

  /// [LinearProgressIndicator] — horizontal progress bar.
  ///
  /// Props: `value` (0.0–1.0; omit for indeterminate), `color`,
  /// `backgroundColor`, `minHeight`, `borderRadius`.
  static Widget buildLinearProgressIndicator(
    WidgetSchema schema,
    BuildContext context,
  ) {
    final props = schema.props ?? {};
    return LinearProgressIndicator(
      value: SchemaConverters.toDouble(props['value']),
      color: SchemaConverters.toColor(props['color']),
      backgroundColor: SchemaConverters.toColor(props['backgroundColor']),
      minHeight: SchemaConverters.toDouble(props['minHeight']),
      borderRadius: SchemaConverters.toBorderRadius(props['borderRadius']) ??
          BorderRadius.zero,
    );
  }
}
