import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../models/widget_schema.dart';
import '../../parser/schema_parser.dart';
import '../../utils/helpers.dart';
import '../../utils/schema_converters.dart';

/// Builders for input widgets: TextField, TextFormField, Switch, Checkbox.
class InputBuilders {
  /// [TextField] — single or multi-line text input with an internal controller.
  ///
  /// Props:
  /// - `value` — initial text
  /// - `hint`, `label`, `helperText`, `errorText`
  /// - `prefixText`, `suffixText`, `prefixIcon`, `suffixIcon` (icon names)
  /// - `filled` (bool), `fillColor`
  /// - `borderRadius` — rounds the input border
  /// - `obscureText` (bool, default `false`)
  /// - `enabled` (bool, default `true`)
  /// - `readOnly` (bool, default `false`)
  /// - `maxLines` (default `1`; if `minLines` exceeds it, `maxLines` is raised to match)
  /// - `minLines`
  /// - `maxLength`
  /// - `keyboardType` — `text` | `number` | `email` | `phone` | `multiline` | `url` | `visiblePassword`
  /// - `textInputAction` — `done` | `next` | `search` | `send` | `go` | `newline`
  /// - `textCapitalization` — `none` | `words` | `sentences` | `characters`
  /// - `textAlign` — `left` | `center` | `right` | `justify`
  /// - `style` — map of text style props for the input text
  /// - `cursorColor`
  /// - `cursorWidth` (default 2.0)
  /// - `autocorrect` (bool, default `true`)
  /// - `enableSuggestions` (bool, default `true`)
  /// - `onChanged` — action map fired on every keystroke
  ///
  /// `action` — fired on `onSubmitted` (keyboard action key pressed).
  static Widget buildTextField(
    WidgetSchema schema,
    BuildContext context,
    SchemaParser parser,
  ) {
    final props = schema.props ?? {};
    return _BduiTextField(schema: schema, props: props, parser: parser);
  }

  /// [TextFormField] — like [TextField] but integrates with [Form] / [FormState].
  ///
  /// Additional props:
  /// - `validators` — list of rule strings applied in order:
  ///   `required`, `email`, `minLength:N`, `maxLength:N`, `numeric`
  ///
  /// All [TextField] props are supported.
  static Widget buildTextFormField(
    WidgetSchema schema,
    BuildContext context,
    SchemaParser parser,
  ) {
    final props = schema.props ?? {};
    return _BduiTextFormField(schema: schema, props: props, parser: parser);
  }

  /// [Switch] — toggle between on/off states.
  ///
  /// Props: `value` (bool initial state, default `false`),
  /// `activeColor`, `activeTrackColor`,
  /// `inactiveThumbColor`, `inactiveTrackColor`.
  /// `action` — fired on every toggle.
  static Widget buildSwitch(
    WidgetSchema schema,
    BuildContext context,
    SchemaParser parser,
  ) {
    final props = schema.props ?? {};
    return _BduiSwitch(props: props, schema: schema, parser: parser);
  }

  /// [Checkbox] — tick box for boolean selection.
  ///
  /// Props: `value` (bool initial state, default `false`),
  /// `tristate` (bool, default `false` — allows `null` intermediate state),
  /// `activeColor`, `checkColor`, `fillColor`.
  /// `action` — fired on every toggle.
  static Widget buildCheckbox(
    WidgetSchema schema,
    BuildContext context,
    SchemaParser parser,
  ) {
    final props = schema.props ?? {};
    return _BduiCheckbox(props: props, schema: schema, parser: parser);
  }
}

// ---------------------------------------------------------------------------
// Shared helpers
// ---------------------------------------------------------------------------

TextInputType _toKeyboardType(String? value) {
  switch (value) {
    case 'number':
      return TextInputType.number;
    case 'email':
      return TextInputType.emailAddress;
    case 'phone':
      return TextInputType.phone;
    case 'multiline':
      return TextInputType.multiline;
    case 'url':
      return TextInputType.url;
    case 'visiblePassword':
      return TextInputType.visiblePassword;
    default:
      return TextInputType.text;
  }
}

TextInputAction _toTextInputAction(String? value) {
  switch (value) {
    case 'next':
      return TextInputAction.next;
    case 'search':
      return TextInputAction.search;
    case 'send':
      return TextInputAction.send;
    case 'go':
      return TextInputAction.go;
    case 'newline':
      return TextInputAction.newline;
    default:
      return TextInputAction.done;
  }
}

