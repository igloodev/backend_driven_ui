import 'package:flutter/material.dart';

import '../../models/widget_schema.dart';
import '../../parser/schema_parser.dart';
import '../../utils/schema_converters.dart';

/// Builders for navigation widgets: BottomNavigationBar, NavigationBar,
/// DefaultTabController, TabBar, TabBarView.
class NavigationBuilders {
  /// [BottomNavigationBar] — classic bottom tab bar.
  ///
  /// `children` — each child's `props` define one tab item:
  ///   - `icon` (required) — icon name
  ///   - `label` — tab label string
  ///   - `activeIcon` — icon name shown when selected
  ///   - `backgroundColor` — per-item color (shifting type only)
  ///
  /// Each child's `action` is executed when that tab is tapped.
  ///
  /// Props: `currentIndex` (initial selected tab, default 0),
  /// `type` (`fixed` | `shifting`, default `fixed`),
  /// `backgroundColor`, `selectedItemColor`, `unselectedItemColor`,
  /// `elevation`, `showSelectedLabels`, `showUnselectedLabels`.
  static Widget buildBottomNavigationBar(
    WidgetSchema schema,
    BuildContext context,
    SchemaParser parser,
  ) {
    final props = schema.props ?? {};
    final children = schema.children ?? [];
    return _BduiBottomNavigationBar(
      props: props,
      children: children,
      parser: parser,
    );
  }

  /// [NavigationBar] — Material 3 bottom navigation bar.
  ///
  /// `children` — each child's `props` define one destination:
  ///   - `icon` (required) — icon name (unselected state)
  ///   - `selectedIcon` — icon name shown when selected
  ///   - `label` — destination label string
  ///
  /// Each child's `action` is executed when that destination is tapped.
  ///
  /// Props: `selectedIndex` (initial, default 0), `backgroundColor`,
  /// `indicatorColor`, `elevation`,
  /// `labelBehavior` (`alwaysShow` | `alwaysHide` | `onlyShowSelected`).
  static Widget buildNavigationBar(
    WidgetSchema schema,
    BuildContext context,
    SchemaParser parser,
  ) {
    final props = schema.props ?? {};
    final children = schema.children ?? [];
    return _BduiNavigationBar(
      props: props,
      children: children,
      parser: parser,
    );
  }

  /// [DefaultTabController] — provides a [TabController] to all descendants.
  ///
  /// Props: `length` — number of tabs (must match the number of tabs in the
  /// child [TabBar] and the number of pages in the child [TabBarView]),
  /// `initialIndex` (default 0, clamped to valid range).
  /// `child` — the widget subtree containing [TabBar] and [TabBarView].
  static Widget buildDefaultTabController(
    WidgetSchema schema,
    BuildContext context,
    SchemaParser parser,
  ) {
    final props = schema.props ?? {};
    final length = (SchemaConverters.toDouble(props['length'])?.toInt() ?? 1)
        .clamp(1, 999);
    final initialIndex =
        (SchemaConverters.toDouble(props['initialIndex'])?.toInt() ?? 0)
            .clamp(0, length - 1);

    return DefaultTabController(
      length: length,
      initialIndex: initialIndex,
      child: schema.child != null
          ? parser.parse(schema.child!, context)
          : const SizedBox.shrink(),
    );
  }

