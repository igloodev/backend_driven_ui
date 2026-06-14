import 'package:flutter/material.dart';

import '../../models/widget_schema.dart';
import '../../parser/schema_parser.dart';
import '../../utils/schema_converters.dart';

/// Builders for Scaffold-related widgets: Scaffold, AppBar, SafeArea.
class ScaffoldBuilders {
  /// [Scaffold] — top-level screen structure.
  ///
  /// Named slots (passed via `props` as nested widget schema maps):
  /// - `appBar` — rendered as [PreferredSizeWidget] (use `AppBar` type)
  /// - `floatingActionButton` — FAB widget schema
  /// - `bottomNavigationBar` — bottom nav widget schema
  /// - `drawer` — left drawer widget schema
  /// - `endDrawer` — right drawer widget schema
  /// - `bottomSheet` — persistent bottom sheet widget schema
  ///
  /// `child` — the body widget.
  ///
  /// Props: `backgroundColor`, `resizeToAvoidBottomInset` (default `true`),
  /// `extendBody`, `extendBodyBehindAppBar`,
  /// `floatingActionButtonLocation` (`centerFloat` | `endFloat` | `centerDocked`
  /// | `endDocked` | `centerTop` | `endTop` | `miniCenterFloat` |
  /// `miniEndFloat` | `miniCenterDocked` | `miniEndDocked`).
  static Widget buildScaffold(
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

    final appBarWidget = parseSlot(props['appBar']);

    FloatingActionButtonLocation? fabLocation;
    switch (props['floatingActionButtonLocation'] as String?) {
      case 'centerFloat':
        fabLocation = FloatingActionButtonLocation.centerFloat;
        break;
      case 'endFloat':
        fabLocation = FloatingActionButtonLocation.endFloat;
        break;
      case 'centerDocked':
        fabLocation = FloatingActionButtonLocation.centerDocked;
        break;
      case 'endDocked':
        fabLocation = FloatingActionButtonLocation.endDocked;
        break;
      case 'centerTop':
        fabLocation = FloatingActionButtonLocation.centerTop;
        break;
      case 'endTop':
        fabLocation = FloatingActionButtonLocation.endTop;
        break;
      case 'miniCenterFloat':
        fabLocation = FloatingActionButtonLocation.miniCenterFloat;
        break;
      case 'miniEndFloat':
        fabLocation = FloatingActionButtonLocation.miniEndFloat;
        break;
      case 'miniCenterDocked':
        fabLocation = FloatingActionButtonLocation.miniCenterDocked;
        break;
      case 'miniEndDocked':
        fabLocation = FloatingActionButtonLocation.miniEndDocked;
        break;
    }

    return Scaffold(
      backgroundColor: SchemaConverters.toColor(props['backgroundColor']),
      resizeToAvoidBottomInset:
          props['resizeToAvoidBottomInset'] as bool? ?? true,
      extendBody: props['extendBody'] as bool? ?? false,
      extendBodyBehindAppBar: props['extendBodyBehindAppBar'] as bool? ?? false,
      appBar: appBarWidget is PreferredSizeWidget ? appBarWidget : null,
      body: schema.child != null ? parser.parse(schema.child!, context) : null,
      floatingActionButton: parseSlot(props['floatingActionButton']),
      floatingActionButtonLocation: fabLocation,
      bottomNavigationBar: parseSlot(props['bottomNavigationBar']),
      drawer: parseSlot(props['drawer']),
      endDrawer: parseSlot(props['endDrawer']),
      bottomSheet: parseSlot(props['bottomSheet']),
    );
  }