TextCapitalization _toTextCapitalization(String? value) {
  switch (value) {
    case 'words':
      return TextCapitalization.words;
    case 'sentences':
      return TextCapitalization.sentences;
    case 'characters':
      return TextCapitalization.characters;
    default:
      return TextCapitalization.none;
  }
}

InputDecoration _buildDecoration(Map<String, dynamic> props) {
  final borderRadius =
      SchemaConverters.toBorderRadius(props['borderRadius']) ??
          BorderRadius.circular(
            SchemaConverters.toDouble(props['borderRadius']) ?? 4.0,
          );

  final filled = props['filled'] as bool? ?? false;
  final fillColor = SchemaConverters.toColor(props['fillColor']);

  final prefixIconData = SchemaConverters.toIconData(props['prefixIcon']);
  final suffixIconData = SchemaConverters.toIconData(props['suffixIcon']);

  final border = OutlineInputBorder(borderRadius: borderRadius);

  return InputDecoration(
    hintText: props['hint'] as String?,
    labelText: props['label'] as String?,
    helperText: props['helperText'] as String?,
    errorText: props['errorText'] as String?,
    prefixText: props['prefixText'] as String?,
    suffixText: props['suffixText'] as String?,
    prefixIcon: prefixIconData != null ? Icon(prefixIconData) : null,
    suffixIcon: suffixIconData != null ? Icon(suffixIconData) : null,
    filled: filled,
    fillColor: fillColor,
    border: border,
    enabledBorder: border,
    focusedBorder: border,
  );
}

String? _runValidators(String? value, List<dynamic> rules) {
  final text = value ?? '';
  for (final rule in rules) {
    final r = rule.toString();
    if (r == 'required' && text.trim().isEmpty) {
      return 'This field is required';
    }
    if (r == 'email' &&
        text.isNotEmpty &&
        !RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(text)) {
      return 'Enter a valid email address';
    }
    if (r == 'numeric' && text.isNotEmpty && double.tryParse(text) == null) {
      return 'Enter a valid number';
    }
    if (r.startsWith('minLength:')) {
      final n = int.tryParse(r.substring(10)) ?? 0;
      if (text.length < n) return 'Minimum $n characters required';
    }
    if (r.startsWith('maxLength:')) {
      final n = int.tryParse(r.substring(10)) ?? 0;
      if (text.length > n) return 'Maximum $n characters allowed';
    }
  }
  return null;
}

// ---------------------------------------------------------------------------
// Stateful wrappers
// ---------------------------------------------------------------------------

class _BduiTextField extends StatefulWidget {
  const _BduiTextField({
    required this.schema,
    required this.props,
    required this.parser,
  });

  final WidgetSchema schema;
  final Map<String, dynamic> props;
  final SchemaParser parser;

  @override
  State<_BduiTextField> createState() => _BduiTextFieldState();
}