  /// [TabBar] — row of tabs, must be a descendant of [DefaultTabController].
  ///
  /// `children` — each child's `props` define one tab:
  ///   - `text` — tab label string
  ///   - `icon` — icon name (shown above or beside label)
  ///
  /// Props: `isScrollable` (bool, default `false`), `labelColor`,
  /// `unselectedLabelColor`, `indicatorColor`, `indicatorWeight` (default 2.0),
  /// `padding`.
  static Widget buildTabBar(
    WidgetSchema schema,
    BuildContext context,
    SchemaParser parser,
  ) {
    final props = schema.props ?? {};
    final children = schema.children ?? [];

    final tabs = children.map((child) {
      final p = child.props ?? {};
      final iconData = SchemaConverters.toIconData(p['icon']);
      return Tab(
        text: p['text'] as String?,
        icon: iconData != null ? Icon(iconData) : null,
      );
    }).toList();

    if (tabs.isEmpty) return const SizedBox.shrink();

    TabAlignment? tabAlignment;
    switch (props['tabAlignment'] as String?) {
      case 'start':
        tabAlignment = TabAlignment.start;
        break;
      case 'startOffset':
        tabAlignment = TabAlignment.startOffset;
        break;
      case 'fill':
        tabAlignment = TabAlignment.fill;
        break;
      case 'center':
        tabAlignment = TabAlignment.center;
        break;
    }

    return TabBar(
      tabs: tabs,
      isScrollable: props['isScrollable'] as bool? ?? false,
      labelColor: SchemaConverters.toColor(props['labelColor']),
      unselectedLabelColor:
          SchemaConverters.toColor(props['unselectedLabelColor']),
      indicatorColor: SchemaConverters.toColor(props['indicatorColor']),
      indicatorWeight:
          (SchemaConverters.toDouble(props['indicatorWeight']) ?? 2.0)
              .clamp(0.1, double.infinity),
      dividerColor: SchemaConverters.toColor(props['dividerColor']),
      padding: SchemaConverters.toEdgeInsets(props['padding']),
      tabAlignment: tabAlignment,
    );
  }

  /// [TabBarView] — page view synced with [TabBar], must be a descendant of
  /// [DefaultTabController].
  ///
  /// `children` — one widget per tab page.
  ///
  /// Props: `physics` (`never` | `bouncing` | `clamping`).
  static Widget buildTabBarView(
    WidgetSchema schema,
    BuildContext context,
    SchemaParser parser,
  ) {
    final props = schema.props ?? {};

    ScrollPhysics? physics;
    switch (props['physics'] as String?) {
      case 'never':
        physics = const NeverScrollableScrollPhysics();
        break;
      case 'bouncing':
        physics = const BouncingScrollPhysics();
        break;
      case 'clamping':
        physics = const ClampingScrollPhysics();
        break;
    }

    final views =
        schema.children?.map((c) => parser.parse(c, context)).toList() ?? [];

    if (views.isEmpty) return const SizedBox.shrink();

    return TabBarView(
      physics: physics,
      children: views,
    );
  }
}

// ---------------------------------------------------------------------------
// Stateful wrappers
// ---------------------------------------------------------------------------

class _BduiBottomNavigationBar extends StatefulWidget {
  const _BduiBottomNavigationBar({
    required this.props,
    required this.children,
    required this.parser,
  });

  final Map<String, dynamic> props;
  final List<WidgetSchema> children;
  final SchemaParser parser;

  @override
  State<_BduiBottomNavigationBar> createState() =>
      _BduiBottomNavigationBarState();
}

class _BduiBottomNavigationBarState extends State<_BduiBottomNavigationBar> {
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex =
        SchemaConverters.toDouble(widget.props['currentIndex'])?.toInt() ?? 0;
  }

  @override
  Widget build(BuildContext context) {
    final props = widget.props;

    final type = props['type'] == 'shifting'
        ? BottomNavigationBarType.shifting
        : BottomNavigationBarType.fixed;

    final items = widget.children.map((child) {
      final p = child.props ?? {};
      return BottomNavigationBarItem(
        icon: Icon(SchemaConverters.toIconData(p['icon'])),
        activeIcon: p['activeIcon'] != null
            ? Icon(SchemaConverters.toIconData(p['activeIcon']))
            : null,
        label: p['label'] as String? ?? '',
        backgroundColor: SchemaConverters.toColor(p['backgroundColor']),
      );
    }).toList();

    if (items.length < 2) return const SizedBox.shrink();

    return BottomNavigationBar(
      items: items,
      currentIndex: _currentIndex.clamp(0, items.length - 1),
      type: type,
      backgroundColor: SchemaConverters.toColor(props['backgroundColor']),
      selectedItemColor: SchemaConverters.toColor(props['selectedItemColor']),
      unselectedItemColor:
          SchemaConverters.toColor(props['unselectedItemColor']),
      elevation: SchemaConverters.toDouble(props['elevation']),
      iconSize: SchemaConverters.toDouble(props['iconSize']) ?? 24.0,
      selectedFontSize:
          SchemaConverters.toDouble(props['selectedFontSize']) ?? 14.0,
      unselectedFontSize:
          SchemaConverters.toDouble(props['unselectedFontSize']) ?? 12.0,
      showSelectedLabels: props['showSelectedLabels'] as bool? ?? true,
      showUnselectedLabels: props['showUnselectedLabels'] as bool? ?? true,
      onTap: (index) {
        setState(() => _currentIndex = index);
        final actionMap = widget.children[index].action;
        if (actionMap != null) {
          final map = actionMap is Map
              ? actionMap.map((k, v) => MapEntry(k.toString(), v))
              : null;
          if (map != null) {
            widget.parser.createActionHandler(context).executeFromMap(map);
          }
        }
      },
    );
  }
}

