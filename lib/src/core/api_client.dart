import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart' show visibleForTesting;
import 'package:http/http.dart' as http;

import '../models/api_exception.dart';
import '../models/api_response.dart';
import '../models/cache_control.dart';
import '../utils/bdui_logger.dart';
import '../utils/url_validator.dart';
import 'api_cache.dart';
import 'bdui_config.dart';
import 'retry_handler.dart';

/// Lightweight HTTP client with retry and caching
class ApiClient {
  /// HTTP client instance
  static http.Client? _httpClient;

  /// Track active requests to prevent disposal during in-flight requests
  static int _activeRequests = 0;

  /// Flag to indicate disposal was requested
  static bool _disposalRequested = false;

  /// Guard to prevent _performDisposal() from running more than once
  /// if multiple in-flight requests complete at the same time.
  static bool _isDisposing = false;

  /// Inject a custom HTTP client for testing.
  @visibleForTesting
  static void setHttpClientForTesting(http.Client client) {
    _httpClient = client;
  }

  /// Get or create the HTTP client
  static http.Client _getOrCreateClient() {
    if (_disposalRequested) {
      // Reset disposal flag - user wants to make new requests
      _disposalRequested = false;
      _isDisposing = false;
    }
    return _httpClient ??= http.Client();
  }

  static ApiCache? _cacheInstance;

  /// Get the cache instance (lazy init with BduiConfig value)
  static ApiCache get _cache {
    return _cacheInstance ??= ApiCache(maxEntries: BduiConfig.maxCacheEntries);
  }

  /// Validate URL to prevent SSRF attacks
  static bool isUrlSafe(String url) => UrlValidator.isUrlSafe(url);

  /// Resolve a URL against [BduiConfig.baseUrl].
  ///
  /// Full URLs (starting with `http://` or `https://`) are returned unchanged.
  /// Relative paths are prepended with [BduiConfig.baseUrl].
  static String resolveUrl(String url) {
    if (url.startsWith('http://') || url.startsWith('https://')) return url;
    final base = BduiConfig.baseUrl;
    if (base.isEmpty) return url;
    if (base.endsWith('/')) {
      return '$base${url.startsWith('/') ? url.substring(1) : url}';
    }
    return '$base${url.startsWith('/') ? url : '/$url'}';
  }

  /// GET request with caching and retry
  static Future<ApiResponse> get(
    String url, {
    Map<String, String>? headers,
    Duration? cacheDuration,
    int maxRetries = 3,
    Duration timeout = const Duration(seconds: 30),
  }) async {
    url = resolveUrl(url);
    BduiLogger.network('API GET: $url');

    // Check cache first
    if (cacheDuration != null) {
      final cached = _cache.get<Map<String, dynamic>>(url);
      if (cached != null) {
        BduiLogger.cache('Cache HIT - Returning cached data');
        return ApiResponse(
          statusCode: 200,
          data: cached,
          fromCache: true,
        );
      }
      BduiLogger.cache('Cache MISS - Fetching from network');
    }

    // Fetch with retry
    BduiLogger.network('Making HTTP request (max retries: $maxRetries)');
    final response = await RetryHandler.retry(
      action: () => _fetch('GET', url, headers: headers, timeout: timeout),
      maxRetries: maxRetries,
      shouldRetry: RetryHandler.defaultShouldRetry,
    );

    BduiLogger.success('Response received - Status: ${response.statusCode}');

    // Determine cache behavior from response or fallback to client settings
    final serverCacheControl = response.cacheControl;
    final shouldCache =
        serverCacheControl?.isCacheEnabled ?? (cacheDuration != null);
    final effectiveTTL = serverCacheControl?.ttl ?? cacheDuration;

    if (serverCacheControl != null) {
      BduiLogger.cache(
          'Server cache control: ${serverCacheControl.policy}, TTL: ${serverCacheControl.ttlSeconds}s');
    }

    // Cache successful response
    if (shouldCache &&
        response.isSuccess &&
        response.data != null &&
        effectiveTTL != null) {
      BduiLogger.cache('Caching response for ${effectiveTTL.inSeconds} seconds');
      _cache.set(url, response.data, duration: effectiveTTL);
    } else if (serverCacheControl?.policy == CachePolicy.noCache) {
      BduiLogger.cache('Cache disabled by server - not caching');
      _cache.remove(url);
    }

    return response;
  }

