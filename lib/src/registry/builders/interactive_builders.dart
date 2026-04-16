import 'package:flutter/material.dart';

import '../../models/widget_schema.dart';
import '../../parser/schema_parser.dart';
import '../../utils/bdui_logger.dart';
import '../../utils/helpers.dart';
import '../../utils/schema_converters.dart';

/// Builders for interactive widgets: Button variants, IconButton,
/// GestureDetector, InkWell.
class InteractiveBuilders {
  static Widget buildButton(
    WidgetSchema schema,
    BuildContext context,
    SchemaParser parser, {
    String buttonType = 'elevated',
  }) {
    final props = schema.props ?? {};
    final text = props['text']?.toString() ?? '';

    VoidCallback? onPressed;
    if (props['disabled'] == true) {
      onPressed = null;
    } else {
      final actionMap = toStringKeyedMap(schema.action);
      if (actionMap != null) {
        onPressed = () => _executeAction(actionMap, context, parser);
      } else {
        onPressed = () => BduiLogger.debug('Button pressed: $text');
      }
    }

    final child = props['icon'] != null
        ? Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                SchemaConverters.toIconData(props['icon']),
                size: SchemaConverters.toDouble(props['iconSize']) ?? 18,
              ),
              if (text.isNotEmpty) ...[
                const SizedBox(width: 8),
                Text(text),
              ],
            ],
          )
        : Text(text);

    switch (buttonType) {
      case 'text':
        return TextButton(
          onPressed: onPressed,
          style: TextButton.styleFrom(
            foregroundColor: SchemaConverters.toColor(props['color']),
          ),
          child: child,
        );
      case 'outlined':
        return OutlinedButton(
          onPressed: onPressed,
          style: OutlinedButton.styleFrom(
            foregroundColor: SchemaConverters.toColor(props['color']),
          ),
          child: child,
        );
      default:
        return ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: SchemaConverters.toColor(props['backgroundColor']),
            foregroundColor: SchemaConverters.toColor(props['color']),
          ),
          child: child,
        );
    }
  }

  static Widget buildIconButton(
    WidgetSchema schema,
    BuildContext context,
    SchemaParser parser,
  ) {
    final props = schema.props ?? {};

    VoidCallback? onPressed;
    if (props['disabled'] == true) {
      onPressed = null;
    } else {
      final actionMap = toStringKeyedMap(schema.action);
      if (actionMap != null) {
        onPressed = () => _executeAction(actionMap, context, parser);
      } else {
        onPressed = () => BduiLogger.debug('IconButton pressed');
      }
    }

    return IconButton(
      onPressed: onPressed,
      icon: Icon(
        SchemaConverters.toIconData(props['icon']),
        color: SchemaConverters.toColor(props['color']),
        size: SchemaConverters.toDouble(props['size']),
      ),
    );
  }

  static Widget buildGestureDetector(
    WidgetSchema schema,
    BuildContext context,
    SchemaParser parser,
  ) {
    final props = schema.props ?? {};
    final actionMap = toStringKeyedMap(schema.action);

    VoidCallback? onTapHandler;
    if (actionMap != null) {
      onTapHandler = () => _executeAction(actionMap, context, parser);
    } else if (props['onTap'] != null) {
      onTapHandler = () => BduiLogger.debug('GestureDetector tapped');
    }

    final doubleTapAction = toStringKeyedMap(props['onDoubleTap']);
    final longPressAction = toStringKeyedMap(props['onLongPress']);

    return GestureDetector(
      onTap: onTapHandler,
      onDoubleTap: doubleTapAction != null
          ? () => _executeAction(doubleTapAction, context, parser)
          : (props['onDoubleTap'] != null
              ? () => BduiLogger.debug('GestureDetector double tapped')
              : null),
      onLongPress: longPressAction != null
          ? () => _executeAction(longPressAction, context, parser)
          : (props['onLongPress'] != null
              ? () => BduiLogger.debug('GestureDetector long pressed')
              : null),
      child: schema.child != null
          ? parser.parse(schema.child!, context)
          : const SizedBox.shrink(),
    );
  }

  static Widget buildInkWell(
    WidgetSchema schema,
    BuildContext context,
    SchemaParser parser,
  ) {
    final props = schema.props ?? {};
    final actionMap = toStringKeyedMap(schema.action);

    VoidCallback? onTapHandler;
    if (actionMap != null) {
      onTapHandler = () => _executeAction(actionMap, context, parser);
    } else if (props['onTap'] != null) {
      onTapHandler = () => BduiLogger.debug('InkWell tapped');
    }

    final doubleTapAction = toStringKeyedMap(props['onDoubleTap']);
    final longPressAction = toStringKeyedMap(props['onLongPress']);

    return InkWell(
      onTap: onTapHandler,
      onDoubleTap: doubleTapAction != null
          ? () => _executeAction(doubleTapAction, context, parser)
          : (props['onDoubleTap'] != null
              ? () => BduiLogger.debug('InkWell double tapped')
              : null),
      onLongPress: longPressAction != null
          ? () => _executeAction(longPressAction, context, parser)
          : (props['onLongPress'] != null
              ? () => BduiLogger.debug('InkWell long pressed')
              : null),
      borderRadius: SchemaConverters.toBorderRadius(props['borderRadius']),
      child: schema.child != null
          ? parser.parse(schema.child!, context)
          : const SizedBox.shrink(),
    );
  }

  static void _executeAction(
    Map<String, dynamic> action,
    BuildContext context,
    SchemaParser parser,
  ) {
    parser.createActionHandler(context).executeFromMap(action);
  }
}