class _BduiTextFieldState extends State<_BduiTextField> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller =
        TextEditingController(text: widget.props['value'] as String? ?? '');
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _execute(Map<String, dynamic> action) {
    widget.parser.createActionHandler(context).executeFromMap(action);
  }

  @override
  Widget build(BuildContext context) {
    final props = widget.props;
    final schema = widget.schema;

    final obscureText = props['obscureText'] as bool? ?? false;
    final bool isMultiline = props['keyboardType'] == 'multiline';
    // When obscureText: minLines must be null, maxLines must be 1.
    final int? minLines =
        obscureText ? null : SchemaConverters.toDouble(props['minLines'])?.toInt();
    final maxLinesRaw = props['maxLines'];
    // Compute maxLines:
    //   - obscureText → 1 (Flutter requires this)
    //   - multiline keyboard + no explicit maxLines → null (unlimited growth)
    //   - multiline keyboard + explicit maxLines:1 → null (override; Flutter asserts != 1)
    //   - otherwise → parse, clamp to [1, 99999], default 1
    int? maxLines;
    if (obscureText) {
      maxLines = 1;
    } else if (maxLinesRaw == null) {
      maxLines = isMultiline ? null : 1;
    } else {
      final parsed =
          (SchemaConverters.toDouble(maxLinesRaw)?.toInt() ?? 1).clamp(1, 99999);
      maxLines = (isMultiline && parsed == 1) ? null : parsed;
    }
    // Ensure minLines <= maxLines when both are set.
    if (minLines != null && maxLines != null && minLines > maxLines) {
      maxLines = minLines;
    }

    final onChangedAction = toStringKeyedMap(props['onChanged']);
    final onSubmittedAction = toStringKeyedMap(schema.action);

    return TextField(
      controller: _controller,
      decoration: _buildDecoration(props),
      style: SchemaConverters.toTextStyle(props['style']),
      obscureText: obscureText,
      enabled: props['enabled'] as bool? ?? true,
      readOnly: props['readOnly'] as bool? ?? false,
      maxLines: maxLines,
      minLines: minLines,
      maxLength: SchemaConverters.toDouble(props['maxLength'])?.toInt(),
      keyboardType: _toKeyboardType(props['keyboardType'] as String?),
      textInputAction:
          _toTextInputAction(props['textInputAction'] as String?),
      textCapitalization:
          _toTextCapitalization(props['textCapitalization'] as String?),
      textAlign: SchemaConverters.toTextAlign(props['textAlign']) ??
          TextAlign.start,
      cursorColor: SchemaConverters.toColor(props['cursorColor']),
      cursorWidth: SchemaConverters.toDouble(props['cursorWidth']) ?? 2.0,
      autocorrect: props['autocorrect'] as bool? ?? true,
      enableSuggestions: props['enableSuggestions'] as bool? ?? true,
      inputFormatters: props['keyboardType'] == 'number'
          ? [FilteringTextInputFormatter.allow(RegExp(r'[\d.]'))]
          : null,
      onChanged: onChangedAction != null
          ? (_) => _execute(onChangedAction)
          : null,
      onSubmitted: onSubmittedAction != null
          ? (_) => _execute(onSubmittedAction)
          : null,
    );
  }
}

class _BduiTextFormField extends StatefulWidget {
  const _BduiTextFormField({
    required this.schema,
    required this.props,
    required this.parser,
  });

  final WidgetSchema schema;
  final Map<String, dynamic> props;
  final SchemaParser parser;

  @override
  State<_BduiTextFormField> createState() => _BduiTextFormFieldState();
}

class _BduiTextFormFieldState extends State<_BduiTextFormField> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller =
        TextEditingController(text: widget.props['value'] as String? ?? '');
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _execute(Map<String, dynamic> action) {
    widget.parser.createActionHandler(context).executeFromMap(action);
  }

  @override
  Widget build(BuildContext context) {
    final props = widget.props;
    final schema = widget.schema;

    final obscureText = props['obscureText'] as bool? ?? false;
    final bool isMultiline = props['keyboardType'] == 'multiline';
    // When obscureText: minLines must be null, maxLines must be 1.
    final int? minLines =
        obscureText ? null : SchemaConverters.toDouble(props['minLines'])?.toInt();
    final maxLinesRaw = props['maxLines'];
    // Compute maxLines:
    //   - obscureText → 1 (Flutter requires this)
    //   - multiline keyboard + no explicit maxLines → null (unlimited growth)
    //   - multiline keyboard + explicit maxLines:1 → null (override; Flutter asserts != 1)
    //   - otherwise → parse, clamp to [1, 99999], default 1
    int? maxLines;
    if (obscureText) {
      maxLines = 1;
    } else if (maxLinesRaw == null) {
      maxLines = isMultiline ? null : 1;
    } else {
      final parsed =
          (SchemaConverters.toDouble(maxLinesRaw)?.toInt() ?? 1).clamp(1, 99999);
      maxLines = (isMultiline && parsed == 1) ? null : parsed;
    }
    // Ensure minLines <= maxLines when both are set.
    if (minLines != null && maxLines != null && minLines > maxLines) {
      maxLines = minLines;
    }

    final onChangedAction = toStringKeyedMap(props['onChanged']);
    final onSubmittedAction = toStringKeyedMap(schema.action);
    final validators = props['validators'] as List<dynamic>? ?? const [];

    return TextFormField(
      controller: _controller,
      decoration: _buildDecoration(props),
      style: SchemaConverters.toTextStyle(props['style']),
      obscureText: obscureText,
      enabled: props['enabled'] as bool? ?? true,
      readOnly: props['readOnly'] as bool? ?? false,
      maxLines: maxLines,
      minLines: minLines,
      maxLength: SchemaConverters.toDouble(props['maxLength'])?.toInt(),
      keyboardType: _toKeyboardType(props['keyboardType'] as String?),
      textInputAction:
          _toTextInputAction(props['textInputAction'] as String?),
      textCapitalization:
          _toTextCapitalization(props['textCapitalization'] as String?),
      textAlign: SchemaConverters.toTextAlign(props['textAlign']) ??
          TextAlign.start,
      cursorColor: SchemaConverters.toColor(props['cursorColor']),
      cursorWidth: SchemaConverters.toDouble(props['cursorWidth']) ?? 2.0,
      autocorrect: props['autocorrect'] as bool? ?? true,
      enableSuggestions: props['enableSuggestions'] as bool? ?? true,
      inputFormatters: props['keyboardType'] == 'number'
          ? [FilteringTextInputFormatter.allow(RegExp(r'[\d.]'))]
          : null,
      validator: validators.isNotEmpty
          ? (value) => _runValidators(value, validators)
          : null,
      onChanged: onChangedAction != null
          ? (_) => _execute(onChangedAction)
          : null,
      onFieldSubmitted: onSubmittedAction != null
          ? (_) => _execute(onSubmittedAction)
          : null,
    );
  }
}