  /// POST request with retry
  static Future<ApiResponse> post(
    String url, {
    Map<String, String>? headers,
    dynamic body,
    int maxRetries = 3,
    Duration timeout = const Duration(seconds: 30),
  }) async {
    url = resolveUrl(url);
    return RetryHandler.retry(
      action: () => _fetch('POST', url,
          headers: headers, body: body, timeout: timeout),
      maxRetries: maxRetries,
      shouldRetry: RetryHandler.defaultShouldRetry,
    );
  }

  /// PUT request with retry
  static Future<ApiResponse> put(
    String url, {
    Map<String, String>? headers,
    dynamic body,
    int maxRetries = 3,
    Duration timeout = const Duration(seconds: 30),
  }) async {
    url = resolveUrl(url);
    return RetryHandler.retry(
      action: () =>
          _fetch('PUT', url, headers: headers, body: body, timeout: timeout),
      maxRetries: maxRetries,
      shouldRetry: RetryHandler.defaultShouldRetry,
    );
  }

  /// DELETE request with retry
  static Future<ApiResponse> delete(
    String url, {
    Map<String, String>? headers,
    int maxRetries = 3,
    Duration timeout = const Duration(seconds: 30),
  }) async {
    url = resolveUrl(url);
    return RetryHandler.retry(
      action: () => _fetch('DELETE', url, headers: headers, timeout: timeout),
      maxRetries: maxRetries,
      shouldRetry: RetryHandler.defaultShouldRetry,
    );
  }

  /// GET with background refresh (stale-while-revalidate)
  static Future<ApiResponse> getWithRefresh(
    String url, {
    Map<String, String>? headers,
    Duration? cacheDuration,
    int maxRetries = 3,
    Duration timeout = const Duration(seconds: 30),
    void Function(ApiResponse freshResponse)? onRefresh,
  }) async {
    url = resolveUrl(url);
    final cached = _cache.get<Map<String, dynamic>>(url);

    if (cached != null) {
      BduiLogger.cache('Returning cached data, refreshing in background...');

      // Fire and forget background refresh
      _refreshInBackground(
        url,
        headers: headers,
        cacheDuration: cacheDuration,
        maxRetries: maxRetries,
        timeout: timeout,
        onRefresh: onRefresh,
      );

      return ApiResponse(
        statusCode: 200,
        data: cached,
        fromCache: true,
      );
    }

    return get(
      url,
      headers: headers,
      cacheDuration: cacheDuration,
      maxRetries: maxRetries,
      timeout: timeout,
    );
  }

  /// Background refresh helper
  static Future<void> _refreshInBackground(
    String url, {
    Map<String, String>? headers,
    Duration? cacheDuration,
    int maxRetries = 3,
    Duration timeout = const Duration(seconds: 30),
    void Function(ApiResponse freshResponse)? onRefresh,
  }) async {
    try {
      BduiLogger.network('Background refresh: $url');
      final response =
          await _fetch('GET', url, headers: headers, timeout: timeout);

      if (response.isSuccess && response.data != null) {
        final effectiveTTL = cacheDuration ?? BduiConfig.defaultCacheDuration;
        _cache.set(url, response.data, duration: effectiveTTL);
        BduiLogger.success('Background refresh complete');
        onRefresh?.call(response);
      } else {
        BduiLogger.warn(
          'Background refresh returned ${response.statusCode} for $url — '
          'keeping stale cache. The cache entry will expire normally.',
        );
      }
    } catch (e) {
      BduiLogger.warn(
        'Background refresh failed for $url — keeping stale cache: $e. '
        'The cache entry will expire normally.',
      );
    }
  }

  /// Clear cache
  static void clearCache() => _cache.clear();

  /// Remove specific cache entry
  static void removeCacheEntry(String key) => _cache.remove(key);

