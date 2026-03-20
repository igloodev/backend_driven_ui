import 'package:flutter/material.dart';

import '../handlers/action_handler.dart';
import '../models/widget_schema.dart';
import '../parser/schema_parser.dart';
import '../utils/helpers.dart';
import '../utils/logger.dart';

/// Built-in widget builders
class BuiltinWidgets {
  /// Register all built-in widgets
  static Map<String, Widget Function(WidgetSchema, BuildContext)> getBuilders(
    SchemaParser parser,
  ) {
    return {
      // Basic widgets
      'Text': (schema, context) => _buildText(schema),
      'Icon': (schema, context) => _buildIcon(schema),
      'Image': (schema, context) => _buildImage(schema),
      'Divider': (schema, context) => _buildDivider(schema),

      // Layout widgets
      'Container': (schema, context) => _buildContainer(schema, context, parser),
      'Column': (schema, context) => _buildColumn(schema, context, parser),
      'Row': (schema, context) => _buildRow(schema, context, parser),
      'Stack': (schema, context) => _buildStack(schema, context, parser),
      'Padding': (schema, context) => _buildPadding(schema, context, parser),
      'Center': (schema, context) => _buildCenter(schema, context, parser),
      'SizedBox': (schema, context) => _buildSizedBox(schema, context, parser),
      'Expanded': (schema, context) => _buildExpanded(schema, context, parser),
      'Flexible': (schema, context) => _buildFlexible(schema, context, parser),
      'Wrap': (schema, context) => _buildWrap(schema, context, parser),
      'Spacer': (schema, context) => _buildSpacer(schema),
      'AspectRatio': (schema, context) => _buildAspectRatio(schema, context, parser),

      // Material widgets
      'Card': (schema, context) => _buildCard(schema, context, parser),
      'ListTile': (schema, context) => _buildListTile(schema, context, parser),
      'CircleAvatar': (schema, context) => _buildCircleAvatar(schema, context, parser),
      'Chip': (schema, context) => _buildChip(schema),
      'ClipRRect': (schema, context) => _buildClipRRect(schema, context, parser),

      // Interactive widgets
      'Button': (schema, context) => _buildButton(schema, context),
      'ElevatedButton': (schema, context) => _buildButton(schema, context, buttonType: 'elevated'),
      'TextButton': (schema, context) => _buildButton(schema, context, buttonType: 'text'),
      'OutlinedButton': (schema, context) => _buildButton(schema, context, buttonType: 'outlined'),
      'IconButton': (schema, context) => _buildIconButton(schema, context),
      'GestureDetector': (schema, context) => _buildGestureDetector(schema, context, parser),
      'InkWell': (schema, context) => _buildInkWell(schema, context, parser),

      // Scrollable widgets (lightweight - lazy loading)
      'ListView': (schema, context) => _buildListView(schema, context, parser),
      'GridView': (schema, context) => _buildGridView(schema, context, parser),
      'SingleChildScrollView': (schema, context) => _buildSingleChildScrollView(schema, context, parser),

      // Visibility & Effects (fast, minimal overhead)
      'Visibility': (schema, context) => _buildVisibility(schema, context, parser),
      'Opacity': (schema, context) => _buildOpacity(schema, context, parser),
    };
  }

  static Widget _buildText(WidgetSchema schema) {
    final props = schema.props ?? {};
    return Text(
      props['text']?.toString() ?? '',
      style: TextStyle(
        fontSize: _toDouble(props['fontSize']),
        fontWeight: _toFontWeight(props['fontWeight']),
        color: _toColor(props['color']),
        backgroundColor: _toColor(props['backgroundColor']),
        letterSpacing: _toDouble(props['letterSpacing']),
        wordSpacing: _toDouble(props['wordSpacing']),
        height: _toDouble(props['lineHeight']),
        fontStyle: props['fontStyle'] == 'italic' ? FontStyle.italic : null,
        decoration: _toTextDecoration(props['decoration']),
        decorationColor: _toColor(props['decorationColor']),
        decorationStyle: _toTextDecorationStyle(props['decorationStyle']),
        decorationThickness: _toDouble(props['decorationThickness']),
        fontFamily: props['fontFamily'] as String?,
      ),
      textAlign: _toTextAlign(props['align']),
      maxLines: props['maxLines'] as int?,
      overflow: _toTextOverflow(props['overflow']),
      softWrap: props['softWrap'] as bool?,
      textDirection: _toTextDirection(props['textDirection']),
    );
  }

