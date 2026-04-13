import 'package:flutter/material.dart';

import '../handlers/action_handler.dart';
import '../models/widget_schema.dart';
import '../parser/schema_parser.dart';
import '../utils/helpers.dart';
import '../utils/bdui_logger.dart';

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

    // Handle String (hex codes, named colors, Colors.x notation)
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

      // Strip optional 'Colors.' prefix (e.g. 'Colors.black' → 'black')
      final normalized =
          (value.startsWith('Colors.') ? value.substring(7) : value)
              .toLowerCase();

      // Named color lookup
      final named = _namedColors[normalized];
      if (named != null) return named;

      // Try parsing as plain int string
      final parsed = int.tryParse(value);
      if (parsed != null) return Color(parsed);
    }

    return null;
  }

  /// Named color map — supports Flutter color names, Material shade variants,
  /// common CSS color names, and the 'Colors.x' prefix (stripped before lookup).
  ///
  /// Formats accepted (all case-insensitive):
  /// - Base names:   `"red"`, `"blue"`, `"teal"`
  /// - Accent names: `"redAccent"`, `"blueAccent"`
  /// - Shades:       `"red500"`, `"blue700"`, `"grey100"`
  /// - CSS names:    `"navy"`, `"coral"`, `"gold"`, `"crimson"`
  /// - With prefix:  `"Colors.deepPurple"`, `"Colors.red700"`
  static const Map<String, Color> _namedColors = {
    // ── Absolute ──────────────────────────────────────────────────────────────
    'transparent': Colors.transparent,

    // ── Black / White ─────────────────────────────────────────────────────────
    'black': Colors.black,
    'black87': Colors.black87,
    'black54': Colors.black54,
    'black45': Colors.black45,
    'black38': Colors.black38,
    'black26': Colors.black26,
    'black12': Colors.black12,
    'white': Colors.white,
    'white70': Colors.white70,
    'white60': Colors.white60,
    'white54': Colors.white54,
    'white38': Colors.white38,
    'white30': Colors.white30,
    'white24': Colors.white24,
    'white12': Colors.white12,
    'white10': Colors.white10,

    // ── Red ───────────────────────────────────────────────────────────────────
    'red': Colors.red,
    'redaccent': Colors.redAccent,
    'red50':  Color(0xFFFFEBEE),
    'red100': Color(0xFFFFCDD2),
    'red200': Color(0xFFEF9A9A),
    'red300': Color(0xFFE57373),
    'red400': Color(0xFFEF5350),
    'red500': Color(0xFFF44336),
    'red600': Color(0xFFE53935),
    'red700': Color(0xFFD32F2F),
    'red800': Color(0xFFC62828),
    'red900': Color(0xFFB71C1C),
    'redaccent100': Color(0xFFFF8A80),
    'redaccent200': Color(0xFFFF5252),
    'redaccent400': Color(0xFFFF1744),
    'redaccent700': Color(0xFFD50000),

    // ── Pink ──────────────────────────────────────────────────────────────────
    'pink': Colors.pink,
    'pinkaccent': Colors.pinkAccent,
    'pink50':  Color(0xFFFCE4EC),
    'pink100': Color(0xFFF8BBD0),
    'pink200': Color(0xFFF48FB1),
    'pink300': Color(0xFFF06292),
    'pink400': Color(0xFFEC407A),
    'pink500': Color(0xFFE91E63),
    'pink600': Color(0xFFD81B60),
    'pink700': Color(0xFFC2185B),
    'pink800': Color(0xFFAD1457),
    'pink900': Color(0xFF880E4F),
    'pinkaccent100': Color(0xFFFF80AB),
    'pinkaccent200': Color(0xFFFF4081),
    'pinkaccent400': Color(0xFFF50057),
    'pinkaccent700': Color(0xFFC51162),

    // ── Purple ────────────────────────────────────────────────────────────────
    'purple': Colors.purple,
    'purpleaccent': Colors.purpleAccent,
    'purple50':  Color(0xFFF3E5F5),
    'purple100': Color(0xFFE1BEE7),
    'purple200': Color(0xFFCE93D8),
    'purple300': Color(0xFFBA68C8),
    'purple400': Color(0xFFAB47BC),
    'purple500': Color(0xFF9C27B0),
    'purple600': Color(0xFF8E24AA),
    'purple700': Color(0xFF7B1FA2),
    'purple800': Color(0xFF6A1B9A),
    'purple900': Color(0xFF4A148C),
    'purpleaccent100': Color(0xFFEA80FC),
    'purpleaccent200': Color(0xFFE040FB),
    'purpleaccent400': Color(0xFFD500F9),
    'purpleaccent700': Color(0xFFAA00FF),

    // ── Deep Purple ───────────────────────────────────────────────────────────
    'deeppurple': Colors.deepPurple,
    'deeppurpleaccent': Colors.deepPurpleAccent,
    'deeppurple50':  Color(0xFFEDE7F6),
    'deeppurple100': Color(0xFFD1C4E9),
    'deeppurple200': Color(0xFFB39DDB),
    'deeppurple300': Color(0xFF9575CD),
    'deeppurple400': Color(0xFF7E57C2),
    'deeppurple500': Color(0xFF673AB7),
    'deeppurple600': Color(0xFF5E35B1),
    'deeppurple700': Color(0xFF512DA8),
    'deeppurple800': Color(0xFF4527A0),
    'deeppurple900': Color(0xFF311B92),
    'deeppurpleaccent100': Color(0xFFB388FF),
    'deeppurpleaccent200': Color(0xFF7C4DFF),
    'deeppurpleaccent400': Color(0xFF651FFF),
    'deeppurpleaccent700': Color(0xFF6200EA),

    // ── Indigo ────────────────────────────────────────────────────────────────
    'indigo': Colors.indigo,
    'indigoaccent': Colors.indigoAccent,
    'indigo50':  Color(0xFFE8EAF6),
    'indigo100': Color(0xFFC5CAE9),
    'indigo200': Color(0xFF9FA8DA),
    'indigo300': Color(0xFF7986CB),
    'indigo400': Color(0xFF5C6BC0),
    'indigo500': Color(0xFF3F51B5),
    'indigo600': Color(0xFF3949AB),
    'indigo700': Color(0xFF303F9F),
    'indigo800': Color(0xFF283593),
    'indigo900': Color(0xFF1A237E),
    'indigoaccent100': Color(0xFF8C9EFF),
    'indigoaccent200': Color(0xFF536DFE),
    'indigoaccent400': Color(0xFF3D5AFE),
    'indigoaccent700': Color(0xFF304FFE),

    // ── Blue ──────────────────────────────────────────────────────────────────
    'blue': Colors.blue,
    'blueaccent': Colors.blueAccent,
    'blue50':  Color(0xFFE3F2FD),
    'blue100': Color(0xFFBBDEFB),
    'blue200': Color(0xFF90CAF9),
    'blue300': Color(0xFF64B5F6),
    'blue400': Color(0xFF42A5F5),
    'blue500': Color(0xFF2196F3),
    'blue600': Color(0xFF1E88E5),
    'blue700': Color(0xFF1976D2),
    'blue800': Color(0xFF1565C0),
    'blue900': Color(0xFF0D47A1),
    'blueaccent100': Color(0xFF82B1FF),
    'blueaccent200': Color(0xFF448AFF),
    'blueaccent400': Color(0xFF2979FF),
    'blueaccent700': Color(0xFF2962FF),

    // ── Light Blue ────────────────────────────────────────────────────────────
    'lightblue': Colors.lightBlue,
    'lightblueaccent': Colors.lightBlueAccent,
    'lightblue50':  Color(0xFFE1F5FE),
    'lightblue100': Color(0xFFB3E5FC),
    'lightblue200': Color(0xFF81D4FA),
    'lightblue300': Color(0xFF4FC3F7),
    'lightblue400': Color(0xFF29B6F6),
    'lightblue500': Color(0xFF03A9F4),
    'lightblue600': Color(0xFF039BE5),
    'lightblue700': Color(0xFF0288D1),
    'lightblue800': Color(0xFF0277BD),
    'lightblue900': Color(0xFF01579B),
    'lightblueaccent100': Color(0xFF80D8FF),
    'lightblueaccent200': Color(0xFF40C4FF),
    'lightblueaccent400': Color(0xFF00B0FF),
    'lightblueaccent700': Color(0xFF0091EA),

    // ── Cyan ──────────────────────────────────────────────────────────────────
    'cyan': Colors.cyan,
    'cyanaccent': Colors.cyanAccent,
    'cyan50':  Color(0xFFE0F7FA),
    'cyan100': Color(0xFFB2EBF2),
    'cyan200': Color(0xFF80DEEA),
    'cyan300': Color(0xFF4DD0E1),
    'cyan400': Color(0xFF26C6DA),
    'cyan500': Color(0xFF00BCD4),
    'cyan600': Color(0xFF00ACC1),
    'cyan700': Color(0xFF0097A7),
    'cyan800': Color(0xFF00838F),
    'cyan900': Color(0xFF006064),
    'cyanaccent100': Color(0xFF84FFFF),
    'cyanaccent200': Color(0xFF18FFFF),
    'cyanaccent400': Color(0xFF00E5FF),
    'cyanaccent700': Color(0xFF00B8D4),

    // ── Teal ──────────────────────────────────────────────────────────────────
    'teal': Colors.teal,
    'tealaccent': Colors.tealAccent,
    'teal50':  Color(0xFFE0F2F1),
    'teal100': Color(0xFFB2DFDB),
    'teal200': Color(0xFF80CBC4),
    'teal300': Color(0xFF4DB6AC),
    'teal400': Color(0xFF26A69A),
    'teal500': Color(0xFF009688),
    'teal600': Color(0xFF00897B),
    'teal700': Color(0xFF00796B),
    'teal800': Color(0xFF00695C),
    'teal900': Color(0xFF004D40),
    'tealaccent100': Color(0xFFA7FFEB),
    'tealaccent200': Color(0xFF64FFDA),
    'tealaccent400': Color(0xFF1DE9B6),
    'tealaccent700': Color(0xFF00BFA5),

    // ── Green ─────────────────────────────────────────────────────────────────
    'green': Colors.green,
    'greenaccent': Colors.greenAccent,
    'green50':  Color(0xFFE8F5E9),
    'green100': Color(0xFFC8E6C9),
    'green200': Color(0xFFA5D6A7),
    'green300': Color(0xFF81C784),
    'green400': Color(0xFF66BB6A),
    'green500': Color(0xFF4CAF50),
    'green600': Color(0xFF43A047),
    'green700': Color(0xFF388E3C),
    'green800': Color(0xFF2E7D32),
    'green900': Color(0xFF1B5E20),
    'greenaccent100': Color(0xFFCCFF90),
    'greenaccent200': Color(0xFFB2FF59),
    'greenaccent400': Color(0xFF76FF03),
    'greenaccent700': Color(0xFF64DD17),

    // ── Light Green ───────────────────────────────────────────────────────────
    'lightgreen': Colors.lightGreen,
    'lightgreenaccent': Colors.lightGreenAccent,
    'lightgreen50':  Color(0xFFF1F8E9),
    'lightgreen100': Color(0xFFDCEDC8),
    'lightgreen200': Color(0xFFC5E1A5),
    'lightgreen300': Color(0xFFAED581),
    'lightgreen400': Color(0xFF9CCC65),
    'lightgreen500': Color(0xFF8BC34A),
    'lightgreen600': Color(0xFF7CB342),
    'lightgreen700': Color(0xFF689F38),
    'lightgreen800': Color(0xFF558B2F),
    'lightgreen900': Color(0xFF33691E),

    // ── Lime ──────────────────────────────────────────────────────────────────
    'lime': Colors.lime,
    'limeaccent': Colors.limeAccent,
    'lime50':  Color(0xFFF9FBE7),
    'lime100': Color(0xFFF0F4C3),
    'lime200': Color(0xFFE6EE9C),
    'lime300': Color(0xFFDCE775),
    'lime400': Color(0xFFD4E157),
    'lime500': Color(0xFFCDDC39),
    'lime600': Color(0xFFC0CA33),
    'lime700': Color(0xFFAFB42B),
    'lime800': Color(0xFF9E9D24),
    'lime900': Color(0xFF827717),

    // ── Yellow ────────────────────────────────────────────────────────────────
    'yellow': Colors.yellow,
    'yellowaccent': Colors.yellowAccent,
    'yellow50':  Color(0xFFFFFDE7),
    'yellow100': Color(0xFFFFF9C4),
    'yellow200': Color(0xFFFFF59D),
    'yellow300': Color(0xFFFFF176),
    'yellow400': Color(0xFFFFEE58),
    'yellow500': Color(0xFFFFEB3B),
    'yellow600': Color(0xFFFDD835),
    'yellow700': Color(0xFFF9A825),
    'yellow800': Color(0xFFF57F17),
    'yellow900': Color(0xFFF57F17),

    // ── Amber ─────────────────────────────────────────────────────────────────
    'amber': Colors.amber,
    'amberaccent': Colors.amberAccent,
    'amber50':  Color(0xFFFFF8E1),
    'amber100': Color(0xFFFFECB3),
    'amber200': Color(0xFFFFE082),
    'amber300': Color(0xFFFFD54F),
    'amber400': Color(0xFFFFCA28),
    'amber500': Color(0xFFFFC107),
    'amber600': Color(0xFFFFB300),
    'amber700': Color(0xFFFF8F00),
    'amber800': Color(0xFFFF6F00),
    'amber900': Color(0xFFFF6F00),

    // ── Orange ────────────────────────────────────────────────────────────────
    'orange': Colors.orange,
    'orangeaccent': Colors.orangeAccent,
    'orange50':  Color(0xFFFFF3E0),
    'orange100': Color(0xFFFFE0B2),
    'orange200': Color(0xFFFFCC80),
    'orange300': Color(0xFFFFB74D),
    'orange400': Color(0xFFFFA726),
    'orange500': Color(0xFFFF9800),
    'orange600': Color(0xFFFB8C00),
    'orange700': Color(0xFFF57C00),
    'orange800': Color(0xFFEF6C00),
    'orange900': Color(0xFFE65100),
    'orangeaccent100': Color(0xFFFFD180),
    'orangeaccent200': Color(0xFFFFAB40),
    'orangeaccent400': Color(0xFFFF9100),
    'orangeaccent700': Color(0xFFFF6D00),

    // ── Deep Orange ───────────────────────────────────────────────────────────
    'deeporange': Colors.deepOrange,
    'deeporangeaccent': Colors.deepOrangeAccent,
    'deeporange50':  Color(0xFFFBE9E7),
    'deeporange100': Color(0xFFFFCCBC),
    'deeporange200': Color(0xFFFFAB91),
    'deeporange300': Color(0xFFFF8A65),
    'deeporange400': Color(0xFFFF7043),
    'deeporange500': Color(0xFFFF5722),
    'deeporange600': Color(0xFFF4511E),
    'deeporange700': Color(0xFFE64A19),
    'deeporange800': Color(0xFFD84315),
    'deeporange900': Color(0xFFBF360C),
    'deeporangeaccent100': Color(0xFFFF9E80),
    'deeporangeaccent200': Color(0xFFFF6E40),
    'deeporangeaccent400': Color(0xFFFF3D00),
    'deeporangeaccent700': Color(0xFFDD2C00),

    // ── Brown ─────────────────────────────────────────────────────────────────
    'brown': Colors.brown,
    'brown50':  Color(0xFFEFEBE9),
    'brown100': Color(0xFFD7CCC8),
    'brown200': Color(0xFFBCAAA4),
    'brown300': Color(0xFFA1887F),
    'brown400': Color(0xFF8D6E63),
    'brown500': Color(0xFF795548),
    'brown600': Color(0xFF6D4C41),
    'brown700': Color(0xFF5D4037),
    'brown800': Color(0xFF4E342E),
    'brown900': Color(0xFF3E2723),

    // ── Grey ──────────────────────────────────────────────────────────────────
    'grey': Colors.grey,
    'gray': Colors.grey,
    'grey50':  Color(0xFFFAFAFA),
    'grey100': Color(0xFFF5F5F5),
    'grey200': Color(0xFFEEEEEE),
    'grey300': Color(0xFFE0E0E0),
    'grey400': Color(0xFFBDBDBD),
    'grey500': Color(0xFF9E9E9E),
    'grey600': Color(0xFF757575),
    'grey700': Color(0xFF616161),
    'grey800': Color(0xFF424242),
    'grey900': Color(0xFF212121),
    'gray50':  Color(0xFFFAFAFA),
    'gray100': Color(0xFFF5F5F5),
    'gray200': Color(0xFFEEEEEE),
    'gray300': Color(0xFFE0E0E0),
    'gray400': Color(0xFFBDBDBD),
    'gray500': Color(0xFF9E9E9E),
    'gray600': Color(0xFF757575),
    'gray700': Color(0xFF616161),
    'gray800': Color(0xFF424242),
    'gray900': Color(0xFF212121),

    // ── Blue Grey ─────────────────────────────────────────────────────────────
    'bluegrey': Colors.blueGrey,
    'bluegray': Colors.blueGrey,
    'bluegrey50':  Color(0xFFECEFF1),
    'bluegrey100': Color(0xFFCFD8DC),
    'bluegrey200': Color(0xFFB0BEC5),
    'bluegrey300': Color(0xFF90A4AE),
    'bluegrey400': Color(0xFF78909C),
    'bluegrey500': Color(0xFF607D8B),
    'bluegrey600': Color(0xFF546E7A),
    'bluegrey700': Color(0xFF455A64),
    'bluegrey800': Color(0xFF37474F),
    'bluegrey900': Color(0xFF263238),
    'bluegray50':  Color(0xFFECEFF1),
    'bluegray100': Color(0xFFCFD8DC),
    'bluegray200': Color(0xFFB0BEC5),
    'bluegray300': Color(0xFF90A4AE),
    'bluegray400': Color(0xFF78909C),
    'bluegray500': Color(0xFF607D8B),
    'bluegray600': Color(0xFF546E7A),
    'bluegray700': Color(0xFF455A64),
    'bluegray800': Color(0xFF37474F),
    'bluegray900': Color(0xFF263238),

    // ── CSS / Common color names ───────────────────────────────────────────────
    'aqua':        Color(0xFF00FFFF), // = cyan
    'fuchsia':     Color(0xFFFF00FF),
    'magenta':     Color(0xFFFF00FF),
    'navy':        Color(0xFF001F5B),
    'maroon':      Color(0xFF800000),
    'olive':       Color(0xFF808000),
    'silver':      Color(0xFFC0C0C0),
    'gold':        Color(0xFFFFD700),
    'coral':       Color(0xFFFF7F50),
    'salmon':      Color(0xFFFA8072),
    'crimson':     Color(0xFFDC143C),
    'scarlet':     Color(0xFFFF2400),
    'violet':      Color(0xFFEE82EE),
    'lavender':    Color(0xFFE6E6FA),
    'khaki':       Color(0xFFF0E68C),
    'turquoise':   Color(0xFF40E0D0),
    'skyblue':     Color(0xFF87CEEB),
    'chocolate':   Color(0xFFD2691E),
    'tan':         Color(0xFFD2B48C),
    'beige':       Color(0xFFF5F5DC),
    'ivory':       Color(0xFFFFFFF0),
    'linen':       Color(0xFFFAF0E6),
    'wheat':       Color(0xFFF5DEB3),
    'mint':        Color(0xFF98FF98),
    'emerald':     Color(0xFF50C878),
    'rose':        Color(0xFFFF007F),
    'ruby':        Color(0xFF9B111E),
    'sapphire':    Color(0xFF0F52BA),
    'peach':       Color(0xFFFFDAB9),
    'mauve':       Color(0xFFE0B0FF),
    'lilac':       Color(0xFFC8A2C8),
    'cream':       Color(0xFFFFFDD0),
    'charcoal':    Color(0xFF36454F),
    'slate':       Color(0xFF708090),
  };

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
