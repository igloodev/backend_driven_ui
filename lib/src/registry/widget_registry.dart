import 'package:flutter/material.dart';

import '../models/widget_schema.dart';
import '../utils/bdui_logger.dart';

/// Widget builder function signature
typedef WidgetBuilder = Widget Function(
  WidgetSchema schema,
  BuildContext context,
);

/// Registry for widget builders
///
/// Each [SchemaParser] creates its own registry instance to ensure
/// proper callback binding. Use [WidgetRegistry.global] only when
/// you need app-wide widget registration (rare).
///
/// Example:
/// ```dart
/// // Recommended: Let SchemaParser create its own registry
/// final parser = SchemaParser(onCustomAction: myHandler);
///
/// // Advanced: Share registry across parsers
/// final sharedRegistry = WidgetRegistry();
/// final parser1 = SchemaParser(registry: sharedRegistry);
/// final parser2 = SchemaParser(registry: sharedRegistry);
/// ```
class WidgetRegistry {
  /// Global singleton instance for app-wide widget registration.
  ///
  /// Use sparingly. Prefer creating new instances per [SchemaParser]
  /// to ensure proper callback isolation.
  static final WidgetRegistry global = WidgetRegistry._internal();

  /// Creates a new isolated registry instance.
  ///
  /// Recommended for most use cases. Each [SchemaParser] should have
  /// its own registry to avoid callback conflicts.
  factory WidgetRegistry() => WidgetRegistry._internal();

  WidgetRegistry._internal();

  final Map<String, WidgetBuilder> _builders = {};

  /// Custom fallback widget builder for unknown types
  Widget Function(WidgetSchema schema)? customFallbackBuilder;

  /// Custom error widget builder for build errors
  Widget Function(String type, String error)? customErrorBuilder;

  /// Register a widget builder
  void register(String type, WidgetBuilder builder) {
    _builders[type] = builder;
  }

  /// Register multiple widget builders
  void registerAll(Map<String, WidgetBuilder> builders) {
    _builders.addAll(builders);
  }

  /// Build a widget from schema
  Widget build(WidgetSchema schema, BuildContext context) {
    final builder = _builders[schema.type];

    if (builder == null) {
      return _buildFallback(schema, context);
    }

    try {
      return builder(schema, context);
    } catch (e) {
      return _buildError(schema.type, e.toString(), context);
    }
  }

  /// Check if type is registered
  bool hasBuilder(String type) => _builders.containsKey(type);

  /// Get all registered types
  List<String> get registeredTypes => _builders.keys.toList();

  /// Clear all builders
  void clear() => _builders.clear();

  /// Fallback widget for unknown types
  Widget _buildFallback(WidgetSchema schema, BuildContext context) {
    // Use custom fallback builder if provided
    if (customFallbackBuilder != null) {
      try {
        return customFallbackBuilder!(schema);
      } catch (e) {
        // Custom fallback failed, use default
        BduiLogger.warn('Custom fallback builder failed: $e');
      }
    }

    // Build child widgets even if parent is unknown
    Widget? childWidget;
    try {
      if (schema.child != null) {
        childWidget = build(schema.child!, context);
      } else if (schema.children != null && schema.children!.isNotEmpty) {
        // Build children with individual error handling
        final builtChildren = <Widget>[];
        for (final child in schema.children!) {
          try {
            builtChildren.add(build(child, context));
          } catch (e) {
            // Child build failed, add error indicator but continue
            builtChildren.add(
              const Text(
                '⚠️ Failed to build child',
                style: TextStyle(color: Colors.orange, fontSize: 10),
              ),
            );
          }
        }
        if (builtChildren.isNotEmpty) {
          childWidget = Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: builtChildren,
          );
        }
      }
    } catch (e) {
      BduiLogger.error('Error building fallback children: $e');
      childWidget = null;
    }

    return Container(
      margin: const EdgeInsets.all(4),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.yellow[100],
        border: Border.all(color: Colors.orange, width: 2),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.help_outline, color: Colors.orange, size: 16),
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  'Unknown: ${schema.type}',
                  style: const TextStyle(
                    color: Colors.orange,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          if (childWidget != null) ...[
            const SizedBox(height: 8),
            const Divider(color: Colors.orange, height: 1),
            const SizedBox(height: 8),
            childWidget,
          ],
        ],
      ),
    );
  }

  /// Error widget
  Widget _buildError(String type, String error, BuildContext context) {
    // Use custom error builder if provided
    if (customErrorBuilder != null) {
      try {
        return customErrorBuilder!(type, error);
      } catch (e) {
        // Custom error builder failed, use default
        BduiLogger.warn('Custom error builder failed: $e');
      }
    }

    return Container(
      margin: const EdgeInsets.all(4),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.red[100],
        border: Border.all(color: Colors.red, width: 2),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 16),
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  'Error: $type',
                  style: const TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            error,
            style: const TextStyle(color: Colors.red, fontSize: 11),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