  static Widget _buildContainer(
    WidgetSchema schema,
    BuildContext context,
    SchemaParser parser,
  ) {
    final props = schema.props ?? {};

    // Build BoxDecoration
    BoxDecoration? decoration;
    if (props['color'] != null ||
        props['gradient'] != null ||
        props['borderRadius'] != null ||
        props['border'] != null ||
        props['boxShadow'] != null ||
        props['image'] != null ||
        props['backgroundImage'] != null) {
      // Validate background image URL if present
      DecorationImage? backgroundImage;
      final bgImageUrl = props['backgroundImage'] as String?;
      if (bgImageUrl != null) {
        if (ActionHandler.isUrlSafe(bgImageUrl)) {
          backgroundImage = DecorationImage(
            image: NetworkImage(bgImageUrl),
            fit: _toBoxFit(props['backgroundFit']),
          );
        } else {
          BduiLogger.warn('Container backgroundImage blocked: URL failed security validation: $bgImageUrl');
        }
      }

      decoration = BoxDecoration(
        color: props['gradient'] == null ? _toColor(props['color']) : null,
        gradient: _toGradient(props['gradient']),
        borderRadius: _toBorderRadius(props['borderRadius']),
        border: props['border'] != null
            ? Border.all(
                color: _toColor(props['borderColor']) ?? Colors.black,
                width: _toDouble(props['borderWidth']) ?? 1.0,
              )
            : null,
        boxShadow: _toBoxShadow(props['boxShadow']),
        image: backgroundImage,
      );
    }

    return Container(
      width: _toDouble(props['width']),
      height: _toDouble(props['height']),
      padding: _toEdgeInsets(props['padding']),
      margin: _toEdgeInsets(props['margin']),
      alignment: _toAlignment(props['alignment']),
      decoration: decoration,
      transform: _toMatrix4(props['transform']),
      child: schema.child != null ? parser.parse(schema.child!, context) : null,
    );
  }

  static Widget _buildColumn(
    WidgetSchema schema,
    BuildContext context,
    SchemaParser parser,
  ) {
    final props = schema.props ?? {};
    return Column(
      mainAxisAlignment: _toMainAxisAlignment(props['mainAxisAlignment']),
      crossAxisAlignment: _toCrossAxisAlignment(props['crossAxisAlignment']),
      mainAxisSize: _toMainAxisSize(props['mainAxisSize']),
      children: schema.children
              ?.map((child) => parser.parse(child, context))
              .toList() ??
          [],
    );
  }

  static Widget _buildRow(
    WidgetSchema schema,
    BuildContext context,
    SchemaParser parser,
  ) {
    final props = schema.props ?? {};
    return Row(
      mainAxisAlignment: _toMainAxisAlignment(props['mainAxisAlignment']),
      crossAxisAlignment: _toCrossAxisAlignment(props['crossAxisAlignment']),
      mainAxisSize: _toMainAxisSize(props['mainAxisSize']),
      children: schema.children
              ?.map((child) => parser.parse(child, context))
              .toList() ??
          [],
    );
  }

  static Widget _buildStack(
    WidgetSchema schema,
    BuildContext context,
    SchemaParser parser,
  ) {
    return Stack(
      children: schema.children
              ?.map((child) => parser.parse(child, context))
              .toList() ??
          [],
    );
  }

  static Widget _buildPadding(
    WidgetSchema schema,
    BuildContext context,
    SchemaParser parser,
  ) {
    final props = schema.props ?? {};
    return Padding(
      padding: _toEdgeInsets(props['padding']) ?? EdgeInsets.zero,
      child: schema.child != null ? parser.parse(schema.child!, context) : null,
    );
  }

  static Widget _buildCenter(
    WidgetSchema schema,
    BuildContext context,
    SchemaParser parser,
  ) {
    return Center(
      child: schema.child != null ? parser.parse(schema.child!, context) : null,
    );
  }

  static Widget _buildSizedBox(
    WidgetSchema schema,
    BuildContext context,
    SchemaParser parser,
  ) {
    final props = schema.props ?? {};
    return SizedBox(
      width: _toDouble(props['width']),
      height: _toDouble(props['height']),
      child: schema.child != null ? parser.parse(schema.child!, context) : null,
    );
  }

