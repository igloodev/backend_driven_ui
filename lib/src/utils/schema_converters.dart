import 'package:flutter/material.dart';

import 'bdui_logger.dart';

/// Converts raw JSON prop values to Flutter types used by schema widget builders.
///
/// All methods are null-safe: passing `null` returns `null` (or the default
/// value for non-nullable return types).
class SchemaConverters {
  // ── Numeric ───────────────────────────────────────────────────────────────

  static double? toDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

  // ── Color ─────────────────────────────────────────────────────────────────

  /// Converts a JSON color value to [Color].
  ///
  /// Accepts:
  /// - `int` / `double` — raw ARGB value
  /// - `String` starting with `#` — `#RRGGBB` or `#AARRGGBB`
  /// - Named color string (`"red"`, `"blue700"`, `"Colors.deepPurple"`, …)
  /// - Plain int string (`"4278190080"`)
  static Color? toColor(dynamic value) {
    if (value == null) return null;

    if (value is int) return Color(value);

    if (value is double) {
      return Color(value.clamp(0, 0xFFFFFFFF).toInt());
    }

    if (value is String) {
      if (value.startsWith('#')) {
        try {
          final hex = value.substring(1);
          if (hex.length == 6) {
            return Color(int.parse(hex, radix: 16) + 0xFF000000);
          }
          if (hex.length == 8) return Color(int.parse(hex, radix: 16));
          return null;
        } catch (_) {
          return null;
        }
      }

      final normalized =
          (value.startsWith('Colors.') ? value.substring(7) : value)
              .toLowerCase();
      final named = _namedColors[normalized];
      if (named != null) return named;

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
    'red50': Color(0xFFFFEBEE),
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
    'pink50': Color(0xFFFCE4EC),
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
    'purple50': Color(0xFFF3E5F5),
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
    'deeppurple50': Color(0xFFEDE7F6),
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
    'indigo50': Color(0xFFE8EAF6),
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
    'blue50': Color(0xFFE3F2FD),
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
    'lightblue50': Color(0xFFE1F5FE),
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
    'cyan50': Color(0xFFE0F7FA),
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
    'teal50': Color(0xFFE0F2F1),
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
    'green50': Color(0xFFE8F5E9),
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
    'lightgreen50': Color(0xFFF1F8E9),
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
    'lime50': Color(0xFFF9FBE7),
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
    'yellow50': Color(0xFFFFFDE7),
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
    'amber50': Color(0xFFFFF8E1),
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
    'orange50': Color(0xFFFFF3E0),
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
    'deeporange50': Color(0xFFFBE9E7),
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
    'brown50': Color(0xFFEFEBE9),
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
    'grey50': Color(0xFFFAFAFA),
    'grey100': Color(0xFFF5F5F5),
    'grey200': Color(0xFFEEEEEE),
    'grey300': Color(0xFFE0E0E0),
    'grey400': Color(0xFFBDBDBD),
    'grey500': Color(0xFF9E9E9E),
    'grey600': Color(0xFF757575),
    'grey700': Color(0xFF616161),
    'grey800': Color(0xFF424242),
    'grey900': Color(0xFF212121),
    'gray50': Color(0xFFFAFAFA),
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
    'bluegrey50': Color(0xFFECEFF1),
    'bluegrey100': Color(0xFFCFD8DC),
    'bluegrey200': Color(0xFFB0BEC5),
    'bluegrey300': Color(0xFF90A4AE),
    'bluegrey400': Color(0xFF78909C),
    'bluegrey500': Color(0xFF607D8B),
    'bluegrey600': Color(0xFF546E7A),
    'bluegrey700': Color(0xFF455A64),
    'bluegrey800': Color(0xFF37474F),
    'bluegrey900': Color(0xFF263238),
    'bluegray50': Color(0xFFECEFF1),
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
    'aqua': Color(0xFF00FFFF),
    'fuchsia': Color(0xFFFF00FF),
    'magenta': Color(0xFFFF00FF),
    'navy': Color(0xFF001F5B),
    'maroon': Color(0xFF800000),
    'olive': Color(0xFF808000),
    'silver': Color(0xFFC0C0C0),
    'gold': Color(0xFFFFD700),
    'coral': Color(0xFFFF7F50),
    'salmon': Color(0xFFFA8072),
    'crimson': Color(0xFFDC143C),
    'scarlet': Color(0xFFFF2400),
    'violet': Color(0xFFEE82EE),
    'lavender': Color(0xFFE6E6FA),
    'khaki': Color(0xFFF0E68C),
    'turquoise': Color(0xFF40E0D0),
    'skyblue': Color(0xFF87CEEB),
    'chocolate': Color(0xFFD2691E),
    'tan': Color(0xFFD2B48C),
    'beige': Color(0xFFF5F5DC),
    'ivory': Color(0xFFFFFFF0),
    'linen': Color(0xFFFAF0E6),
    'wheat': Color(0xFFF5DEB3),
    'mint': Color(0xFF98FF98),
    'emerald': Color(0xFF50C878),
    'rose': Color(0xFFFF007F),
    'ruby': Color(0xFF9B111E),
    'sapphire': Color(0xFF0F52BA),
    'peach': Color(0xFFFFDAB9),
    'mauve': Color(0xFFE0B0FF),
    'lilac': Color(0xFFC8A2C8),
    'cream': Color(0xFFFFFDD0),
    'charcoal': Color(0xFF36454F),
    'slate': Color(0xFF708090),
  };

  // ── Spacing ───────────────────────────────────────────────────────────────

  static EdgeInsets? toEdgeInsets(dynamic value) {
    if (value == null) return null;
    if (value is num) return EdgeInsets.all(value.toDouble());
    if (value is Map) {
      if (value['all'] != null) return EdgeInsets.all(toDouble(value['all'])!);
      if (value['horizontal'] != null || value['vertical'] != null) {
        return EdgeInsets.symmetric(
          horizontal: toDouble(value['horizontal']) ?? 0.0,
          vertical: toDouble(value['vertical']) ?? 0.0,
        );
      }
      return EdgeInsets.only(
        left: toDouble(value['left']) ?? 0.0,
        top: toDouble(value['top']) ?? 0.0,
        right: toDouble(value['right']) ?? 0.0,
        bottom: toDouble(value['bottom']) ?? 0.0,
      );
    }
    return null;
  }

  // ── Clip ──────────────────────────────────────────────────────────────────

  /// Converts a JSON clip value to [Clip].
  ///
  /// Accepts: `"none"`, `"hardEdge"`, `"antiAlias"`, `"antiAliasWithSaveLayer"`.
  /// Returns `null` for unrecognised values so callers can apply their own default.
  static Clip? toClip(dynamic value) {
    switch (value) {
      case 'none':
        return Clip.none;
      case 'hardEdge':
        return Clip.hardEdge;
      case 'antiAlias':
        return Clip.antiAlias;
      case 'antiAliasWithSaveLayer':
        return Clip.antiAliasWithSaveLayer;
      default:
        return null;
    }
  }

  // ── Text ──────────────────────────────────────────────────────────────────

  static FontWeight? toFontWeight(dynamic value) {
    if (value == null) return null;
    if (value == 'bold') return FontWeight.bold;
    if (value is int) return FontWeight.values[(value ~/ 100 - 1).clamp(0, 8)];
    return null;
  }

  static TextAlign? toTextAlign(dynamic value) {
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

  static TextOverflow? toTextOverflow(dynamic value) {
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

  static TextDecoration? toTextDecoration(dynamic value) {
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

  static TextDecorationStyle? toTextDecorationStyle(dynamic value) {
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

  static TextDirection? toTextDirection(dynamic value) {
    switch (value) {
      case 'ltr':
        return TextDirection.ltr;
      case 'rtl':
        return TextDirection.rtl;
      default:
        return null;
    }
  }

  // ── Layout ────────────────────────────────────────────────────────────────

  static MainAxisAlignment toMainAxisAlignment(dynamic value) {
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

  static CrossAxisAlignment toCrossAxisAlignment(dynamic value) {
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

  static MainAxisSize toMainAxisSize(dynamic value) {
    switch (value) {
      case 'min':
        return MainAxisSize.min;
      case 'max':
        return MainAxisSize.max;
      default:
        return MainAxisSize.max;
    }
  }

  static WrapAlignment toWrapAlignment(dynamic value) {
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

  static Alignment? toAlignment(dynamic value) =>
      toAlignmentGeometry(value) as Alignment?;

  static AlignmentGeometry? toAlignmentGeometry(dynamic value) {
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

  // ── Decoration ────────────────────────────────────────────────────────────

  static BorderRadius? toBorderRadius(dynamic value) {
    if (value == null) return null;
    if (value is num) return BorderRadius.circular(value.toDouble());
    if (value is Map) {
      return BorderRadius.only(
        topLeft: Radius.circular(toDouble(value['topLeft']) ?? 0.0),
        topRight: Radius.circular(toDouble(value['topRight']) ?? 0.0),
        bottomLeft: Radius.circular(toDouble(value['bottomLeft']) ?? 0.0),
        bottomRight: Radius.circular(toDouble(value['bottomRight']) ?? 0.0),
      );
    }
    return null;
  }

  static List<BoxShadow>? toBoxShadow(dynamic value) {
    if (value == null) return null;
    final shadows = value is List ? value : [value];
    return shadows
        .whereType<Map>()
        .map((s) => BoxShadow(
              color: toColor(s['color']) ?? Colors.black.withAlpha(77),
              offset: Offset(
                toDouble(s['offsetX']) ?? 0.0,
                toDouble(s['offsetY']) ?? (value is List ? 0.0 : 2.0),
              ),
              blurRadius:
                  toDouble(s['blurRadius']) ?? (value is List ? 0.0 : 4.0),
              spreadRadius: toDouble(s['spreadRadius']) ?? 0.0,
            ))
        .toList();
  }

  static Gradient? toGradient(dynamic value) {
    if (value == null || value is! Map) return null;

    final type = value['type'] as String?;
    final colors = (value['colors'] as List?)
        ?.map((c) => toColor(c))
        .whereType<Color>()
        .toList();

    if (colors == null || colors.isEmpty) return null;

    final stops =
        (value['stops'] as List?)?.map((s) => (s as num).toDouble()).toList();

    switch (type) {
      case 'radial':
        return RadialGradient(
          colors: colors,
          center: toAlignmentGeometry(value['center']) ?? Alignment.center,
          radius: toDouble(value['radius']) ?? 0.5,
          stops: stops,
        );
      case 'sweep':
        return SweepGradient(
          colors: colors,
          center: toAlignmentGeometry(value['center']) ?? Alignment.center,
          startAngle: toDouble(value['startAngle']) ?? 0.0,
          endAngle: toDouble(value['endAngle']) ?? 6.283185307179586,
          stops: stops,
        );
      default:
        return LinearGradient(
          colors: colors,
          begin: toAlignmentGeometry(value['begin']) ?? Alignment.centerLeft,
          end: toAlignmentGeometry(value['end']) ?? Alignment.centerRight,
          stops: stops,
        );
    }
  }

  static Matrix4? toMatrix4(dynamic value) {
    if (value == null || value is! Map) return null;
    final m = Matrix4.identity();
    if (value['rotateZ'] != null) {
      m.rotateZ(toDouble(value['rotateZ'])! * 3.141592653589793 / 180.0);
    }
    if (value['rotateX'] != null) {
      m.rotateX(toDouble(value['rotateX'])! * 3.141592653589793 / 180.0);
    }
    if (value['rotateY'] != null) {
      m.rotateY(toDouble(value['rotateY'])! * 3.141592653589793 / 180.0);
    }
    if (value['scale'] != null) {
      final s = toDouble(value['scale'])!;
      m.multiply(Matrix4.diagonal3Values(s, s, s));
    }
    if (value['scaleX'] != null || value['scaleY'] != null) {
      m.multiply(Matrix4.diagonal3Values(
        toDouble(value['scaleX']) ?? 1.0,
        toDouble(value['scaleY']) ?? 1.0,
        1.0,
      ));
    }
    if (value['translateX'] != null || value['translateY'] != null) {
      m.multiply(Matrix4.translationValues(
        toDouble(value['translateX']) ?? 0.0,
        toDouble(value['translateY']) ?? 0.0,
        0.0,
      ));
    }
    return m;
  }

  // ── Misc ──────────────────────────────────────────────────────────────────

  static BoxFit? toBoxFit(dynamic value) {
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

  static IconData? toIconData(dynamic value) {
    if (value == null) return null;
    switch (value) {
      // ── Navigation / arrows ────────────────────────────────────────────────
      case 'home':
        return Icons.home;
      case 'back':
        return Icons.arrow_back;
      case 'forward':
        return Icons.arrow_forward;
      case 'up':
        return Icons.keyboard_arrow_up;
      case 'down':
        return Icons.keyboard_arrow_down;
      case 'expand_more':
        return Icons.expand_more;
      case 'expand_less':
        return Icons.expand_less;
      case 'chevron_left':
        return Icons.chevron_left;
      case 'chevron_right':
        return Icons.chevron_right;
      case 'arrow_left':
        return Icons.arrow_back_ios;
      case 'arrow_right':
        return Icons.arrow_forward_ios;
      case 'arrow_upward':
        return Icons.arrow_upward;
      case 'arrow_downward':
        return Icons.arrow_downward;
      case 'first_page':
        return Icons.first_page;
      case 'last_page':
        return Icons.last_page;
      case 'more_vert':
        return Icons.more_vert;
      case 'more_horiz':
        return Icons.more_horiz;
      case 'menu':
        return Icons.menu;
      case 'close':
        return Icons.close;
      case 'fullscreen':
        return Icons.fullscreen;
      case 'fullscreen_exit':
        return Icons.fullscreen_exit;

      // ── Status / actions ──────────────────────────────────────────────────
      case 'search':
        return Icons.search;
      case 'settings':
        return Icons.settings;
      case 'tune':
        return Icons.tune;
      case 'filter_list':
        return Icons.filter_list;
      case 'sort':
        return Icons.sort;
      case 'add':
        return Icons.add;
      case 'add_circle':
        return Icons.add_circle;
      case 'remove':
        return Icons.remove;
      case 'remove_circle':
        return Icons.remove_circle;
      case 'edit':
        return Icons.edit;
      case 'delete':
        return Icons.delete;
      case 'delete_outline':
        return Icons.delete_outline;
      case 'refresh':
        return Icons.refresh;
      case 'check':
        return Icons.check;
      case 'check_circle':
        return Icons.check_circle;
      case 'check_circle_outline':
        return Icons.check_circle_outline;
      case 'done':
        return Icons.done;
      case 'done_all':
        return Icons.done_all;
      case 'cancel':
        return Icons.cancel;
      case 'block':
        return Icons.block;
      case 'error':
        return Icons.error;
      case 'error_outline':
        return Icons.error_outline;
      case 'warning':
        return Icons.warning;
      case 'warning_amber':
        return Icons.warning_amber;
      case 'info':
        return Icons.info;
      case 'info_outline':
        return Icons.info_outline;
      case 'help':
        return Icons.help;
      case 'help_outline':
        return Icons.help_outline;
      case 'copy':
        return Icons.copy;
      case 'share':
        return Icons.share;
      case 'send':
        return Icons.send;
      case 'reply':
        return Icons.reply;
      case 'link':
        return Icons.link;
      case 'flag':
        return Icons.flag;
      case 'label':
        return Icons.label;
      case 'label_outline':
        return Icons.label_outline;
      case 'new_releases':
        return Icons.new_releases;
      case 'verified':
        return Icons.verified;
      case 'zoom_in':
        return Icons.zoom_in;
      case 'zoom_out':
        return Icons.zoom_out;
      case 'rotate_left':
        return Icons.rotate_left;
      case 'rotate_right':
        return Icons.rotate_right;
      case 'crop':
        return Icons.crop;

      // ── People / social ───────────────────────────────────────────────────
      case 'person':
        return Icons.person;
      case 'person_add':
        return Icons.person_add;
      case 'person_remove':
        return Icons.person_remove;
      case 'account_circle':
        return Icons.account_circle;
      case 'group':
        return Icons.group;
      case 'groups':
        return Icons.groups;
      case 'logout':
        return Icons.logout;
      case 'login':
        return Icons.login;

      // ── Favorites / ratings ───────────────────────────────────────────────
      case 'favorite':
        return Icons.favorite;
      case 'favorite_border':
        return Icons.favorite_border;
      case 'star':
        return Icons.star;
      case 'star_border':
        return Icons.star_border;
      case 'star_half':
        return Icons.star_half;
      case 'thumb_up':
        return Icons.thumb_up;
      case 'thumb_down':
        return Icons.thumb_down;
      case 'bookmark':
        return Icons.bookmark;
      case 'bookmark_border':
        return Icons.bookmark_border;
      case 'bookmark_add':
        return Icons.bookmark_add;

      // ── Communication ────────────────────────────────────────────────────
      case 'email':
        return Icons.email;
      case 'phone':
        return Icons.phone;
      case 'call':
        return Icons.call;
      case 'call_end':
        return Icons.call_end;
      case 'message':
        return Icons.message;
      case 'chat':
        return Icons.chat;
      case 'chat_bubble':
        return Icons.chat_bubble;
      case 'forum':
        return Icons.forum;
      case 'notifications':
        return Icons.notifications;
      case 'notifications_none':
        return Icons.notifications_none;
      case 'notifications_off':
        return Icons.notifications_off;
      case 'videocam':
        return Icons.videocam;
      case 'videocam_off':
        return Icons.videocam_off;
      case 'mic':
        return Icons.mic;
      case 'mic_off':
        return Icons.mic_off;

      // ── Media controls ────────────────────────────────────────────────────
      case 'play':
        return Icons.play_arrow;
      case 'pause':
        return Icons.pause;
      case 'stop':
        return Icons.stop;
      case 'skip_next':
        return Icons.skip_next;
      case 'skip_previous':
        return Icons.skip_previous;
      case 'volume_up':
        return Icons.volume_up;
      case 'volume_down':
        return Icons.volume_down;
      case 'volume_off':
        return Icons.volume_off;
      case 'volume_mute':
        return Icons.volume_mute;
      case 'headphones':
        return Icons.headphones;

      // ── Files / content ───────────────────────────────────────────────────
      case 'camera':
        return Icons.camera_alt;
      case 'image':
        return Icons.image;
      case 'photo':
        return Icons.photo;
      case 'photo_library':
        return Icons.photo_library;
      case 'file':
        return Icons.insert_drive_file;
      case 'folder':
        return Icons.folder;
      case 'folder_open':
        return Icons.folder_open;
      case 'download':
        return Icons.download;
      case 'upload':
        return Icons.upload;
      case 'attach_file':
        return Icons.attach_file;
      case 'attachment':
        return Icons.attachment;
      case 'description':
        return Icons.description;
      case 'article':
        return Icons.article;
      case 'code':
        return Icons.code;
      case 'print':
        return Icons.print;
      case 'save':
        return Icons.save;
      case 'save_alt':
        return Icons.save_alt;

      // ── Commerce ──────────────────────────────────────────────────────────
      case 'shopping_cart':
        return Icons.shopping_cart;
      case 'shopping_bag':
        return Icons.shopping_bag;
      case 'payment':
        return Icons.payment;
      case 'credit_card':
        return Icons.credit_card;
      case 'store':
        return Icons.store;
      case 'receipt':
        return Icons.receipt;
      case 'local_offer':
        return Icons.local_offer;

      // ── Location / map ────────────────────────────────────────────────────
      case 'location_on':
        return Icons.location_on;
      case 'location_off':
        return Icons.location_off;
      case 'map':
        return Icons.map;
      case 'navigation':
        return Icons.navigation;
      case 'explore':
        return Icons.explore;
      case 'directions':
        return Icons.directions;

      // ── Time / calendar ───────────────────────────────────────────────────
      case 'calendar':
        return Icons.calendar_today;
      case 'calendar_today':
        return Icons.calendar_today;
      case 'date_range':
        return Icons.date_range;
      case 'schedule':
        return Icons.schedule;
      case 'access_time':
        return Icons.access_time;
      case 'timer':
        return Icons.timer;
      case 'history':
        return Icons.history;

      // ── Device / connectivity ─────────────────────────────────────────────
      case 'wifi':
        return Icons.wifi;
      case 'wifi_off':
        return Icons.wifi_off;
      case 'bluetooth':
        return Icons.bluetooth;
      case 'bluetooth_disabled':
        return Icons.bluetooth_disabled;
      case 'battery_full':
        return Icons.battery_full;
      case 'battery_low':
        return Icons.battery_1_bar;
      case 'signal':
        return Icons.signal_cellular_alt;
      case 'fingerprint':
        return Icons.fingerprint;
      case 'qr_code':
        return Icons.qr_code;
      case 'barcode':
        return Icons.barcode_reader;
      case 'language':
        return Icons.language;
      case 'dark_mode':
        return Icons.dark_mode;
      case 'light_mode':
        return Icons.light_mode;
      case 'flash_on':
        return Icons.flash_on;
      case 'flash_off':
        return Icons.flash_off;

      // ── Security ──────────────────────────────────────────────────────────
      case 'lock':
        return Icons.lock;
      case 'unlock':
        return Icons.lock_open;
      case 'security':
        return Icons.security;
      case 'shield':
        return Icons.shield;
      case 'visibility':
        return Icons.visibility;
      case 'visibility_off':
        return Icons.visibility_off;

      // ── Analytics / trends ────────────────────────────────────────────────
      case 'trending_up':
        return Icons.trending_up;
      case 'trending_down':
        return Icons.trending_down;
      case 'bar_chart':
        return Icons.bar_chart;
      case 'pie_chart':
        return Icons.pie_chart;
      case 'dashboard':
        return Icons.dashboard;

      // ── Layout / view ─────────────────────────────────────────────────────
      case 'grid_view':
        return Icons.grid_view;
      case 'list':
        return Icons.list;
      case 'view_list':
        return Icons.view_list;
      case 'view_module':
        return Icons.view_module;
      case 'table_chart':
        return Icons.table_chart;

      // ── Cloud ─────────────────────────────────────────────────────────────
      case 'cloud':
        return Icons.cloud;
      case 'cloud_upload':
        return Icons.cloud_upload;
      case 'cloud_download':
        return Icons.cloud_download;

      // ── Misc ──────────────────────────────────────────────────────────────
      case 'palette':
        return Icons.palette;
      case 'brush':
        return Icons.brush;
      case 'bug_report':
        return Icons.bug_report;
      case 'support':
        return Icons.support_agent;
      case 'headset':
        return Icons.headset;
      case 'power':
        return Icons.power_settings_new;
      case 'sync':
        return Icons.sync;

      default:
        BduiLogger.warn(
          'toIconData: unknown icon "$value" — using help_outline. '
          'See SCHEMA_REFERENCE.md for the full list of ~120 supported icon names.',
        );
        return Icons.help_outline;
    }
  }

  /// Converts a map of text style properties to a [TextStyle].
  ///
  /// Supported keys: `fontSize`, `fontWeight`, `color`, `backgroundColor`,
  /// `letterSpacing`, `wordSpacing`, `lineHeight`, `fontStyle` (`italic`),
  /// `decoration`, `decorationColor`, `decorationStyle`, `decorationThickness`,
  /// `fontFamily`.
  static TextStyle? toTextStyle(dynamic value) {
    if (value is! Map) return null;
    final props = value.map((k, v) => MapEntry(k.toString(), v));
    return TextStyle(
      fontSize: toDouble(props['fontSize']),
      fontWeight: toFontWeight(props['fontWeight']),
      color: toColor(props['color']),
      backgroundColor: toColor(props['backgroundColor']),
      letterSpacing: toDouble(props['letterSpacing']),
      wordSpacing: toDouble(props['wordSpacing']),
      height: toDouble(props['lineHeight']),
      fontStyle: props['fontStyle'] == 'italic' ? FontStyle.italic : null,
      decoration: toTextDecoration(props['decoration']),
      decorationColor: toColor(props['decorationColor']),
      decorationStyle: toTextDecorationStyle(props['decorationStyle']),
      decorationThickness: toDouble(props['decorationThickness']),
      fontFamily: props['fontFamily'] as String?,
    );
  }
}
