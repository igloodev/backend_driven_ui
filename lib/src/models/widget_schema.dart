import '../core/bdui_config.dart';
import '../utils/helpers.dart';
import '../utils/bdui_logger.dart';

/// Widget schema from backend JSON
class WidgetSchema {

  /// Widget type (e.g., 'Column', 'Text', 'Button')
  final String type;

  /// Widget properties
  final Map<String, dynamic>? props;

  /// Child widgets
  final List<WidgetSchema>? children;

  /// Single child widget
  final WidgetSchema? child;

  /// Action to perform (e.g., on tap)
  final dynamic action;

  /// Conditional rendering
  final String? condition;

  /// Creates a widget schema
  const WidgetSchema({
    required this.type,
    this.props,
    this.children,
    this.child,
    this.action,
    this.condition,
  });

  /// Creates from JSON with validation
  factory WidgetSchema.fromJson(Map<String, dynamic> json) {
    // Validate required field: type
    final type = json['type'] as String?;
    if (type == null || type.isEmpty) {
      throw ArgumentError(
        'WidgetSchema requires a non-empty "type" field. Got: ${json['type']}',
      );
    }

    // Safe parsing of children
    List<WidgetSchema>? children;
    if (json['children'] != null) {
      try {
        final childrenList = json['children'] as List?;
        if (childrenList != null) {
          // Security: Limit children count to prevent memory exhaustion
          if (childrenList.length > BduiConfig.maxChildren) {
            BduiLogger.warn('Children count (${childrenList.length}) exceeds limit (${BduiConfig.maxChildren}), truncating');
          }
          final limitedCount = childrenList.length > BduiConfig.maxChildren ? BduiConfig.maxChildren : childrenList.length;

          children = [];
          for (var i = 0; i < limitedCount; i++) {
            try {
              final childJson = childrenList[i];
              final childMap = toStringKeyedMap(childJson);
              if (childMap != null) {
                children.add(WidgetSchema.fromJson(childMap));
              }
            } catch (e) {
              // Skip invalid child, log error
              BduiLogger.warn('Skipping invalid child at index $i: $e');
            }
          }
        }
      } catch (e) {
        BduiLogger.error('Error parsing children: $e');
      }
    }

    // Safe parsing of child
    WidgetSchema? child;
    if (json['child'] != null) {
      try {
        final childMap = toStringKeyedMap(json['child']);
        if (childMap != null) {
          child = WidgetSchema.fromJson(childMap);
        }
      } catch (e) {
        BduiLogger.error('Error parsing child: $e');
      }
    }

    return WidgetSchema(
      type: type,
      props: toStringKeyedMap(json['props']),
      children: children,
      child: child,
      action: json['action'],
      condition: json['condition'] as String?,
    );
  }

  /// Converts to JSON
  Map<String, dynamic> toJson() {
    return {
      'type': type,
      if (props != null) 'props': props,
      if (children != null)
        'children': children!.map((e) => e.toJson()).toList(),
      if (child != null) 'child': child!.toJson(),
      if (action != null) 'action': action,
      if (condition != null) 'condition': condition,
    };
  }

  /// Safely get a prop value with type checking
  T? getProp<T>(String key, {T? defaultValue}) {
    if (props == null) return defaultValue;

    try {
      final value = props![key];
      if (value == null) return defaultValue;

      // Type checking
      if (value is T) {
        return value;
      }

      // Try to convert common types
      if (T == String) {
        return value.toString() as T;
      }
      if (T == int && value is num) {
        return value.toInt() as T;
      }
      if (T == double && value is num) {
        return value.toDouble() as T;
      }

      return defaultValue;
    } catch (e) {
      BduiLogger.warn('Error getting prop "$key": $e');
      return defaultValue;
    }
  }

  /// Safely get a string prop
  String? getString(String key, {String? defaultValue}) {
    return getProp<String>(key, defaultValue: defaultValue);
  }

  /// Safely get an int prop
  int? getInt(String key, {int? defaultValue}) {
    return getProp<int>(key, defaultValue: defaultValue);
  }

  /// Safely get a double prop
  double? getDouble(String key, {double? defaultValue}) {
    return getProp<double>(key, defaultValue: defaultValue);
  }

  /// Safely get a bool prop
  bool? getBool(String key, {bool? defaultValue}) {
    return getProp<bool>(key, defaultValue: defaultValue);
  }

  /// Safely get a map prop
  Map<String, dynamic>? getMap(String key) {
    return getProp<Map<String, dynamic>>(key);
  }

  /// Safely get a list prop
  List<dynamic>? getList(String key) {
    return getProp<List<dynamic>>(key);
  }

  /// Check if a prop exists and is not null
  bool hasProp(String key) {
    return props != null && props!.containsKey(key) && props![key] != null;
  }

  @override
  String toString() => 'WidgetSchema(type: $type)';
}
