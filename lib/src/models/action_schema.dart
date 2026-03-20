import '../utils/helpers.dart';

/// Action schema for user interactions
class ActionSchema {
  /// Action type (navigate, api, showDialog, etc.)
  final String type;

  /// Action parameters
  final Map<String, dynamic>? params;

  /// Route (for navigation)
  final String? route;

  /// API endpoint (for API calls)
  final String? endpoint;

  /// HTTP method (for API calls)
  final String? method;

  /// Request body (for API calls)
  final dynamic body;

  /// Success action (chain)
  final ActionSchema? onSuccess;

  /// Error action (chain)
  final ActionSchema? onError;

  /// Multiple actions to execute in sequence
  final List<ActionSchema>? actions;

  /// Condition for conditional actions
  final String? condition;

  /// Then action (for conditionals)
  final ActionSchema? thenAction;

  /// Else action (for conditionals)
  final ActionSchema? elseAction;

  /// Creates an action schema
  const ActionSchema({
    required this.type,
    this.params,
    this.route,
    this.endpoint,
    this.method,
    this.body,
    this.onSuccess,
    this.onError,
    this.actions,
    this.condition,
    this.thenAction,
    this.elseAction,
  });

  /// Creates from JSON with validation
  ///
  /// Throws [ArgumentError] if required fields are missing or invalid.
  factory ActionSchema.fromJson(Map<String, dynamic> json) {
    // Validate required 'type' field
    final type = json['type'];
    if (type == null) {
      throw ArgumentError('ActionSchema requires a "type" field');
    }
    if (type is! String) {
      throw ArgumentError('ActionSchema "type" must be a String, got ${type.runtimeType}');
    }
    if (type.isEmpty) {
      throw ArgumentError('ActionSchema "type" cannot be empty');
    }

    // Reserved keys that are not part of params
    const reservedKeys = {
      'type', 'params', 'route', 'endpoint', 'method', 'body',
      'onSuccess', 'onError', 'actions', 'condition', 'then', 'else'
    };

    // Collect extra keys into params (for convenience - allows flat action format)
    Map<String, dynamic>? params = json['params'] as Map<String, dynamic>?;
    final extraParams = <String, dynamic>{};
    for (final key in json.keys) {
      if (!reservedKeys.contains(key)) {
        extraParams[key] = json[key];
      }
    }
    if (extraParams.isNotEmpty) {
      params = {...?params, ...extraParams};
    }

    // Safe parsing of nested actions
    final onSuccessMap = toStringKeyedMap(json['onSuccess']);
    final onErrorMap = toStringKeyedMap(json['onError']);
    final thenMap = toStringKeyedMap(json['then']);
    final elseMap = toStringKeyedMap(json['else']);

    // Safe parsing of actions list
    List<ActionSchema>? actionsList;
    if (json['actions'] is List) {
      actionsList = [];
      for (final item in json['actions'] as List) {
        final itemMap = toStringKeyedMap(item);
        if (itemMap != null) {
          actionsList.add(ActionSchema.fromJson(itemMap));
        }
      }
    }

    return ActionSchema(
      type: type,
      params: params,
      route: json['route'] as String?,
      endpoint: json['endpoint'] as String?,
      method: json['method'] as String?,
      body: json['body'],
      onSuccess: onSuccessMap != null ? ActionSchema.fromJson(onSuccessMap) : null,
      onError: onErrorMap != null ? ActionSchema.fromJson(onErrorMap) : null,
      actions: actionsList,
      condition: json['condition'] as String?,
      thenAction: thenMap != null ? ActionSchema.fromJson(thenMap) : null,
      elseAction: elseMap != null ? ActionSchema.fromJson(elseMap) : null,
    );
  }

  /// Converts to JSON
  Map<String, dynamic> toJson() {
    return {
      'type': type,
      if (params != null) 'params': params,
      if (route != null) 'route': route,
      if (endpoint != null) 'endpoint': endpoint,
      if (method != null) 'method': method,
      if (body != null) 'body': body,
      if (onSuccess != null) 'onSuccess': onSuccess!.toJson(),
      if (onError != null) 'onError': onError!.toJson(),
      if (actions != null) 'actions': actions!.map((e) => e.toJson()).toList(),
      if (condition != null) 'condition': condition,
      if (thenAction != null) 'then': thenAction!.toJson(),
      if (elseAction != null) 'else': elseAction!.toJson(),
    };
  }

  @override
  String toString() => 'ActionSchema(type: $type)';
}
