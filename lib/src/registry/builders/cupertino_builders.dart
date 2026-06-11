import 'package:flutter/cupertino.dart';

import '../../models/widget_schema.dart';
import '../../parser/schema_parser.dart';
import '../../utils/helpers.dart';
import '../../utils/schema_converters.dart';

/// Builders for iOS-native Cupertino widgets.
///
/// Use these when you want platform-native look and feel on iOS rather than
/// Material Design equivalents.
class CupertinoBuilders {
  /// [CupertinoButton] — iOS-style button with optional fill.
  ///
  /// Props: `text`, `color` (filled background), `textColor`, `padding`,
  /// `minSize`, `borderRadius`, `disabled`, `filled` (bool).
  /// `action` — executed on tap.
  static Widget buildCupertinoButton(
    WidgetSchema schema,
    BuildContext context,
    SchemaParser parser,
  ) {
    final props = schema.props ?? {};
    final actionMap = toStringKeyedMap(schema.action);
    final disabled = props['disabled'] as bool? ?? false;
    final filled = props['filled'] as bool? ?? false;
    final color = SchemaConverters.toColor(props['color']);
    final text = props['text']?.toString() ?? '';

    Widget child;
    if (schema.child != null) {
      child = parser.parse(schema.child!, context);
    } else {
      child = Text(
        text,
        style: TextStyle(
          color: SchemaConverters.toColor(props['textColor']),
        ),
      );
    }

    final borderRadius = SchemaConverters.toBorderRadius(props['borderRadius']) ??
        const BorderRadius.all(Radius.circular(8));
    final padding = SchemaConverters.toEdgeInsets(props['padding']);
    final minSize = SchemaConverters.toDouble(props['minSize']) ?? 44.0;

    VoidCallback? onPressed = disabled
        ? null
        : () {
            if (actionMap != null) {
              parser.createActionHandler(context).executeFromMap(actionMap);
            }
          };

    // `minSize` (JSON prop) is a single double — map to a square Size for the
    // current Flutter API (`minimumSize`). 44.0 default matches the iOS HIG
    // minimum tap target.
    final minimum = Size.square(minSize);

    if (filled) {
      return CupertinoButton.filled(
        onPressed: onPressed,
        borderRadius: borderRadius,
        padding: padding,
        minimumSize: minimum,
        child: child,
      );
    }

    return CupertinoButton(
      onPressed: onPressed,
      color: color,
      borderRadius: borderRadius,
      padding: padding,
      minimumSize: minimum,
      child: child,
    );
  }

  /// [CupertinoSwitch] — iOS-style toggle switch.
  ///
  /// Props: `value` (bool), `activeColor`, `trackColor`, `thumbColor`,
  /// `stateKey` (writes bool to state on toggle).
  /// `action` — executed on change.
  static Widget buildCupertinoSwitch(
    WidgetSchema schema,
    BuildContext context,
    SchemaParser parser,
  ) {
    final props = schema.props ?? {};
    return _CupertinoSwitchWidget(schema: schema, props: props, parser: parser);
  }

  /// [CupertinoSlider] — iOS-style slider.
  ///
  /// Props: `value` (0.0–1.0 by default), `min`, `max`, `divisions`,
  /// `activeColor`, `thumbColor`, `stateKey` (writes value to state).
  static Widget buildCupertinoSlider(
    WidgetSchema schema,
    BuildContext context,
    SchemaParser parser,
  ) {
    final props = schema.props ?? {};
    return _CupertinoSliderWidget(schema: schema, props: props, parser: parser);
  }

  /// [CupertinoActivityIndicator] — iOS-style spinning loader.
  ///
  /// Props: `radius` (default 10.0), `animating` (default true), `color`.
  static Widget buildCupertinoActivityIndicator(
    WidgetSchema schema,
    BuildContext context,
  ) {
    final props = schema.props ?? {};
    return CupertinoActivityIndicator(
      radius: SchemaConverters.toDouble(props['radius']) ?? 10.0,
      animating: props['animating'] as bool? ?? true,
      color: SchemaConverters.toColor(props['color']),
    );
  }

  /// [CupertinoTextField] — iOS-style text input.
  ///
  /// Props: `hint` (placeholder), `stateKey`, `obscureText`, `enabled`,
  /// `maxLines`, `keyboardType`, `style`, `padding`, `textAlign`,
  /// `clearButtonMode` (`never` | `always` | `whileEditing` | `unlessEditing`).
  static Widget buildCupertinoTextField(
    WidgetSchema schema,
    BuildContext context,
    SchemaParser parser,
  ) {
    final props = schema.props ?? {};
    return _CupertinoTextFieldWidget(schema: schema, props: props, parser: parser);
  }
}

// ─── Stateful helpers ─────────────────────────────────────────────────────────

class _CupertinoSwitchWidget extends StatefulWidget {
  const _CupertinoSwitchWidget({
    required this.schema,
    required this.props,
    required this.parser,
  });

  final WidgetSchema schema;
  final Map<String, dynamic> props;
  final SchemaParser parser;

  @override
  State<_CupertinoSwitchWidget> createState() => _CupertinoSwitchState();
}

class _CupertinoSwitchState extends State<_CupertinoSwitchWidget> {
  late bool _value;

  @override
  void initState() {
    super.initState();
    final stateKey = widget.props['stateKey'] as String?;
    _value = (stateKey != null
            ? widget.parser.stateManager.get(stateKey) as bool?
            : null) ??
        widget.props['value'] as bool? ??
        false;
  }

