import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import '../core/api_client.dart';
import '../models/api_response.dart';
import '../models/cache_control.dart';
import '../utils/bdui_logger.dart';

/// Declarative API widget - FutureBuilder's better alternative
///
/// Automatically handles loading, success, error, and empty states
/// with built-in caching and retry logic.
class ApiWidget extends StatefulWidget {
  /// API endpoint URL
  final String endpoint;

  /// HTTP method (default: GET)
  final String method;

  /// Request headers
  final Map<String, String>? headers;

  /// Request body (for POST/PUT)
  final dynamic body;

  /// Cache duration (null = no cache)
  final Duration? cacheDuration;

  /// Maximum retry attempts
  final int maxRetries;

  /// Request timeout
  final Duration timeout;

  /// Auto-refresh interval (null = no polling)
  final Duration? pollInterval;

  /// Widget to show while loading
  final Widget? loadingWidget;

  /// Widget builder for successful response
  final Widget Function(dynamic data)? successWidget;

  /// Widget builder for error state
  final Widget Function(String error)? errorWidget;

  /// Widget to show for empty data
  final Widget? emptyWidget;

  /// Callback on successful response
  final void Function(dynamic data)? onSuccess;

  /// Callback on error
  final void Function(String error)? onError;

  /// Callback when background refresh completes
  final void Function(dynamic data)? onBackgroundRefresh;

  /// Whether to show retry button on error
  final bool showRetryButton;

  const ApiWidget({
    super.key,
    required this.endpoint,
    this.method = 'GET',
    this.headers,
    this.body,
    this.cacheDuration,
    this.maxRetries = 3,
    this.timeout = const Duration(seconds: 30),
    this.pollInterval,
    this.loadingWidget,
    this.successWidget,
    this.errorWidget,
    this.emptyWidget,
    this.onSuccess,
    this.onError,
    this.onBackgroundRefresh,
    this.showRetryButton = true,
  });

  @override
  State<ApiWidget> createState() => _ApiWidgetState();
}

class _ApiWidgetState extends State<ApiWidget> {
  late Future<ApiResponse> _future;
  Timer? _pollTimer;
  CacheControl? _lastCacheControl;

  /// Prevent duplicate callbacks for same data
  String? _lastCallbackDataHash;

  /// Track if a request is in flight (prevents polling overlap)
  bool _isRequestInFlight = false;

  @override
  void initState() {
    super.initState();
    _fetchData();
    _setupPolling();
  }

  @override
  void didUpdateWidget(ApiWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.endpoint != widget.endpoint ||
        oldWidget.method != widget.method ||
        oldWidget.body != widget.body) {
      _fetchData();
    }

