import 'cache_control.dart';

/// API Response Model
class ApiResponse {
  /// HTTP status code
  final int statusCode;

  /// Response data (parsed JSON)
  final dynamic data;

  /// Whether response came from cache
  final bool fromCache;

  /// Response headers
  final Map<String, String>? headers;

  /// Cache control from response (if provided by backend)
  final CacheControl? cacheControl;

  /// Creates an API response
  const ApiResponse({
    required this.statusCode,
    required this.data,
    this.fromCache = false,
    this.headers,
    this.cacheControl,
  });

  /// Whether the response is successful (2xx)
  bool get isSuccess => statusCode >= 200 && statusCode < 300;

  /// Whether the response is a client error (4xx)
  bool get isClientError => statusCode >= 400 && statusCode < 500;

  /// Whether the response is a server error (5xx)
  bool get isServerError => statusCode >= 500;

  @override
  String toString() =>
      'ApiResponse(status: $statusCode, fromCache: $fromCache)';
}
