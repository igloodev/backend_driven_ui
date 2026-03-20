import 'package:flutter/material.dart';

import '../core/bdui_config.dart';
import '../handlers/action_handler.dart';
import '../models/widget_schema.dart';
import '../registry/builtin_widgets.dart';
import '../registry/widget_registry.dart';
import '../utils/helpers.dart';
import '../utils/logger.dart';

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

  /// Generate cache key for a schema
  String _getCacheKey(WidgetSchema schema) {
    // Generate unique hash including full content
    final buffer = StringBuffer();
    buffer.write(schema.type);
    buffer.write('_');

    // Include full props hash
    if (schema.props != null) {
      buffer.write(schema.props.toString().hashCode);
    }
    buffer.write('_');

    // Include child's full content hash (recursive)
    if (schema.child != null) {
      buffer.write(_getSchemaHash(schema.child!));
    }
    buffer.write('_');

    // Include children's content hash
    if (schema.children != null && schema.children!.isNotEmpty) {
      for (var i = 0; i < schema.children!.length; i++) {
        buffer.write(_getSchemaHash(schema.children![i]));
        buffer.write(',');
      }
    }

    return buffer.toString().hashCode.toString();
  }

  /// Get a hash for a schema's full content
  int _getSchemaHash(WidgetSchema schema) {
    var hash = schema.type.hashCode;
    if (schema.props != null) {
      hash ^= schema.props.toString().hashCode;
    }
    if (schema.child != null) {
      hash ^= _getSchemaHash(schema.child!);
    }
    if (schema.children != null) {
      for (final child in schema.children!) {
        hash ^= _getSchemaHash(child);
      }
    }
    return hash;
  }
}