  @override
  void didUpdateWidget(_CupertinoSwitchWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    final newValue = widget.props['value'] as bool?;
    if (newValue != null && newValue != (oldWidget.props['value'] as bool?)) {
      setState(() => _value = newValue);
    }
  }

  @override
  Widget build(BuildContext context) {
    final props = widget.props;
    final stateKey = props['stateKey'] as String?;
    final actionMap = toStringKeyedMap(widget.schema.action);

    return CupertinoSwitch(
      value: _value,
      // JSON props `activeColor` / `trackColor` are kept for backward compat;
      // they map to CupertinoSwitch's renamed `activeTrackColor` /
      // `inactiveTrackColor` parameters (Flutter 3.24+).
      activeTrackColor: SchemaConverters.toColor(props['activeColor']),
      inactiveTrackColor: SchemaConverters.toColor(props['trackColor']),
      thumbColor: SchemaConverters.toColor(props['thumbColor']),
      onChanged: (v) {
        setState(() => _value = v);
        if (stateKey != null) widget.parser.stateManager.set(stateKey, v);
        if (actionMap != null) {
          widget.parser.createActionHandler(context).executeFromMap(actionMap);
        }
      },
    );
  }
}

class _CupertinoSliderWidget extends StatefulWidget {
  const _CupertinoSliderWidget({
    required this.schema,
    required this.props,
    required this.parser,
  });

  final WidgetSchema schema;
  final Map<String, dynamic> props;
  final SchemaParser parser;

  @override
  State<_CupertinoSliderWidget> createState() => _CupertinoSliderState();
}

class _CupertinoSliderState extends State<_CupertinoSliderWidget> {
  late double _value;

  @override
  void initState() {
    super.initState();
    final stateKey = widget.props['stateKey'] as String?;
    final fromState = stateKey != null
        ? SchemaConverters.toDouble(widget.parser.stateManager.get(stateKey))
        : null;
    _value = fromState ??
        SchemaConverters.toDouble(widget.props['value']) ??
        0.0;
  }

  @override
  void didUpdateWidget(_CupertinoSliderWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    final newValue = SchemaConverters.toDouble(widget.props['value']);
    final oldValue = SchemaConverters.toDouble(oldWidget.props['value']);
    if (newValue != null && newValue != oldValue) {
      setState(() => _value = newValue);
    }
  }

  @override
  Widget build(BuildContext context) {
    final props = widget.props;
    final stateKey = props['stateKey'] as String?;
    final min = SchemaConverters.toDouble(props['min']) ?? 0.0;
    final max = SchemaConverters.toDouble(props['max']) ?? 1.0;
    final divisions = (SchemaConverters.toDouble(props['divisions']))?.toInt();

    return CupertinoSlider(
      value: _value.clamp(min, max),
      min: min,
      max: max,
      divisions: divisions,
      activeColor: SchemaConverters.toColor(props['activeColor']),
      thumbColor: SchemaConverters.toColor(props['thumbColor']) ?? CupertinoColors.white,
      onChanged: (v) {
        setState(() => _value = v);
        if (stateKey != null) widget.parser.stateManager.set(stateKey, v);
      },
    );
  }
}

class _CupertinoTextFieldWidget extends StatefulWidget {
  const _CupertinoTextFieldWidget({
    required this.schema,
    required this.props,
    required this.parser,
  });

  final WidgetSchema schema;
  final Map<String, dynamic> props;
  final SchemaParser parser;

  @override
  State<_CupertinoTextFieldWidget> createState() => _CupertinoTextFieldState();
}

class _CupertinoTextFieldState extends State<_CupertinoTextFieldWidget> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    final stateKey = widget.props['stateKey'] as String?;
    final initial = widget.props['value'] as String? ??
        (stateKey != null
            ? widget.parser.stateManager.get(stateKey)?.toString()
            : null) ??
        '';
    _controller = TextEditingController(text: initial);
  }

  @override
  void didUpdateWidget(_CupertinoTextFieldWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    final newValue = widget.props['value'] as String?;
    final oldValue = oldWidget.props['value'] as String?;
    if (newValue != null && newValue != oldValue && newValue != _controller.text) {
      _controller.text = newValue;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  OverlayVisibilityMode _toOverlayMode(String? v) {
    switch (v) {
      case 'always':
        return OverlayVisibilityMode.always;
      case 'whileEditing':
        return OverlayVisibilityMode.editing;
      case 'unlessEditing':
        return OverlayVisibilityMode.notEditing;
      default:
        return OverlayVisibilityMode.never;
    }
  }

  @override
  Widget build(BuildContext context) {
    final props = widget.props;
    final stateKey = props['stateKey'] as String?;
    final obscure = props['obscureText'] as bool? ?? false;

    return CupertinoTextField(
      controller: _controller,
      placeholder: props['hint'] as String?,
      obscureText: obscure,
      enabled: props['enabled'] as bool? ?? true,
      maxLines: obscure ? 1 : SchemaConverters.toDouble(props['maxLines'])?.toInt() ?? 1,
      style: SchemaConverters.toTextStyle(props['style']),
      padding: SchemaConverters.toEdgeInsets(props['padding']) ??
          const EdgeInsets.symmetric(horizontal: 6, vertical: 7),
      textAlign: SchemaConverters.toTextAlign(props['textAlign']) ?? TextAlign.start,
      clearButtonMode: _toOverlayMode(props['clearButtonMode'] as String?),
      onChanged: (v) {
        if (stateKey != null) widget.parser.stateManager.set(stateKey, v);
      },
    );
  }
}