// ---------------------------------------------------------------------------
// Switch
// ---------------------------------------------------------------------------

class _BduiSwitch extends StatefulWidget {
  const _BduiSwitch({
    required this.props,
    required this.schema,
    required this.parser,
  });

  final Map<String, dynamic> props;
  final WidgetSchema schema;
  final SchemaParser parser;

  @override
  State<_BduiSwitch> createState() => _BduiSwitchState();
}

class _BduiSwitchState extends State<_BduiSwitch> {
  late bool _value;

  @override
  void initState() {
    super.initState();
    _value = widget.props['value'] as bool? ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final props = widget.props;
    final actionMap = toStringKeyedMap(widget.schema.action);

    return Switch(
      value: _value,
      activeThumbColor: SchemaConverters.toColor(props['activeColor']),
      activeTrackColor: SchemaConverters.toColor(props['activeTrackColor']),
      inactiveThumbColor:
          SchemaConverters.toColor(props['inactiveThumbColor']),
      inactiveTrackColor:
          SchemaConverters.toColor(props['inactiveTrackColor']),
      onChanged: (newValue) {
        setState(() => _value = newValue);
        if (actionMap != null) {
          widget.parser
              .createActionHandler(context)
              .executeFromMap(actionMap);
        }
      },
    );
  }
}

// ---------------------------------------------------------------------------
// Checkbox
// ---------------------------------------------------------------------------

class _BduiCheckbox extends StatefulWidget {
  const _BduiCheckbox({
    required this.props,
    required this.schema,
    required this.parser,
  });

  final Map<String, dynamic> props;
  final WidgetSchema schema;
  final SchemaParser parser;

  @override
  State<_BduiCheckbox> createState() => _BduiCheckboxState();
}

class _BduiCheckboxState extends State<_BduiCheckbox> {
  bool? _value;

  @override
  void initState() {
    super.initState();
    _value = widget.props['value'] as bool? ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final props = widget.props;
    final tristate = props['tristate'] as bool? ?? false;
    final actionMap = toStringKeyedMap(widget.schema.action);

    final activeColor = SchemaConverters.toColor(props['activeColor']);
    final checkColor = SchemaConverters.toColor(props['checkColor']);
    final fillColor = SchemaConverters.toColor(props['fillColor']);

    final borderColor = SchemaConverters.toColor(props['borderColor']);
    final borderWidth =
        SchemaConverters.toDouble(props['borderWidth']) ?? 2.0;

    VisualDensity? visualDensity;
    switch (props['visualDensity'] as String?) {
      case 'compact':
        visualDensity = VisualDensity.compact;
        break;
      case 'comfortable':
        visualDensity = VisualDensity.comfortable;
        break;
      case 'standard':
        visualDensity = VisualDensity.standard;
        break;
    }

    return Checkbox(
      value: _value,
      tristate: tristate,
      activeColor: activeColor,
      checkColor: checkColor,
      fillColor: fillColor != null
          ? WidgetStateProperty.all(fillColor)
          : null,
      side: borderColor != null
          ? BorderSide(color: borderColor, width: borderWidth)
          : null,
      visualDensity: visualDensity,
      onChanged: (newValue) {
        setState(() => _value = newValue);
        if (actionMap != null) {
          widget.parser
              .createActionHandler(context)
              .executeFromMap(actionMap);
        }
      },
    );
  }
}
