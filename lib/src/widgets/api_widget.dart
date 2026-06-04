import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import '../core/bdui_config.dart';
import '../core/bdui_http_client.dart';
import '../models/api_request.dart';
import '../models/api_response.dart';
import '../models/cache_control.dart';
import '../models/http_method.dart';
import '../utils/bdui_logger.dart';

/// Declarative API widget - FutureBuilder's better alternative
///
/// Automatically handles loading, success, error, and empty states
/// with built-in caching and retry logic.
class ApiWidget extends StatefulWidget {
  /// Pre-built request config. When provided, [endpoint], [method], [headers],
  /// [body], [cacheDuration], [maxRetries], and [timeout] are all derived from
  /// this — the individual params below are ignored.
  final ApiRequest? request;

  /// API endpoint URL. Ignored when [request] is provided.
  final String endpoint;

  /// HTTP method (default: [HttpMethod.get]). Ignored when [request] is provided.
  final HttpMethod method;

  /// Custom HTTP client — inject a [BduiHttpClient] implementation to override
  /// the default network behaviour (useful for testing or custom HTTP libraries).
  final BduiHttpClient? httpClient;

  /// Request headers
  final Map<String, String>? headers;

  /// Request body (for POST/PUT)
  final dynamic body;

  /// Cache duration (null = no cache)
  final Duration? cacheDuration;

  /// Maximum retry attempts. `null` resolves to [BduiConfig.defaultMaxRetries].
  final int? maxRetries;

  /// Per-request timeout. `null` resolves to [BduiConfig.defaultTimeout].
  final Duration? timeout;

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
    this.request,
    this.endpoint = '',
    this.method = HttpMethod.get,
    this.httpClient,
    this.headers,
    this.body,
    this.cacheDuration,
    this.maxRetries,
    this.timeout,
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

  /// Prevent duplicate success/error callbacks for the same data
  String? _lastSuccessHash;
  String? _lastErrorHash;

  /// Track if a request is in flight (prevents polling overlap)
  bool _isRequestInFlight = false;

  /// Generation counter — each fetch increments this so only the latest
  /// whenComplete can clear _isRequestInFlight, preventing a stale request
  /// from unblocking polling too early.
  int _fetchGeneration = 0;

  @override
  void initState() {
    super.initState();
    _fetchData();
    _setupPolling();
  }

  @override
  void didUpdateWidget(ApiWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.request != widget.request ||
        oldWidget.endpoint != widget.endpoint ||
        oldWidget.method != widget.method ||
        oldWidget.headers != widget.headers ||
        oldWidget.body != widget.body) {
      // Force a new fetch even if a prior request is still in-flight.
      // The old future becomes stale — FutureBuilder ignores it once
      // _future is replaced. The generation counter ensures only the
      // latest whenComplete clears the in-flight flag.
      _fetchData(force: true);
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

  void _fetchData({bool force = false}) {
    if (!mounted) return;
    if (_isRequestInFlight && !force) return;

    final gen = ++_fetchGeneration;
    _isRequestInFlight = true;
    setState(() {
      _future = _makeRequest().whenComplete(() {
        if (gen == _fetchGeneration) _isRequestInFlight = false;
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
    // Guard: flat-params path requires a non-empty endpoint.
    if (widget.request == null && widget.endpoint.isEmpty) {
      BduiLogger.warn(
        'ApiWidget: endpoint is empty and no ApiRequest was provided. '
        'Set endpoint or pass a request object.',
      );
      throw Exception('ApiWidget requires a non-empty endpoint or an ApiRequest.');
    }

    final client = widget.httpClient ?? const DefaultBduiHttpClient();

    // When an ApiRequest is provided, use it directly.
    if (widget.request != null) {
      final req = widget.request!;
      if (req.method == HttpMethod.get &&
          _lastCacheControl?.shouldRefreshInBackground == true) {
        return client.getWithRefresh(
          req.endpoint,
          headers: req.headers,
          cacheDuration: _lastCacheControl?.ttl ?? req.cacheDuration,
          maxRetries: req.maxRetries,
          timeout: req.timeout,
          onRefresh: _handleBackgroundRefresh,
        );
      }
      return client.execute(widget.request!);
    }

    // Flat params path — kept for backward compatibility.
    final effectiveRetries = widget.maxRetries ?? BduiConfig.defaultMaxRetries;
    final effectiveTimeout = widget.timeout ?? BduiConfig.defaultTimeout;

    switch (widget.method) {
      case HttpMethod.get:
        if (_lastCacheControl?.shouldRefreshInBackground == true) {
          return client.getWithRefresh(
            widget.endpoint,
            headers: widget.headers,
            cacheDuration: _lastCacheControl?.ttl ?? widget.cacheDuration,
            maxRetries: effectiveRetries,
            timeout: effectiveTimeout,
            onRefresh: _handleBackgroundRefresh,
          );
        }
        return client.get(
          widget.endpoint,
          headers: widget.headers,
          cacheDuration: widget.cacheDuration,
          maxRetries: effectiveRetries,
          timeout: effectiveTimeout,
        );
      case HttpMethod.post:
        return client.post(
          widget.endpoint,
          headers: widget.headers,
          body: widget.body,
          maxRetries: effectiveRetries,
          timeout: effectiveTimeout,
        );
      case HttpMethod.put:
        return client.put(
          widget.endpoint,
          headers: widget.headers,
          body: widget.body,
          maxRetries: effectiveRetries,
          timeout: effectiveTimeout,
        );
      case HttpMethod.patch:
        return client.patch(
          widget.endpoint,
          headers: widget.headers,
          body: widget.body,
          maxRetries: effectiveRetries,
          timeout: effectiveTimeout,
        );
      case HttpMethod.delete:
        return client.delete(
          widget.endpoint,
          headers: widget.headers,
          maxRetries: effectiveRetries,
          timeout: effectiveTimeout,
        );
      case HttpMethod.head:
        return client.head(
          widget.endpoint,
          headers: widget.headers,
          maxRetries: effectiveRetries,
          timeout: effectiveTimeout,
        );
      case HttpMethod.options:
        return client.options(
          widget.endpoint,
          headers: widget.headers,
          maxRetries: effectiveRetries,
          timeout: effectiveTimeout,
        );
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

          _invokeCallbackAfterBuild(
            () => widget.onError?.call(error),
            getHash: () => _lastErrorHash,
            setHash: (h) => _lastErrorHash = h,
            dataHash: error.hashCode.toString(),
          );

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

          _invokeCallbackAfterBuild(
            () => widget.onSuccess?.call(data),
            getHash: () => _lastSuccessHash,
            setHash: (h) => _lastSuccessHash = h,
            dataHash: data.hashCode.toString(),
          );

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

  void _invokeCallbackAfterBuild(
    VoidCallback callback, {
    required String? Function() getHash,
    required void Function(String?) setHash,
    String? dataHash,
  }) {
    if (dataHash != null && getHash() == dataHash) return;

    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (dataHash != null) setHash(dataHash);
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
