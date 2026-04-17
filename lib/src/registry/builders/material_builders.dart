import 'package:flutter/material.dart';

import '../../models/widget_schema.dart';
import '../../parser/schema_parser.dart';
import '../../utils/bdui_logger.dart';
import '../../utils/schema_converters.dart';
import '../../utils/url_validator.dart';
import '../../utils/helpers.dart';

/// Builders for Material Design widgets: Card, ListTile, CircleAvatar, Chip,
/// ClipRRect, FloatingActionButton, ExpansionTile.
class MaterialBuilders {
  static Widget buildCard(
    WidgetSchema schema,
    BuildContext context,
    SchemaParser parser,
  ) {
    final props = schema.props ?? {};

    Clip? clipBehavior;
    switch (props['clipBehavior'] as String?) {
      case 'hardEdge':
        clipBehavior = Clip.hardEdge;
        break;
      case 'antiAlias':
        clipBehavior = Clip.antiAlias;
        break;
      case 'antiAliasWithSaveLayer':
        clipBehavior = Clip.antiAliasWithSaveLayer;
        break;
    }

    return Card(
      color: SchemaConverters.toColor(props['color']),
      shadowColor: SchemaConverters.toColor(props['shadowColor']),
      surfaceTintColor: SchemaConverters.toColor(props['surfaceTintColor']),
      elevation: SchemaConverters.toDouble(props['elevation']),
      margin: SchemaConverters.toEdgeInsets(props['margin']),
      clipBehavior: clipBehavior,
      shape: props['borderRadius'] != null
          ? RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(
                SchemaConverters.toDouble(props['borderRadius']) ?? 0.0,
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

    Widget? parseSlot(dynamic slotValue) {
      final map = toStringKeyedMap(slotValue);
      if (map == null) return null;
      try {
        return parser.parse(WidgetSchema.fromJson(map), context);
      } catch (_) {
        return null;
      }
    }

    final actionMap = toStringKeyedMap(schema.action);

    return ListTile(
      leading: parseSlot(schema.props?['leading']),
      trailing: parseSlot(schema.props?['trailing']),
      title: props['title'] != null ? Text(props['title'].toString()) : null,
      subtitle: props['subtitle'] != null ? Text(props['subtitle'].toString()) : null,
      dense: props['dense'] as bool? ?? false,
      enabled: props['enabled'] as bool? ?? true,
      selected: props['selected'] as bool? ?? false,
      isThreeLine: props['subtitle'] != null && (props['isThreeLine'] as bool? ?? false),
      tileColor: SchemaConverters.toColor(props['tileColor']),
      selectedTileColor: SchemaConverters.toColor(props['selectedTileColor']),
      selectedColor: SchemaConverters.toColor(props['selectedColor']),
      iconColor: SchemaConverters.toColor(props['iconColor']),
      textColor: SchemaConverters.toColor(props['textColor']),
      contentPadding: SchemaConverters.toEdgeInsets(props['contentPadding']),
      minLeadingWidth: SchemaConverters.toDouble(props['minLeadingWidth']),
      minVerticalPadding: SchemaConverters.toDouble(props['minVerticalPadding']),
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
      labelStyle: SchemaConverters.toTextStyle(props['labelStyle']),
      backgroundColor: SchemaConverters.toColor(props['backgroundColor']),
      shadowColor: SchemaConverters.toColor(props['shadowColor']),
      elevation: SchemaConverters.toDouble(props['elevation']),
      padding: SchemaConverters.toEdgeInsets(props['padding']),
      labelPadding: SchemaConverters.toEdgeInsets(props['labelPadding']),
      avatar: props['avatar'] != null
          ? Icon(SchemaConverters.toIconData(props['avatar']))
          : null,
      deleteIcon: props['deleteIcon'] != null
          ? Icon(SchemaConverters.toIconData(props['deleteIcon']))
          : null,
      side: props['borderColor'] != null
          ? BorderSide(
              color: SchemaConverters.toColor(props['borderColor']) ??
                  Colors.transparent,
              width: SchemaConverters.toDouble(props['borderWidth']) ?? 1.0,
            )
          : null,
    );
  }

  static Widget buildClipRRect(
    WidgetSchema schema,
    BuildContext context,
    SchemaParser parser,
  ) {
    final props = schema.props ?? {};

    Clip clipBehavior = Clip.antiAlias;
    switch (props['clipBehavior'] as String?) {
      case 'hardEdge':
        clipBehavior = Clip.hardEdge;
        break;
      case 'antiAliasWithSaveLayer':
        clipBehavior = Clip.antiAliasWithSaveLayer;
        break;
      case 'none':
        clipBehavior = Clip.none;
        break;
    }

    return ClipRRect(
      borderRadius: SchemaConverters.toBorderRadius(props['borderRadius']) ??
          BorderRadius.circular(
            SchemaConverters.toDouble(props['borderRadius']) ?? 0.0,
          ),
      clipBehavior: clipBehavior,
      child: schema.child != null
          ? parser.parse(schema.child!, context)
          : const SizedBox.shrink(),
    );
  }

  /// [FloatingActionButton] — circular action button, typically placed in
  /// [Scaffold.floatingActionButton].
  ///
  /// Props: `icon` (icon name), `label` (string — switches to extended FAB),
  /// `tooltip`, `backgroundColor`, `foregroundColor`, `elevation`,
  /// `mini` (bool, default `false`).
  ///
  /// `action` — executed on press.
  static Widget buildFloatingActionButton(
    WidgetSchema schema,
    BuildContext context,
    SchemaParser parser,
  ) {
    final props = schema.props ?? {};
    final actionMap = toStringKeyedMap(schema.action);

    final VoidCallback onPressed = actionMap != null
        ? () => parser.createActionHandler(context).executeFromMap(actionMap)
        : () => BduiLogger.debug('FloatingActionButton pressed');

    final iconData = SchemaConverters.toIconData(props['icon']);
    final label = props['label'] as String?;
    final backgroundColor = SchemaConverters.toColor(props['backgroundColor']);
    final foregroundColor = SchemaConverters.toColor(props['foregroundColor']);
    final elevation = SchemaConverters.toDouble(props['elevation']);
    final tooltip = props['tooltip'] as String?;

    // heroTag — when the user provides 'heroTag' in props, pass it through so
    // multiple FABs can coexist (use 'null' string to disable Hero animation).
    // When the prop is absent, omit heroTag entirely so Flutter's default
    // _DefaultHeroTag is used and a single FAB still participates in Hero.
    final heroTagRaw = props['heroTag'];
    final bool hasHeroTag = heroTagRaw != null;
    final Object? heroTag =
        heroTagRaw == 'null' ? null : heroTagRaw?.toString();

    if (label != null) {
      return hasHeroTag
          ? FloatingActionButton.extended(
              onPressed: onPressed,
              heroTag: heroTag,
              label: Text(label),
              icon: iconData != null ? Icon(iconData) : null,
              backgroundColor: backgroundColor,
              foregroundColor: foregroundColor,
              elevation: elevation,
              tooltip: tooltip,
            )
          : FloatingActionButton.extended(
              onPressed: onPressed,
              label: Text(label),
              icon: iconData != null ? Icon(iconData) : null,
              backgroundColor: backgroundColor,
              foregroundColor: foregroundColor,
              elevation: elevation,
              tooltip: tooltip,
            );
    }

    return hasHeroTag
        ? FloatingActionButton(
            onPressed: onPressed,
            heroTag: heroTag,
            mini: props['mini'] as bool? ?? false,
            backgroundColor: backgroundColor,
            foregroundColor: foregroundColor,
            elevation: elevation,
            tooltip: tooltip,
            child: iconData != null ? Icon(iconData) : null,
          )
        : FloatingActionButton(
            onPressed: onPressed,
            mini: props['mini'] as bool? ?? false,
            backgroundColor: backgroundColor,
            foregroundColor: foregroundColor,
            elevation: elevation,
            tooltip: tooltip,
            child: iconData != null ? Icon(iconData) : null,
          );
  }

  /// [ExpansionTile] — a tile that expands to reveal its children.
  ///
  /// Props: `title` (string), `subtitle` (string),
  /// `initiallyExpanded` (bool, default `false`),
  /// `maintainState` (bool, default `false`),
  /// `backgroundColor` (when expanded), `collapsedBackgroundColor`,
  /// `textColor` (when expanded), `collapsedTextColor`,
  /// `iconColor` (when expanded), `collapsedIconColor`,
  /// `tilePadding`, `childrenPadding`.
  ///
  /// Named slots (via `props`): `leading`, `trailing`.
  /// `children` — widgets revealed on expand.
  /// `action` — fired on expand/collapse (receives no arguments).
  static Widget buildExpansionTile(
    WidgetSchema schema,
    BuildContext context,
    SchemaParser parser,
  ) {
    final props = schema.props ?? {};

    Widget? parseSlot(dynamic slotValue) {
      if (slotValue is! Map) return null;
      try {
        final map = slotValue.map((k, v) => MapEntry(k.toString(), v));
        return parser.parse(WidgetSchema.fromJson(map), context);
      } catch (_) {
        return null;
      }
    }

    final actionMap = toStringKeyedMap(schema.action);

    return ExpansionTile(
      title: Text(props['title']?.toString() ?? ''),
      subtitle: props['subtitle'] != null
          ? Text(props['subtitle'].toString())
          : null,
      leading: parseSlot(props['leading']),
      trailing: parseSlot(props['trailing']),
      initiallyExpanded: props['initiallyExpanded'] as bool? ?? false,
      maintainState: props['maintainState'] as bool? ?? false,
      backgroundColor: SchemaConverters.toColor(props['backgroundColor']),
      collapsedBackgroundColor:
          SchemaConverters.toColor(props['collapsedBackgroundColor']),
      textColor: SchemaConverters.toColor(props['textColor']),
      collapsedTextColor: SchemaConverters.toColor(props['collapsedTextColor']),
      iconColor: SchemaConverters.toColor(props['iconColor']),
      collapsedIconColor: SchemaConverters.toColor(props['collapsedIconColor']),
      tilePadding: SchemaConverters.toEdgeInsets(props['tilePadding']),
      childrenPadding: SchemaConverters.toEdgeInsets(props['childrenPadding']),
      dense: props['dense'] as bool? ?? false,
      enableFeedback: props['enableFeedback'] as bool?,
      expandedAlignment: SchemaConverters.toAlignment(props['expandedAlignment']),
      onExpansionChanged: actionMap != null
          ? (_) => parser.createActionHandler(context).executeFromMap(actionMap)
          : null,
      children:
          schema.children?.map((c) => parser.parse(c, context)).toList() ?? [],
    );
  }
}