  static Widget _buildDivider(WidgetSchema schema) {
    final props = schema.props ?? {};
    return Divider(
      height: _toDouble(props['height']),
      thickness: _toDouble(props['thickness']),
      color: _toColor(props['color']),
    );
  }

  static Widget _buildIcon(WidgetSchema schema) {
    final props = schema.props ?? {};
    return Icon(
      _toIconData(props['icon']),
      size: _toDouble(props['size']),
      color: _toColor(props['color']),
    );
  }

  static Widget _buildImage(WidgetSchema schema) {
    final props = schema.props ?? {};
    final url = props['url'] as String?;

    if (url == null) {
      return const SizedBox.shrink();
    }

    // Security: Validate URL before loading
    if (!ActionHandler.isUrlSafe(url)) {
      BduiLogger.warn('Image blocked: URL failed security validation: $url');
      return Container(
        width: _toDouble(props['width']),
        height: _toDouble(props['height']),
        color: Colors.grey[200],
        child: const Center(
          child: Icon(Icons.block, color: Colors.red),
        ),
      );
    }

    return Image.network(
      url,
      width: _toDouble(props['width']),
      height: _toDouble(props['height']),
      fit: _toBoxFit(props['fit']),
      errorBuilder: (context, error, stackTrace) {
        return Container(
          width: _toDouble(props['width']),
          height: _toDouble(props['height']),
          color: Colors.grey[200],
          child: const Center(
            child: Icon(Icons.broken_image, color: Colors.grey),
          ),
        );
      },
    );
  }

  // Helper converters
  static double? _toDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

  static Color? _toColor(dynamic value) {
    if (value == null) return null;

    // Handle int (normal case)
    if (value is int) return Color(value);

    // Handle double (happens when number exceeds int.max in JSON)
    if (value is double) {
      // Clamp to valid color range and convert to int
      final clamped = value.clamp(0, 0xFFFFFFFF).toInt();
      return Color(clamped);
    }

    // Handle String (hex color codes)
    if (value is String) {
      if (value.startsWith('#')) {
        try {
          final hex = value.substring(1);
          if (hex.length == 6) {
            // RGB format: #RRGGBB - add full alpha
            return Color(int.parse(hex, radix: 16) + 0xFF000000);
          } else if (hex.length == 8) {
            // ARGB format: #AARRGGBB - use as-is
            return Color(int.parse(hex, radix: 16));
          }
          return null;
        } catch (e) {
          return null;
        }
      }
      // Try parsing as plain int
      final parsed = int.tryParse(value);
      if (parsed != null) return Color(parsed);
    }

    return null;
  }

  static EdgeInsets? _toEdgeInsets(dynamic value) {
    if (value == null) return null;
    if (value is num) return EdgeInsets.all(value.toDouble());
    if (value is Map) {
      // Support all EdgeInsets variants
      if (value['all'] != null) {
        return EdgeInsets.all(_toDouble(value['all'])!);
      }
      if (value['horizontal'] != null || value['vertical'] != null) {
        return EdgeInsets.symmetric(
          horizontal: _toDouble(value['horizontal']) ?? 0.0,
          vertical: _toDouble(value['vertical']) ?? 0.0,
        );
      }
      // Individual sides
      return EdgeInsets.only(
        left: _toDouble(value['left']) ?? 0.0,
        top: _toDouble(value['top']) ?? 0.0,
        right: _toDouble(value['right']) ?? 0.0,
        bottom: _toDouble(value['bottom']) ?? 0.0,
      );
    }
    return null;
  }

  static FontWeight? _toFontWeight(dynamic value) {
    if (value == null) return null;
    if (value == 'bold') return FontWeight.bold;
    if (value is int) {
      return FontWeight.values[(value ~/ 100 - 1).clamp(0, 8)];
    }
    return null;
  }

  static TextAlign? _toTextAlign(dynamic value) {
    if (value == null) return null;
    switch (value) {
      case 'left':
        return TextAlign.left;
      case 'right':
        return TextAlign.right;
      case 'center':
        return TextAlign.center;
      case 'justify':
        return TextAlign.justify;
      default:
        return null;
    }
  }

  static TextOverflow? _toTextOverflow(dynamic value) {
    if (value == null) return null;
    switch (value) {
      case 'ellipsis':
        return TextOverflow.ellipsis;
      case 'fade':
        return TextOverflow.fade;
      case 'clip':
        return TextOverflow.clip;
      default:
        return null;
    }
  }

