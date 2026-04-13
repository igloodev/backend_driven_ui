import 'package:flutter/material.dart';

import '../core/bdui_config.dart';
import '../handlers/action_handler.dart';
import '../models/widget_schema.dart';
import '../registry/builtin_widgets.dart';
import '../registry/widget_registry.dart';
import '../utils/helpers.dart';
import '../utils/bdui_logger.dart';

/// Parser for converting widget schemas to Flutter widgets
class SchemaParser {
  final WidgetRegistry _registry;
  final Map<String, Widget> _widgetCache = {};
  bool _cacheEnabled;

  /// Maximum cached widgets to prevent memory leaks
  static const int _maxCacheSize = 200;

  /// Callback for custom action handling
  final CustomActionCallback? onCustomAction;

  /// Callback for navigation - allows app to override default navigation
  final NavigationCallback? onNavigate;

  /// Callback for API success
  final ApiCallback? onApiSuccess;

  /// Callback for API errors
  final ApiErrorCallback? onApiError;

  /// Callback for URL launching - wire in url_launcher or any custom handler.
  ///
  /// See [LaunchUrlCallback] for usage example.
  final LaunchUrlCallback? onLaunchUrl;

  /// Creates a SchemaParser with its own registry.
  ///
  /// Each parser instance has its own registry to ensure callbacks
  /// (onCustomAction, onNavigate, etc.) are correctly bound.
  /// Pass [registry] to share a registry between parsers (advanced use).
  SchemaParser({
    WidgetRegistry? registry,
    bool enableCache = true,
    this.onCustomAction,
    this.onNavigate,
    this.onApiSuccess,
    this.onApiError,
    this.onLaunchUrl,
  })  : _registry = registry ?? WidgetRegistry(),
        _cacheEnabled = enableCache {
    // Register built-in widgets to this parser's registry
    _registry.registerAll(BuiltinWidgets.getBuilders(this));
  }

  /// Create an ActionHandler for the given context
  ActionHandler createActionHandler(BuildContext context) {
    return ActionHandler(
      context: context,
      onCustomAction: onCustomAction,
      onNavigate: onNavigate,
      onApiSuccess: onApiSuccess,
      onApiError: onApiError,
      onLaunchUrl: onLaunchUrl,
    );
  }

  /// Current parsing depth (used to track recursion)
  int _currentDepth = 0;

  /// Parse a widget schema into a Flutter widget
  Widget parse(WidgetSchema schema, BuildContext context) {
    // Check recursion depth BEFORE incrementing
    if (_currentDepth >= BduiConfig.maxWidgetDepth) {
      BduiLogger.warn(
          'SchemaParser: Max widget depth (${BduiConfig.maxWidgetDepth}) exceeded');
      return const ColoredBox(
        color: Colors.red,
        child: Padding(
          padding: EdgeInsets.all(8),
          child: Text(
            'Max nesting depth exceeded',
            style: TextStyle(color: Colors.white, fontSize: 10),
          ),
        ),
      );
    }

    // Increment depth for this parse call
    _currentDepth++;

    try {
      // Check cache first
      if (_cacheEnabled && schema.condition == null && schema.action == null) {
        final cacheKey = _getCacheKey(schema);
        if (_widgetCache.containsKey(cacheKey)) {
          return _widgetCache[cacheKey]!;
        }
      }

      // Handle conditional rendering
      if (schema.condition != null) {
        final shouldRender = evaluateCondition(schema.condition!, context);
        if (!shouldRender) {
          return const SizedBox.shrink();
        }
      }

      // Build widget
      final widget = _registry.build(schema, context);

      // Cache if enabled and no condition/action (actions need fresh context)
      if (_cacheEnabled && schema.condition == null && schema.action == null) {
        final cacheKey = _getCacheKey(schema);

        // LRU eviction if cache is full
        if (_widgetCache.length >= _maxCacheSize) {
          final oldestKey = _widgetCache.keys.first;
          _widgetCache.remove(oldestKey);
        }

        _widgetCache[cacheKey] = widget;
      }

      return widget;
    } finally {
      // Always decrement depth when done
      _currentDepth--;
    }
  }

  /// Parse multiple schemas
  List<Widget> parseList(List<WidgetSchema> schemas, BuildContext context) {
    return schemas.map((schema) => parse(schema, context)).toList();
  }

  /// Register a custom widget builder on this parser's registry.
  ///
  /// Use this to extend the built-in 33 widgets with your own types:
  /// ```dart
  /// final parser = SchemaParser();
  /// parser.register('ProductCard', (schema, context) {
  ///   return ProductCard(title: schema.props?['title']);
  /// });
  /// ```
  void register(String type, Widget Function(WidgetSchema, BuildContext) builder) {
    _registry.register(type, builder);
  }

  /// Enable or disable widget caching
  void setCacheEnabled(bool enabled) {
    _cacheEnabled = enabled;
    if (!enabled) {
      clearCache();
    }
  }

  /// Clear the widget cache
  void clearCache() {
    _widgetCache.clear();
  }

  /// Generate a deterministic cache key for a schema.
  ///
  /// Uses a stable string built from type + props + child hashes.
  /// No hashCode-of-hashCode: the buffer string itself is the key,
  /// keeping it compact via [_getSchemaHash].
  String _getCacheKey(WidgetSchema schema) {
    final buffer = StringBuffer();
    buffer.write(schema.type);
    buffer.write('|');

    if (schema.props != null) {
      buffer.write(_propsKey(schema.props!));
    }
    buffer.write('|');

    if (schema.child != null) {
      buffer.write(_getSchemaHash(schema.child!));
    }
    buffer.write('|');

    if (schema.children != null && schema.children!.isNotEmpty) {
      for (final child in schema.children!) {
        buffer.write(_getSchemaHash(child));
        buffer.write(',');
      }
    }

    return buffer.toString();
  }

  /// Stable string key for a props map.
  ///
  /// Sorts entries by key so insertion-order differences don't produce
  /// different cache keys for semantically identical props.
  String _propsKey(Map<String, dynamic> props) {
    final entries = props.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));
    return entries.map((e) => '${e.key}:${e.value}').join(';');
  }

  /// Polynomial hash for a schema's full content.
  ///
  /// Uses prime multiplication (31) rather than XOR so that child order
  /// and duplicate children produce distinct hashes.
  int _getSchemaHash(WidgetSchema schema) {
    var hash = 17;
    hash = hash * 31 + schema.type.hashCode;
    if (schema.props != null) {
      hash = hash * 31 + _propsKey(schema.props!).hashCode;
    }
    if (schema.child != null) {
      hash = hash * 31 + _getSchemaHash(schema.child!);
    }
    if (schema.children != null) {
      for (final child in schema.children!) {
        hash = hash * 31 + _getSchemaHash(child);
      }
    }
    return hash;
  }
}
