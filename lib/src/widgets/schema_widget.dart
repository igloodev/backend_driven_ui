import 'package:flutter/material.dart';

import '../handlers/action_handler.dart';
import '../models/widget_schema.dart';
import '../parser/schema_parser.dart';

/// Widget that renders a WidgetSchema
///
/// This widget internally uses SchemaParser to convert JSON schemas
/// into Flutter widgets. Users don't need to manage the parser themselves.
///
/// The parser is cached in state to avoid recreation on every build.
class SchemaWidget extends StatefulWidget {
  /// The widget schema to render
  final WidgetSchema schema;

  /// Optional custom parser (uses default if not provided)
  final SchemaParser? parser;

  /// Callback for custom action handling
  final CustomActionCallback? onCustomAction;

  /// Callback for navigation - allows app to override default navigation
  final NavigationCallback? onNavigate;

  /// Callback for API success
  final ApiCallback? onApiSuccess;

  /// Callback for API errors
  final ApiErrorCallback? onApiError;

  const SchemaWidget({
    super.key,
    required this.schema,
    this.parser,
    this.onCustomAction,
    this.onNavigate,
    this.onApiSuccess,
    this.onApiError,
  });

  /// Create from JSON directly
  factory SchemaWidget.fromJson(
    Map<String, dynamic> json, {
    SchemaParser? parser,
    CustomActionCallback? onCustomAction,
    NavigationCallback? onNavigate,
    ApiCallback? onApiSuccess,
    ApiErrorCallback? onApiError,
  }) {
    return SchemaWidget(
      schema: WidgetSchema.fromJson(json),
      parser: parser,
      onCustomAction: onCustomAction,
      onNavigate: onNavigate,
      onApiSuccess: onApiSuccess,
      onApiError: onApiError,
    );
  }

  @override
  State<SchemaWidget> createState() => _SchemaWidgetState();
}

class _SchemaWidgetState extends State<SchemaWidget> {
  late SchemaParser _parser;

  @override
  void initState() {
    super.initState();
    _initParser();
  }

  @override
  void didUpdateWidget(SchemaWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Recreate parser if callbacks or parser changed
    if (widget.parser != oldWidget.parser ||
        widget.onCustomAction != oldWidget.onCustomAction ||
        widget.onNavigate != oldWidget.onNavigate ||
        widget.onApiSuccess != oldWidget.onApiSuccess ||
        widget.onApiError != oldWidget.onApiError) {
      _initParser();
    }
  }

  void _initParser() {
    _parser = widget.parser ?? SchemaParser(
      onCustomAction: widget.onCustomAction,
      onNavigate: widget.onNavigate,
      onApiSuccess: widget.onApiSuccess,
      onApiError: widget.onApiError,
    );
  }

  @override
  Widget build(BuildContext context) {
    return _parser.parse(widget.schema, context);
  }
}