  static MainAxisAlignment _toMainAxisAlignment(dynamic value) {
    switch (value) {
      case 'start':
        return MainAxisAlignment.start;
      case 'end':
        return MainAxisAlignment.end;
      case 'center':
        return MainAxisAlignment.center;
      case 'spaceBetween':
        return MainAxisAlignment.spaceBetween;
      case 'spaceAround':
        return MainAxisAlignment.spaceAround;
      case 'spaceEvenly':
        return MainAxisAlignment.spaceEvenly;
      default:
        return MainAxisAlignment.start;
    }
  }

  static CrossAxisAlignment _toCrossAxisAlignment(dynamic value) {
    switch (value) {
      case 'start':
        return CrossAxisAlignment.start;
      case 'end':
        return CrossAxisAlignment.end;
      case 'center':
        return CrossAxisAlignment.center;
      case 'stretch':
        return CrossAxisAlignment.stretch;
      default:
        return CrossAxisAlignment.start;
    }
  }

  static MainAxisSize _toMainAxisSize(dynamic value) {
    switch (value) {
      case 'min':
        return MainAxisSize.min;
      case 'max':
        return MainAxisSize.max;
      default:
        return MainAxisSize.max;
    }
  }

  static IconData? _toIconData(dynamic value) {
    if (value == null) return null;
    // Map common icon names to IconData
    switch (value) {
      case 'home':
        return Icons.home;
      case 'search':
        return Icons.search;
      case 'settings':
        return Icons.settings;
      case 'person':
        return Icons.person;
      case 'favorite':
        return Icons.favorite;
      case 'star':
        return Icons.star;
      case 'error':
        return Icons.error;
      case 'check':
        return Icons.check;
      default:
        return Icons.help_outline;
    }
  }

  static BoxFit? _toBoxFit(dynamic value) {
    switch (value) {
      case 'contain':
        return BoxFit.contain;
      case 'cover':
        return BoxFit.cover;
      case 'fill':
        return BoxFit.fill;
      case 'fitWidth':
        return BoxFit.fitWidth;
      case 'fitHeight':
        return BoxFit.fitHeight;
      default:
        return null;
    }
  }

  // New layout widgets
  static Widget _buildExpanded(
    WidgetSchema schema,
    BuildContext context,
    SchemaParser parser,
  ) {
    final props = schema.props ?? {};
    return Expanded(
      flex: props['flex'] as int? ?? 1,
      child: schema.child != null ? parser.parse(schema.child!, context) : const SizedBox.shrink(),
    );
  }

  static Widget _buildFlexible(
    WidgetSchema schema,
    BuildContext context,
    SchemaParser parser,
  ) {
    final props = schema.props ?? {};
    return Flexible(
      flex: props['flex'] as int? ?? 1,
      fit: props['fit'] == 'loose' ? FlexFit.loose : FlexFit.tight,
      child: schema.child != null ? parser.parse(schema.child!, context) : const SizedBox.shrink(),
    );
  }

  static Widget _buildWrap(
    WidgetSchema schema,
    BuildContext context,
    SchemaParser parser,
  ) {
    final props = schema.props ?? {};
    return Wrap(
      spacing: _toDouble(props['spacing']) ?? 0.0,
      runSpacing: _toDouble(props['runSpacing']) ?? 0.0,
      alignment: _toWrapAlignment(props['alignment']),
      children: schema.children
              ?.map((child) => parser.parse(child, context))
              .toList() ??
          [],
    );
  }

  static Widget _buildSpacer(WidgetSchema schema) {
    final props = schema.props ?? {};
    return Spacer(flex: props['flex'] as int? ?? 1);
  }