    if (oldWidget.pollInterval != widget.pollInterval) {
      _setupPolling();
    }
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    _pollTimer = null;
    super.dispose();
  }

  void _setupPolling() {
    _pollTimer?.cancel();
    _pollTimer = null;

    if (widget.pollInterval != null) {
      _pollTimer = Timer.periodic(widget.pollInterval!, (_) {
        // Only fetch if mounted AND no request already in flight
        if (mounted && !_isRequestInFlight) {
          _fetchData();
        }
      });
    }
  }

  void _fetchData() {
    if (!mounted || _isRequestInFlight) return;

    _isRequestInFlight = true;
    setState(() {
      _future = _makeRequest().whenComplete(() {
        _isRequestInFlight = false;
      });
    });
  }

  void _handleBackgroundRefresh(ApiResponse response) {
    if (!mounted) return;

    if (response.cacheControl != null) {
      _lastCacheControl = response.cacheControl;
    }

    widget.onBackgroundRefresh?.call(response.data);

    setState(() {
      _future = Future.value(response);
    });
  }

  Future<ApiResponse> _makeRequest() async {
    switch (widget.method.toUpperCase()) {
      case 'GET':
        if (_lastCacheControl?.shouldRefreshInBackground == true) {
          return ApiClient.getWithRefresh(
            widget.endpoint,
            headers: widget.headers,
            cacheDuration: _lastCacheControl?.ttl ?? widget.cacheDuration,
            maxRetries: widget.maxRetries,
            timeout: widget.timeout,
            onRefresh: _handleBackgroundRefresh,
          );
        }
        return ApiClient.get(
          widget.endpoint,
          headers: widget.headers,
          cacheDuration: widget.cacheDuration,
          maxRetries: widget.maxRetries,
          timeout: widget.timeout,
        );
      case 'POST':
        return ApiClient.post(
          widget.endpoint,
          headers: widget.headers,
          body: widget.body,
          maxRetries: widget.maxRetries,
          timeout: widget.timeout,
        );
      case 'PUT':
        return ApiClient.put(
          widget.endpoint,
          headers: widget.headers,
          body: widget.body,
          maxRetries: widget.maxRetries,
          timeout: widget.timeout,
        );
      case 'DELETE':
        return ApiClient.delete(
          widget.endpoint,
          headers: widget.headers,
          maxRetries: widget.maxRetries,
          timeout: widget.timeout,
        );
      default:
        throw Exception('Unsupported HTTP method: ${widget.method}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<ApiResponse>(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return widget.loadingWidget ?? _buildDefaultLoading();
        }

        if (snapshot.hasError) {
          final error = snapshot.error.toString();

          _invokeCallbackAfterBuild(() {
            widget.onError?.call(error);
          });

          Widget errorWidget;
          try {
            errorWidget =
                widget.errorWidget?.call(error) ?? _buildDefaultError(error);
          } catch (e) {
            BduiLogger.warn('Error in errorWidget builder: $e');
            errorWidget = _buildDefaultError(error);
          }

          if (widget.showRetryButton) {
            return SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  errorWidget,
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: _fetchData,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Retry'),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            );
          }

          return errorWidget;
        }

        if (snapshot.hasData) {
          final response = snapshot.data!;
          final data = response.data;

          if (response.cacheControl != null) {
            _lastCacheControl = response.cacheControl;
          }

          if (_isEmpty(data)) {
            try {
              return widget.emptyWidget ?? _buildDefaultEmpty();
            } catch (e) {
              BduiLogger.warn('Error in emptyWidget: $e');
              return _buildDefaultEmpty();
            }
          }

          _invokeCallbackAfterBuild(() {
            widget.onSuccess?.call(data);
          }, dataHash: data.hashCode.toString());

          try {
            return widget.successWidget?.call(data) ??
                _buildDefaultSuccess(data);
          } catch (e) {
            BduiLogger.warn('Error in successWidget builder: $e');
            return _buildDefaultSuccess(data);
          }
        }

        try {
          return widget.errorWidget?.call('Unknown error occurred') ??
              _buildDefaultError('Unknown error occurred');
        } catch (e) {
          BduiLogger.error('Error in unknown state: $e');
          return _buildDefaultError('Unknown error occurred');
        }
      },
    );
  }

  void _invokeCallbackAfterBuild(VoidCallback callback, {String? dataHash}) {
    if (dataHash != null && _lastCallbackDataHash == dataHash) {
      return;
    }

    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      if (dataHash != null) {
        _lastCallbackDataHash = dataHash;
      }

      try {
        callback();
      } catch (e) {
        BduiLogger.warn('Error in callback: $e');
      }
    });
  }

  bool _isEmpty(dynamic data) {
    if (data == null) return true;
    if (data is List) return data.isEmpty;
    if (data is Map) return data.isEmpty;
    if (data is String) return data.trim().isEmpty;
    return false;
  }

  Widget _buildDefaultLoading() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text(
            'Loading...',
            style: TextStyle(fontSize: 14, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildDefaultError(String error) {
    return Center(
      child: Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.red[50],
          border: Border.all(color: Colors.red, width: 2),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 48),
            const SizedBox(height: 16),
            const Text(
              'Something went wrong',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              error,
              style: TextStyle(fontSize: 14, color: Colors.grey[700]),
              textAlign: TextAlign.center,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDefaultEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.inbox_outlined, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'No data found',
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildDefaultSuccess(dynamic data) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.check_circle, color: Colors.green, size: 20),
                SizedBox(width: 8),
                Text(
                  'Success',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: SelectableText(
                data.toString(),
                style: const TextStyle(fontSize: 12, fontFamily: 'monospace'),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Add successWidget parameter to customize this view',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
