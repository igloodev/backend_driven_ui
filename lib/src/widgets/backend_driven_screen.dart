import 'package:flutter/material.dart';

import '../core/api_client.dart';
import '../core/bdui_config.dart';
import '../handlers/action_handler.dart';
import '../models/http_method.dart';
import '../models/widget_schema.dart';
import '../parser/schema_parser.dart';

/// A screen that renders UI from backend JSON schema
class BackendDrivenScreen extends StatefulWidget {
  /// API endpoint to fetch the screen schema
  final String endpoint;

  /// HTTP method (default: [HttpMethod.get])
  final HttpMethod method;

  /// Request body for POST/PUT requests
  final dynamic body;

  /// Request headers (e.g. `{'Authorization': 'Bearer $token'}`)
  final Map<String, String>? headers;

  /// Cache duration for the schema
  final Duration? cacheDuration;

  /// Maximum retry attempts. `null` resolves to [BduiConfig.defaultMaxRetries].
  final int? maxRetries;

  /// Per-request timeout. `null` resolves to [BduiConfig.defaultTimeout].
  final Duration? timeout;

  /// Custom schema parser
  final SchemaParser? parser;

  /// Loading widget
  final Widget loadingWidget;

  /// Error widget builder
  final Widget Function(String error)? errorWidget;

  /// Callback when schema is loaded
  final void Function(Map<String, dynamic> schema)? onSchemaLoaded;

  /// Callback when navigation is requested
  final NavigationCallback? onNavigate;

  /// Callback for URL launching - wire in url_launcher or any custom handler.
  ///
  /// See [LaunchUrlCallback] for usage example.
  final LaunchUrlCallback? onLaunchUrl;

  /// Callback for custom actions
  final CustomActionCallback? onCustomAction;

  /// Callback for API success
  final ApiCallback? onApiSuccess;

  /// Callback for API errors
  final ApiErrorCallback? onApiError;

  /// Whether to show retry button on error
  final bool showRetryButton;

  const BackendDrivenScreen({
    super.key,
    required this.endpoint,
    this.method = HttpMethod.get,
    this.body,
    this.headers,
    this.cacheDuration,
    this.maxRetries,
    this.timeout,
    this.parser,
    this.loadingWidget = const Center(child: CircularProgressIndicator()),
    this.errorWidget,
    this.onSchemaLoaded,
    this.onNavigate,
    this.onLaunchUrl,
    this.onCustomAction,
    this.onApiSuccess,
    this.onApiError,
    this.showRetryButton = true,
  });

  @override
  State<BackendDrivenScreen> createState() => _BackendDrivenScreenState();
}

class _BackendDrivenScreenState extends State<BackendDrivenScreen> {
  late SchemaParser _parser;
  late Future<WidgetSchema> _schemaFuture;

  @override
  void initState() {
    super.initState();
    _initParser();
    _schemaFuture = _fetchSchema();
  }

  @override
  void didUpdateWidget(BackendDrivenScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Recreate parser if callbacks changed
    if (widget.parser != oldWidget.parser ||
        widget.onNavigate != oldWidget.onNavigate ||
        widget.onLaunchUrl != oldWidget.onLaunchUrl ||
        widget.onCustomAction != oldWidget.onCustomAction ||
        widget.onApiSuccess != oldWidget.onApiSuccess ||
        widget.onApiError != oldWidget.onApiError) {
      _initParser();
    }
    // Refetch if endpoint or request parameters changed
    if (widget.endpoint != oldWidget.endpoint ||
        widget.method != oldWidget.method ||
        widget.headers != oldWidget.headers ||
        widget.body != oldWidget.body) {
      setState(() {
        _schemaFuture = _fetchSchema();
      });
    }
  }

  void _initParser() {
    _parser = widget.parser ??
        SchemaParser(
          onNavigate: widget.onNavigate,
          onLaunchUrl: widget.onLaunchUrl,
          onCustomAction: widget.onCustomAction,
          onApiSuccess: widget.onApiSuccess,
          onApiError: widget.onApiError,
        );
  }

  Future<WidgetSchema> _fetchSchema() async {
    try {
      final response = await _makeApiCall();

      if (response.data is! Map<String, dynamic>) {
        throw Exception('Invalid schema format: Expected JSON object');
      }

      final schemaData = response.data as Map<String, dynamic>;

      if (widget.onSchemaLoaded != null) {
        widget.onSchemaLoaded!(schemaData);
      }

      return WidgetSchema.fromJson(schemaData);
    } catch (e) {
      throw Exception('Failed to fetch schema: $e');
    }
  }

  Future<dynamic> _makeApiCall() async {
    final effectiveRetries = widget.maxRetries ?? BduiConfig.defaultMaxRetries;
    final effectiveTimeout = widget.timeout ?? BduiConfig.defaultTimeout;
    switch (widget.method) {
      case HttpMethod.get:
        return await ApiClient.get(
          widget.endpoint,
          headers: widget.headers,
          cacheDuration: widget.cacheDuration,
          maxRetries: effectiveRetries,
          timeout: effectiveTimeout,
        );
      case HttpMethod.post:
        return await ApiClient.post(
          widget.endpoint,
          headers: widget.headers,
          body: widget.body,
          maxRetries: effectiveRetries,
          timeout: effectiveTimeout,
        );
      case HttpMethod.put:
        return await ApiClient.put(
          widget.endpoint,
          headers: widget.headers,
          body: widget.body,
          maxRetries: effectiveRetries,
          timeout: effectiveTimeout,
        );
      case HttpMethod.patch:
        return await ApiClient.patch(
          widget.endpoint,
          headers: widget.headers,
          body: widget.body,
          maxRetries: effectiveRetries,
          timeout: effectiveTimeout,
        );
      case HttpMethod.delete:
        return await ApiClient.delete(
          widget.endpoint,
          headers: widget.headers,
          maxRetries: effectiveRetries,
          timeout: effectiveTimeout,
        );
    }
  }

  void _retry() {
    setState(() {
      _schemaFuture = _fetchSchema();
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<WidgetSchema>(
      future: _schemaFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return widget.loadingWidget;
        }

        if (snapshot.hasError) {
          return widget.errorWidget?.call(snapshot.error.toString()) ??
              _buildDefaultError(snapshot.error.toString());
        }

        if (!snapshot.hasData) {
          return widget.errorWidget?.call('No data received') ??
              _buildDefaultError('No data received');
        }

        return _parser.parse(snapshot.data!, context);
      },
    );
  }

  Widget _buildDefaultError(String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              color: Colors.red,
              size: 48,
            ),
            const SizedBox(height: 16),
            Text(
              'Failed to load screen',
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              error,
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            if (widget.showRetryButton) ...[
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _retry,
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
