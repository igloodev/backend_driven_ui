import 'package:flutter/material.dart';

import '../../models/widget_schema.dart';
import '../../parser/schema_parser.dart';
import '../../utils/bdui_logger.dart';
import '../../utils/schema_converters.dart';
import '../../utils/url_validator.dart';
import '../../utils/helpers.dart';

/// Builders for Material Design widgets: Card, ListTile, CircleAvatar, Chip, ClipRRect.
class MaterialBuilders {
  static Widget buildCard(
    WidgetSchema schema,
    BuildContext context,
    SchemaParser parser,
  ) {
    final props = schema.props ?? {};
    return Card(
      color: SchemaConverters.toColor(props['color']),
      elevation: SchemaConverters.toDouble(props['elevation']),
      margin: SchemaConverters.toEdgeInsets(props['margin']),
      shape: props['borderRadius'] != null
          ? RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(
                SchemaConverters.toDouble(props['borderRadius'])!,
              ),
            )
          : null,
      child: schema.child != null ? parser.parse(schema.child!, context) : null,
    );
  }

  static Widget buildListTile(
    WidgetSchema schema,
    BuildContext context,
    SchemaParser parser,
  ) {
    final props = schema.props ?? {};

    Widget? leading;
    final leadingMap = toStringKeyedMap(schema.props?['leading']);
    if (leadingMap != null) {
      leading = parser.parse(WidgetSchema.fromJson(leadingMap), context);
    }

    Widget? trailing;
    final trailingMap = toStringKeyedMap(schema.props?['trailing']);
    if (trailingMap != null) {
      trailing = parser.parse(WidgetSchema.fromJson(trailingMap), context);
    }

    final actionMap = toStringKeyedMap(schema.action);

    return ListTile(
      leading: leading,
      trailing: trailing,
      title: props['title'] != null ? Text(props['title'].toString()) : null,
      subtitle: props['subtitle'] != null ? Text(props['subtitle'].toString()) : null,
      dense: props['dense'] as bool? ?? false,
      contentPadding: SchemaConverters.toEdgeInsets(props['contentPadding']),
      onTap: actionMap != null
          ? () => parser.createActionHandler(context).executeFromMap(actionMap)
          : null,
    );
  }

  static Widget buildCircleAvatar(
    WidgetSchema schema,
    BuildContext context,
    SchemaParser parser,
  ) {
    final props = schema.props ?? {};
    final imageUrl = props['imageUrl'] as String?;
    final radius = SchemaConverters.toDouble(props['radius']);
    final backgroundColor = SchemaConverters.toColor(props['backgroundColor']);

    if (imageUrl != null) {
      if (!UrlValidator.isUrlSafe(imageUrl)) {
        BduiLogger.warn('CircleAvatar image blocked: URL failed security validation: $imageUrl');
        return CircleAvatar(
          radius: radius,
          backgroundColor: backgroundColor ?? Colors.grey[200],
          child: const Icon(Icons.block, color: Colors.red),
        );
      }
      return CircleAvatar(
        radius: radius,
        backgroundColor: backgroundColor,
        backgroundImage: NetworkImage(imageUrl),
      );
    }

    return CircleAvatar(
      radius: radius,
      backgroundColor: backgroundColor,
      child: schema.child != null ? parser.parse(schema.child!, context) : null,
    );
  }

  static Widget buildChip(WidgetSchema schema, BuildContext context) {
    final props = schema.props ?? {};
    return Chip(
      label: Text(props['label']?.toString() ?? ''),
      backgroundColor: SchemaConverters.toColor(props['backgroundColor']),
      avatar: props['avatar'] != null
          ? Icon(SchemaConverters.toIconData(props['avatar']))
          : null,
      deleteIcon: props['deleteIcon'] != null
          ? Icon(SchemaConverters.toIconData(props['deleteIcon']))
          : null,
    );
  }

  static Widget buildClipRRect(
    WidgetSchema schema,
    BuildContext context,
    SchemaParser parser,
  ) {
    final props = schema.props ?? {};
    return ClipRRect(
      borderRadius: BorderRadius.circular(
        SchemaConverters.toDouble(props['borderRadius']) ?? 0.0,
      ),
      child: schema.child != null
          ? parser.parse(schema.child!, context)
          : const SizedBox.shrink(),
    );
  }
}
