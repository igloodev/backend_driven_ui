import '../core/bdui_config.dart';
import 'http_method.dart';

/// Encapsulates all parameters for a single API call.
///
/// Pass an [ApiRequest] to [ApiWidget] instead of individual params when you
/// want to build, reuse, or compose request configs outside the widget tree.
///
/// [maxRetries] and [timeout] default to [BduiConfig.defaultMaxRetries] and
/// [BduiConfig.defaultTimeout] when left `null` — so updating [BduiConfig]
/// at app startup automatically applies to all requests.
///
/// ```dart
/// final request = ApiRequest(
///   endpoint: '/api/products',
///   method: HttpMethod.get,
///   headers: {'Authorization': 'Bearer $token'},
///   cacheDuration: Duration(minutes: 5),
/// );
///
/// ApiWidget(request: request, successWidget: (data) => ProductList(data))
/// ```
class ApiRequest {
  /// API endpoint — full URL or relative path resolved against [BduiConfig.baseUrl].
  final String endpoint;

  /// HTTP method. Defaults to [HttpMethod.get].
  final HttpMethod method;

  /// Request headers merged on top of [BduiConfig.defaultContentType].
  final Map<String, String>? headers;

  /// Request body for [HttpMethod.post] and [HttpMethod.put].
  final dynamic body;

  /// How long to cache a successful response. `null` disables caching.
  final Duration? cacheDuration;

  /// Maximum retry attempts. `null` resolves to [BduiConfig.defaultMaxRetries].
  final int? maxRetries;

  /// Per-request timeout. `null` resolves to [BduiConfig.defaultTimeout].
  final Duration? timeout;

  /// Creates an [ApiRequest].
  const ApiRequest({
    required this.endpoint,
    this.method = HttpMethod.get,
    this.headers,
    this.body,
    this.cacheDuration,
    this.maxRetries,
    this.timeout,
  });

  // Sentinel used by copyWith to distinguish "not passed" from explicit null.
  static const _unset = Object();

  /// Returns a copy of this request with the given fields replaced.
  ///
  /// Pass `body: null` explicitly to clear the body on the copy:
  /// ```dart
  /// final getRequest = postRequest.copyWith(method: HttpMethod.get, body: null);
  /// ```
  ApiRequest copyWith({
    String? endpoint,
    HttpMethod? method,
    Map<String, String>? headers,
    Object? body = _unset,
    Duration? cacheDuration,
    int? maxRetries,
    Duration? timeout,
  }) {
    return ApiRequest(
      endpoint: endpoint ?? this.endpoint,
      method: method ?? this.method,
      headers: headers ?? this.headers,
      body: identical(body, _unset) ? this.body : body,
      cacheDuration: cacheDuration ?? this.cacheDuration,
      maxRetries: maxRetries ?? this.maxRetries,
      timeout: timeout ?? this.timeout,
    );
  }

  @override
  String toString() => 'ApiRequest(${method.value} $endpoint)';
}