  /// [AppBar] — material design app bar for use inside [Scaffold].
  ///
  /// Props: `title` (string), `centerTitle`, `backgroundColor`,
  /// `foregroundColor`, `shadowColor`, `surfaceTintColor`, `elevation`,
  /// `scrolledUnderElevation`, `toolbarHeight`, `leadingWidth`,
  /// `titleSpacing`, `automaticallyImplyLeading`.
  ///
  /// Named slots (via `props`): `leading`, `flexibleSpace`, `bottom`
  /// (`bottom` must resolve to a [PreferredSizeWidget], e.g. `TabBar`).
  /// `children` — rendered as `actions`.
  static Widget buildAppBar(
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

    final title = props['title'] as String?;
    final bottomWidget = parseSlot(props['bottom']);

    return AppBar(
      title: title != null ? Text(title) : null,
      centerTitle: props['centerTitle'] as bool?,
      backgroundColor: SchemaConverters.toColor(props['backgroundColor']),
      foregroundColor: SchemaConverters.toColor(props['foregroundColor']),
      shadowColor: SchemaConverters.toColor(props['shadowColor']),
      surfaceTintColor: SchemaConverters.toColor(props['surfaceTintColor']),
      elevation: SchemaConverters.toDouble(props['elevation']),
      scrolledUnderElevation:
          SchemaConverters.toDouble(props['scrolledUnderElevation']),
      toolbarHeight: SchemaConverters.toDouble(props['toolbarHeight']),
      leadingWidth: SchemaConverters.toDouble(props['leadingWidth']),
      titleSpacing: SchemaConverters.toDouble(props['titleSpacing']),
      automaticallyImplyLeading:
          props['automaticallyImplyLeading'] as bool? ?? true,
      leading: parseSlot(props['leading']),
      flexibleSpace: parseSlot(props['flexibleSpace']),
      bottom: bottomWidget is PreferredSizeWidget ? bottomWidget : null,
      actions: schema.children?.map((c) => parser.parse(c, context)).toList(),
    );
  }

  /// [Form] — wraps form fields and provides validation coordination.
  ///
  /// Props: `formKey` (string ID used with `submitForm` action, default
  /// `"_default"`), `autovalidateMode` (`"disabled"` | `"always"` |
  /// `"onUserInteraction"`, default `"disabled"`).
  ///
  /// `child` or `children` — the form field widgets. Multiple `children`
  /// are wrapped in a [Column].
  static Widget buildForm(
    WidgetSchema schema,
    BuildContext context,
    SchemaParser parser,
  ) {
    final props = schema.props ?? {};
    final formKeyName = props['formKey'] as String? ?? '_default';

    AutovalidateMode autovalidateMode;
    switch (props['autovalidateMode'] as String?) {
      case 'always':
        autovalidateMode = AutovalidateMode.always;
        break;
      case 'onUserInteraction':
        autovalidateMode = AutovalidateMode.onUserInteraction;
        break;
      default:
        autovalidateMode = AutovalidateMode.disabled;
    }

    Widget child;
    if (schema.child != null) {
      child = parser.parse(schema.child!, context);
    } else if (schema.children != null && schema.children!.isNotEmpty) {
      child = Column(
        mainAxisSize: MainAxisSize.min,
        children: parser.parseList(schema.children!, context),
      );
    } else {
      child = const SizedBox.shrink();
    }

    return Form(
      key: parser.getFormKey(formKeyName),
      autovalidateMode: autovalidateMode,
      child: child,
    );
  }

  /// [SafeArea] — insets its child to avoid OS intrusions (notch, home bar).
  ///
  /// Props: `top`, `bottom`, `left`, `right` (all `bool`, default `true`),
  /// `minimum` padding (same format as EdgeInsets).
  static Widget buildSafeArea(
    WidgetSchema schema,
    BuildContext context,
    SchemaParser parser,
  ) {
    final props = schema.props ?? {};
    return SafeArea(
      top: props['top'] as bool? ?? true,
      bottom: props['bottom'] as bool? ?? true,
      left: props['left'] as bool? ?? true,
      right: props['right'] as bool? ?? true,
      minimum:
          SchemaConverters.toEdgeInsets(props['minimum']) ?? EdgeInsets.zero,
      child: schema.child != null
          ? parser.parse(schema.child!, context)
          : const SizedBox.shrink(),
    );
  }
}