  /// Internal fetch implementation
  static Future<ApiResponse> _fetch(
    String method,
    String url, {
    Map<String, String>? headers,
    dynamic body,
    required Duration timeout,
  }) async {
    // Validate URL to prevent SSRF attacks
    if (!isUrlSafe(url)) {
      throw ApiException(
        message: 'URL blocked for security reasons: $url',
      );
    }

    // Track active request
    _activeRequests++;

    try {
      final uri = Uri.parse(url);
      http.Response response;

      final effectiveHeaders = {
        'Content-Type': BduiConfig.defaultContentType,
        ...?headers,
      };

      final client = _getOrCreateClient();

      switch (method) {
        case 'GET':
          response =
              await client.get(uri, headers: effectiveHeaders).timeout(timeout);
          break;
        case 'POST':
          response = await client
              .post(uri,
                  headers: effectiveHeaders,
                  body: body != null ? jsonEncode(body) : null)
              .timeout(timeout);
          break;
        case 'PUT':
          response = await client
              .put(uri,
                  headers: effectiveHeaders,
                  body: body != null ? jsonEncode(body) : null)
              .timeout(timeout);
          break;
        case 'DELETE':
          response = await client
              .delete(uri, headers: effectiveHeaders)
              .timeout(timeout);
          break;
        default:
          throw ApiException(message: 'Unsupported HTTP method: $method');
      }

      if (response.statusCode >= 400) {
        throw ApiException(
          message: _parseErrorMessage(response),
          statusCode: response.statusCode,
        );
      }

      dynamic data;
      CacheControl? cacheControl;

      if (response.body.isNotEmpty) {
        try {
          data = jsonDecode(response.body);

          if (data is Map<String, dynamic>) {
            cacheControl = _extractCacheControl(data);
            // Only unwrap 'ui'/'data' when the value is itself a Map.
            // A non-Map value (String, List, etc.) is left as-is so
            // the caller receives the raw decoded body rather than crashing.
            if (data.containsKey('ui') &&
                data['ui'] is Map<String, dynamic>) {
              data = data['ui'] as Map<String, dynamic>;
            } else if (data.containsKey('data') &&
                data['data'] is Map<String, dynamic>) {
              data = data['data'] as Map<String, dynamic>;
            }
          }
        } catch (e) {
          throw ApiException(
            message: 'Invalid JSON response: ${e.toString()}',
            statusCode: response.statusCode,
          );
        }
      }

      return ApiResponse(
        statusCode: response.statusCode,
        data: data,
        headers: response.headers,
        cacheControl: cacheControl,
      );
    } on TimeoutException {
      throw const ApiException(
        message: 'Request timeout. Please check your internet connection.',
      );
    } on SocketException {
      throw const ApiException(
        message: 'No internet connection. Please check your network.',
      );
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(
        message: 'Request failed: ${e.toString()}',
        originalError: e,
      );
    } finally {
      // Decrement active requests
      _activeRequests--;

      // If disposal was requested and no active requests, dispose now
      if (_disposalRequested && _activeRequests == 0) {
        _performDisposal();
      }
    }
  }

  static CacheControl? _extractCacheControl(Map<String, dynamic> json) {
    if (json.containsKey('cachePolicy') || json.containsKey('cacheTTL')) {
      return CacheControl.fromJson(json);
    }
    return null;
  }

  static String _parseErrorMessage(http.Response response) {
    try {
      final data = jsonDecode(response.body);
      if (data is Map) {
        return data['message'] ?? data['error'] ?? 'HTTP ${response.statusCode}';
      }
    } catch (_) {}
    return 'HTTP ${response.statusCode}: ${response.reasonPhrase}';
  }

  /// Dispose resources safely
  ///
  /// If requests are in flight, marks for disposal after completion.
  static void dispose() {
    if (_activeRequests > 0) {
      BduiLogger.debug(
          'ApiClient: Disposal requested, waiting for $_activeRequests active requests');
      _disposalRequested = true;
      return;
    }
    _performDisposal();
  }

  /// Actually perform the disposal.
  ///
  /// The [_isDisposing] guard ensures this runs at most once even if multiple
  /// in-flight requests complete simultaneously and both see _activeRequests==0.
  static void _performDisposal() {
    if (_isDisposing) return;
    _isDisposing = true;

    _httpClient?.close();
    _httpClient = null;
    _cacheInstance?.dispose();
    _cacheInstance = null;
    _disposalRequested = false;
    _isDisposing = false;
    BduiLogger.debug('ApiClient: Disposed');
  }

  /// Reset the client (for testing or network changes)
  static void reset() {
    if (_activeRequests > 0) {
      BduiLogger.warn(
          'ApiClient: Reset called with $_activeRequests active requests');
    }
    _httpClient?.close();
    _httpClient = null;
  }

  /// Check if there are active requests (for testing)
  static bool get hasActiveRequests => _activeRequests > 0;
}