class _BduiNavigationBar extends StatefulWidget {
  const _BduiNavigationBar({
    required this.props,
    required this.children,
    required this.parser,
  });

  final Map<String, dynamic> props;
  final List<WidgetSchema> children;
  final SchemaParser parser;

  @override
  State<_BduiNavigationBar> createState() => _BduiNavigationBarState();
}

class _BduiNavigationBarState extends State<_BduiNavigationBar> {
  late int _selectedIndex;

  @override
  void initState() {
    super.initState();
    _selectedIndex =
        SchemaConverters.toDouble(widget.props['selectedIndex'])?.toInt() ?? 0;
  }

  @override
  Widget build(BuildContext context) {
    final props = widget.props;

    NavigationDestinationLabelBehavior? labelBehavior;
    switch (props['labelBehavior'] as String?) {
      case 'alwaysShow':
        labelBehavior = NavigationDestinationLabelBehavior.alwaysShow;
        break;
      case 'alwaysHide':
        labelBehavior = NavigationDestinationLabelBehavior.alwaysHide;
        break;
      case 'onlyShowSelected':
        labelBehavior = NavigationDestinationLabelBehavior.onlyShowSelected;
        break;
    }

    final destinations = widget.children.map((child) {
      final p = child.props ?? {};
      return NavigationDestination(
        icon: Icon(SchemaConverters.toIconData(p['icon'])),
        selectedIcon: p['selectedIcon'] != null
            ? Icon(SchemaConverters.toIconData(p['selectedIcon']))
            : null,
        label: p['label'] as String? ?? '',
      );
    }).toList();

    if (destinations.isEmpty) return const SizedBox.shrink();

    final animDurationMs =
        SchemaConverters.toDouble(props['animationDuration'])?.toInt();

    return NavigationBar(
      destinations: destinations,
      selectedIndex: _selectedIndex.clamp(0, destinations.length - 1),
      backgroundColor: SchemaConverters.toColor(props['backgroundColor']),
      indicatorColor: SchemaConverters.toColor(props['indicatorColor']),
      shadowColor: SchemaConverters.toColor(props['shadowColor']),
      surfaceTintColor: SchemaConverters.toColor(props['surfaceTintColor']),
      elevation: SchemaConverters.toDouble(props['elevation']),
      height: SchemaConverters.toDouble(props['height']),
      animationDuration: animDurationMs != null
          ? Duration(milliseconds: animDurationMs)
          : null,
      labelBehavior: labelBehavior,
      onDestinationSelected: (index) {
        setState(() => _selectedIndex = index);
        final actionMap = widget.children[index].action;
        if (actionMap != null) {
          final map = actionMap is Map
              ? actionMap.map((k, v) => MapEntry(k.toString(), v))
              : null;
          if (map != null) {
            widget.parser.createActionHandler(context).executeFromMap(map);
          }
        }
      },
    );
  }
}