  static Widget _buildAspectRatio(
    WidgetSchema schema,
    BuildContext context,
    SchemaParser parser,
  ) {
    final props = schema.props ?? {};
    var ratio = _toDouble(props['ratio']) ?? 1.0;

    // Validate ratio to prevent Flutter errors
    // Must be positive and reasonable (between 0.1 and 10)
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
      child: schema.child != null ? parser.parse(schema.child!, context) : const SizedBox.shrink(),
    );
  }

  // Material widgets
  static Widget _buildCard(
    WidgetSchema schema,
    BuildContext context,
    SchemaParser parser,
  ) {
    final props = schema.props ?? {};
    return Card(
      color: _toColor(props['color']),
      elevation: _toDouble(props['elevation']),
      margin: _toEdgeInsets(props['margin']),
      shape: props['borderRadius'] != null
          ? RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(_toDouble(props['borderRadius'])!),
            )
          : null,
      child: schema.child != null ? parser.parse(schema.child!, context) : null,
    );
  }

  static Widget _buildListTile(
    WidgetSchema schema,
    BuildContext context,
    SchemaParser parser,
  ) {
    final props = schema.props ?? {};

    Widget? leading;
    if (schema.props?['leading'] != null) {
      final leadingMap = toStringKeyedMap(schema.props!['leading']);
      if (leadingMap != null) {
        leading = parser.parse(WidgetSchema.fromJson(leadingMap), context);
      }
    }

    Widget? trailing;
    if (schema.props?['trailing'] != null) {
      final trailingMap = toStringKeyedMap(schema.props!['trailing']);
      if (trailingMap != null) {
        trailing = parser.parse(WidgetSchema.fromJson(trailingMap), context);
      }
    }

    return ListTile(
      leading: leading,
      trailing: trailing,
      title: props['title'] != null ? Text(props['title'].toString()) : null,
      subtitle: props['subtitle'] != null ? Text(props['subtitle'].toString()) : null,
      dense: props['dense'] as bool? ?? false,
      contentPadding: _toEdgeInsets(props['contentPadding']),
    );
  }

  static Widget _buildCircleAvatar(
    WidgetSchema schema,
    BuildContext context,
    SchemaParser parser,
  ) {
    final props = schema.props ?? {};
    final imageUrl = props['imageUrl'] as String?;
    final radius = _toDouble(props['radius']);
    final backgroundColor = _toColor(props['backgroundColor']);

    if (imageUrl != null) {
      // Security: Validate URL before loading
      if (!ActionHandler.isUrlSafe(imageUrl)) {
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

  static Widget _buildChip(WidgetSchema schema) {
    final props = schema.props ?? {};
    return Chip(
      label: Text(props['label']?.toString() ?? ''),
      backgroundColor: _toColor(props['backgroundColor']),
      avatar: props['avatar'] != null
          ? Icon(_toIconData(props['avatar']))
          : null,
      deleteIcon: props['deleteIcon'] != null
          ? Icon(_toIconData(props['deleteIcon']))
          : null,
    );
  }

  static Widget _buildClipRRect(
    WidgetSchema schema,
    BuildContext context,
    SchemaParser parser,
  ) {
    final props = schema.props ?? {};
    return ClipRRect(
      borderRadius: BorderRadius.circular(_toDouble(props['borderRadius']) ?? 0.0),
      child: schema.child != null ? parser.parse(schema.child!, context) : const SizedBox.shrink(),
    );
  }

  // Interactive widgets (optimized - minimal overhead)
  static Widget _buildButton(
    WidgetSchema schema,
    BuildContext context, {
    String buttonType = 'elevated',
  }) {
    final props = schema.props ?? {};
    final action = schema.action;
    final text = props['text']?.toString() ?? '';

    // Create press handler based on action or disabled state
    VoidCallback? onPressed;
    if (props['disabled'] == true) {
      onPressed = null;
    } else {
      final actionMap = toStringKeyedMap(action);
      if (actionMap != null) {
        onPressed = () => _executeAction(actionMap, context);
      } else {
        onPressed = () => BduiLogger.debug('Button pressed: $text');
      }
    }

    final child = props['icon'] != null
        ? Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(_toIconData(props['icon']), size: _toDouble(props['iconSize']) ?? 18),
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
            foregroundColor: _toColor(props['color']),
          ),
          child: child,
        );
      case 'outlined':
        return OutlinedButton(
          onPressed: onPressed,
          style: OutlinedButton.styleFrom(
            foregroundColor: _toColor(props['color']),
          ),
          child: child,
        );
      default:
        return ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: _toColor(props['backgroundColor']),
            foregroundColor: _toColor(props['color']),
          ),
          child: child,
        );
    }
  }

  static Widget _buildIconButton(WidgetSchema schema, BuildContext context) {
    final props = schema.props ?? {};
    final action = schema.action;

    // Create press handler based on action or disabled state
    VoidCallback? onPressed;
    if (props['disabled'] == true) {
      onPressed = null;
    } else {
      final actionMap = toStringKeyedMap(action);
      if (actionMap != null) {
        onPressed = () => _executeAction(actionMap, context);
      } else {
        onPressed = () => BduiLogger.debug('IconButton pressed');
      }
    }

    return IconButton(
      onPressed: onPressed,
      icon: Icon(
        _toIconData(props['icon']),
        color: _toColor(props['color']),
        size: _toDouble(props['size']),
      ),
    );
  }

  static Widget _buildGestureDetector(
    WidgetSchema schema,
    BuildContext context,
    SchemaParser parser,
  ) {
    final props = schema.props ?? {};
    final action = schema.action;

    // Create tap handler based on action or props
    VoidCallback? onTapHandler;
    final actionMap = toStringKeyedMap(action);
    if (actionMap != null) {
      onTapHandler = () => _executeAction(actionMap, context);
    } else if (props['onTap'] != null) {
      onTapHandler = () => BduiLogger.debug('GestureDetector tapped');
    }

    return GestureDetector(
      onTap: onTapHandler,
      onDoubleTap: props['onDoubleTap'] != null ? () {
        BduiLogger.debug('GestureDetector double tapped');
      } : null,
      onLongPress: props['onLongPress'] != null ? () {
        BduiLogger.debug('GestureDetector long pressed');
      } : null,
      child: schema.child != null ? parser.parse(schema.child!, context) : const SizedBox.shrink(),
    );
  }

  static Widget _buildInkWell(
    WidgetSchema schema,
    BuildContext context,
    SchemaParser parser,
  ) {
    final props = schema.props ?? {};
    final action = schema.action;

    // Create tap handler based on action or props
    VoidCallback? onTapHandler;
    final actionMap = toStringKeyedMap(action);
    if (actionMap != null) {
      onTapHandler = () => _executeAction(actionMap, context);
    } else if (props['onTap'] != null) {
      onTapHandler = () => BduiLogger.debug('InkWell tapped');
    }

    return InkWell(
      onTap: onTapHandler,
      onDoubleTap: props['onDoubleTap'] != null ? () {
        BduiLogger.debug('InkWell double tapped');
      } : null,
      onLongPress: props['onLongPress'] != null ? () {
        BduiLogger.debug('InkWell long pressed');
      } : null,
      borderRadius: _toBorderRadius(props['borderRadius']),
      child: schema.child != null ? parser.parse(schema.child!, context) : const SizedBox.shrink(),
    );
  }

  /// Execute an action using ActionHandler (supports all action types)
  static void _executeAction(Map<String, dynamic> action, BuildContext context) {
    final executor = ActionHandler(context: context);
    executor.executeFromMap(action);
  }

  // Scrollable widgets (optimized with lazy building)
  static Widget _buildListView(
    WidgetSchema schema,
    BuildContext context,
    SchemaParser parser,
  ) {
    final props = schema.props ?? {};
    final children = schema.children;

    if (children == null || children.isEmpty) {
      return const SizedBox.shrink();
    }

    // Lazy loading - only parse visible items
    return ListView.builder(
      shrinkWrap: props['shrinkWrap'] as bool? ?? false,
      physics: props['physics'] == 'never' ? const NeverScrollableScrollPhysics() : null,
      padding: _toEdgeInsets(props['padding']),
      itemCount: children.length,
      itemBuilder: (context, index) {
        final child = children[index];
        // Use id from schema props if available, otherwise use index
        final itemKey = child.props?['id']?.toString() ?? 'item_$index';
        return KeyedSubtree(
          key: ValueKey(itemKey),
          child: parser.parse(child, context),
        );
      },
    );
  }

  static Widget _buildGridView(
    WidgetSchema schema,
    BuildContext context,
    SchemaParser parser,
  ) {
    final props = schema.props ?? {};
    final children = schema.children;
    final crossAxisCount = props['crossAxisCount'] as int? ?? 2;

    if (children == null || children.isEmpty) {
      return const SizedBox.shrink();
    }

    return GridView.builder(
      shrinkWrap: props['shrinkWrap'] as bool? ?? false,
      physics: props['physics'] == 'never' ? const NeverScrollableScrollPhysics() : null,
      padding: _toEdgeInsets(props['padding']),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        mainAxisSpacing: _toDouble(props['mainAxisSpacing']) ?? 0.0,
        crossAxisSpacing: _toDouble(props['crossAxisSpacing']) ?? 0.0,
        childAspectRatio: _toDouble(props['childAspectRatio']) ?? 1.0,
      ),
      itemCount: children.length,
      itemBuilder: (context, index) {
        final child = children[index];
        // Use id from schema props if available, otherwise use index
        final itemKey = child.props?['id']?.toString() ?? 'grid_$index';
        return KeyedSubtree(
          key: ValueKey(itemKey),
          child: parser.parse(child, context),
        );
      },
    );
  }

  static Widget _buildSingleChildScrollView(
    WidgetSchema schema,
    BuildContext context,
    SchemaParser parser,
  ) {
    final props = schema.props ?? {};
    return SingleChildScrollView(
      scrollDirection: props['scrollDirection'] == 'horizontal'
          ? Axis.horizontal
          : Axis.vertical,
      padding: _toEdgeInsets(props['padding']),
      child: schema.child != null ? parser.parse(schema.child!, context) : const SizedBox.shrink(),
    );
  }

  // Visibility & Effects (minimal overhead)
  static Widget _buildVisibility(
    WidgetSchema schema,
    BuildContext context,
    SchemaParser parser,
  ) {
    final props = schema.props ?? {};
    final visible = props['visible'] as bool? ?? true;

    return Visibility(
      visible: visible,
      maintainSize: props['maintainSize'] as bool? ?? false,
      maintainAnimation: props['maintainAnimation'] as bool? ?? false,
      maintainState: props['maintainState'] as bool? ?? false,
      child: schema.child != null ? parser.parse(schema.child!, context) : const SizedBox.shrink(),
    );
  }

  static Widget _buildOpacity(
    WidgetSchema schema,
    BuildContext context,
    SchemaParser parser,
  ) {
    final props = schema.props ?? {};
    return Opacity(
      opacity: _toDouble(props['opacity']) ?? 1.0,
      child: schema.child != null ? parser.parse(schema.child!, context) : const SizedBox.shrink(),
    );
  }

  // Helper converters for new widgets
  static WrapAlignment _toWrapAlignment(dynamic value) {
    switch (value) {
      case 'start':
        return WrapAlignment.start;
      case 'end':
        return WrapAlignment.end;
      case 'center':
        return WrapAlignment.center;
      case 'spaceBetween':
        return WrapAlignment.spaceBetween;
      case 'spaceAround':
        return WrapAlignment.spaceAround;
      case 'spaceEvenly':
        return WrapAlignment.spaceEvenly;
      default:
        return WrapAlignment.start;
    }
  }

  // Text decoration converters
  static TextDecoration? _toTextDecoration(dynamic value) {
    switch (value) {
      case 'underline':
        return TextDecoration.underline;
      case 'lineThrough':
        return TextDecoration.lineThrough;
      case 'overline':
        return TextDecoration.overline;
      case 'none':
        return TextDecoration.none;
      default:
        return null;
    }
  }

  static TextDecorationStyle? _toTextDecorationStyle(dynamic value) {
    switch (value) {
      case 'solid':
        return TextDecorationStyle.solid;
      case 'double':
        return TextDecorationStyle.double;
      case 'dotted':
        return TextDecorationStyle.dotted;
      case 'dashed':
        return TextDecorationStyle.dashed;
      case 'wavy':
        return TextDecorationStyle.wavy;
      default:
        return null;
    }
  }

  static TextDirection? _toTextDirection(dynamic value) {
    switch (value) {
      case 'ltr':
        return TextDirection.ltr;
      case 'rtl':
        return TextDirection.rtl;
      default:
        return null;
    }
  }

  // Container converters
  static Gradient? _toGradient(dynamic value) {
    if (value == null) return null;
    if (value is! Map) return null;

    final type = value['type'] as String?;
    final colors = (value['colors'] as List?)
        ?.map((c) => _toColor(c))
        .whereType<Color>()
        .toList();

    if (colors == null || colors.isEmpty) return null;

    switch (type) {
      case 'linear':
        return LinearGradient(
          colors: colors,
          begin: _toAlignmentGeometry(value['begin']) ?? Alignment.centerLeft,
          end: _toAlignmentGeometry(value['end']) ?? Alignment.centerRight,
          stops: (value['stops'] as List?)?.map((s) => (s as num).toDouble()).toList(),
        );
      case 'radial':
        return RadialGradient(
          colors: colors,
          center: _toAlignmentGeometry(value['center']) ?? Alignment.center,
          radius: _toDouble(value['radius']) ?? 0.5,
          stops: (value['stops'] as List?)?.map((s) => (s as num).toDouble()).toList(),
        );
      case 'sweep':
        return SweepGradient(
          colors: colors,
          center: _toAlignmentGeometry(value['center']) ?? Alignment.center,
          startAngle: _toDouble(value['startAngle']) ?? 0.0,
          endAngle: _toDouble(value['endAngle']) ?? 6.283185307179586,
          stops: (value['stops'] as List?)?.map((s) => (s as num).toDouble()).toList(),
        );
      default:
        return LinearGradient(colors: colors);
    }
  }

  static BorderRadius? _toBorderRadius(dynamic value) {
    if (value == null) return null;
    if (value is num) {
      return BorderRadius.circular(value.toDouble());
    }
    if (value is Map) {
      return BorderRadius.only(
        topLeft: Radius.circular(_toDouble(value['topLeft']) ?? 0.0),
        topRight: Radius.circular(_toDouble(value['topRight']) ?? 0.0),
        bottomLeft: Radius.circular(_toDouble(value['bottomLeft']) ?? 0.0),
        bottomRight: Radius.circular(_toDouble(value['bottomRight']) ?? 0.0),
      );
    }
    return null;
  }

  static List<BoxShadow>? _toBoxShadow(dynamic value) {
    if (value == null) return null;
    if (value is List) {
      return value
          .map((shadow) {
            if (shadow is! Map) return null;
            return BoxShadow(
              color: _toColor(shadow['color']) ?? Colors.black.withAlpha(77),
              offset: Offset(
                _toDouble(shadow['offsetX']) ?? 0.0,
                _toDouble(shadow['offsetY']) ?? 0.0,
              ),
              blurRadius: _toDouble(shadow['blurRadius']) ?? 0.0,
              spreadRadius: _toDouble(shadow['spreadRadius']) ?? 0.0,
            );
          })
          .whereType<BoxShadow>()
          .toList();
    }
    // Single shadow
    if (value is Map) {
      return [
        BoxShadow(
          color: _toColor(value['color']) ?? Colors.black.withAlpha(77),
          offset: Offset(
            _toDouble(value['offsetX']) ?? 0.0,
            _toDouble(value['offsetY']) ?? 2.0,
          ),
          blurRadius: _toDouble(value['blurRadius']) ?? 4.0,
          spreadRadius: _toDouble(value['spreadRadius']) ?? 0.0,
        )
      ];
    }
    return null;
  }

  static Alignment? _toAlignment(dynamic value) {
    return _toAlignmentGeometry(value) as Alignment?;
  }

  static AlignmentGeometry? _toAlignmentGeometry(dynamic value) {
    switch (value) {
      case 'topLeft':
        return Alignment.topLeft;
      case 'topCenter':
        return Alignment.topCenter;
      case 'topRight':
        return Alignment.topRight;
      case 'centerLeft':
        return Alignment.centerLeft;
      case 'center':
        return Alignment.center;
      case 'centerRight':
        return Alignment.centerRight;
      case 'bottomLeft':
        return Alignment.bottomLeft;
      case 'bottomCenter':
        return Alignment.bottomCenter;
      case 'bottomRight':
        return Alignment.bottomRight;
      default:
        return null;
    }
  }

  static Matrix4? _toMatrix4(dynamic value) {
    if (value == null) return null;
    if (value is Map) {
      final matrix = Matrix4.identity();

      // Rotation
      if (value['rotateZ'] != null) {
        matrix.rotateZ(_toDouble(value['rotateZ'])! * 3.141592653589793 / 180.0);
      }
      if (value['rotateX'] != null) {
        matrix.rotateX(_toDouble(value['rotateX'])! * 3.141592653589793 / 180.0);
      }
      if (value['rotateY'] != null) {
        matrix.rotateY(_toDouble(value['rotateY'])! * 3.141592653589793 / 180.0);
      }

      // Scale
      if (value['scale'] != null) {
        final scale = _toDouble(value['scale'])!;
        matrix.multiply(Matrix4.diagonal3Values(scale, scale, scale));
      }
      if (value['scaleX'] != null || value['scaleY'] != null) {
        matrix.multiply(Matrix4.diagonal3Values(
          _toDouble(value['scaleX']) ?? 1.0,
          _toDouble(value['scaleY']) ?? 1.0,
          1.0,
        ));
      }

      // Translate
      if (value['translateX'] != null || value['translateY'] != null) {
        matrix.multiply(Matrix4.translationValues(
          _toDouble(value['translateX']) ?? 0.0,
          _toDouble(value['translateY']) ?? 0.0,
          0.0,
        ));
      }

      return matrix;
    }
    return null;
  }
}
