import '../models/api_request.dart';
import '../models/api_response.dart';
import '../models/http_method.dart';
import 'api_client.dart';
import 'bdui_config.dart';

/// Abstract HTTP client interface consumed by [ApiWidget].
///
/// Implement this to provide a custom HTTP backend — useful for testing,
/// mocking, or swapping in a different HTTP library without touching widget code.
///
/// ```dart
/// class MockHttpClient implements BduiHttpClient {
///   @override
///   Future<ApiResponse> get(String url, {
///     Map<String, String>? headers,
///     Duration? cacheDuration,
///     int? maxRetries,
///     Duration? timeout,
///   }) async {
///     return ApiResponse(statusCode: 200, data: {'key': 'value'});
///   }
///   // implement remaining methods ...
/// }
///
/// ApiWidget(
///   endpoint: '/products',
///   httpClient: MockHttpClient(),
///   successWidget: (data) => Text(data['key']),
/// )
/// ```
abstract class BduiHttpClient {
  /// Performs a GET request.
  ///
  /// [maxRetries] and [timeout] default to [BduiConfig.defaultMaxRetries] and
  /// [BduiConfig.defaultTimeout] when `null`.
  Future<ApiResponse> get(
    String url, {
    Map<String, String>? headers,
    Duration? cacheDuration,
    int? maxRetries,
    Duration? timeout,
  });

  /// Performs a GET request with stale-while-revalidate caching.
  ///
  /// Returns cached data immediately and refreshes in the background,
  /// calling [onRefresh] with the fresh response when done.
  Future<ApiResponse> getWithRefresh(
    String url, {
    Map<String, String>? headers,
    Duration? cacheDuration,
    int? maxRetries,
    Duration? timeout,
    void Function(ApiResponse freshResponse)? onRefresh,
  });

  /// Performs a POST request.
  Future<ApiResponse> post(
    String url, {
    Map<String, String>? headers,
    dynamic body,
    int? maxRetries,
    Duration? timeout,
  });

  /// Performs a PUT request.
  Future<ApiResponse> put(
    String url, {
    Map<String, String>? headers,
    dynamic body,
    int? maxRetries,
    Duration? timeout,
  });

  /// Performs a PATCH request.
  Future<ApiResponse> patch(
    String url, {
    Map<String, String>? headers,
    dynamic body,
    int? maxRetries,
    Duration? timeout,
  });

  /// Performs a DELETE request.
  Future<ApiResponse> delete(
    String url, {
    Map<String, String>? headers,
    int? maxRetries,
    Duration? timeout,
  });

  /// Executes an [ApiRequest] — routes to [get], [post], [put], or [delete]
  /// based on [ApiRequest.method].
  ///
  /// Prefer this over calling the individual methods directly when you already
  /// have an [ApiRequest] object.
  Future<ApiResponse> execute(ApiRequest request);
}

/// Default [BduiHttpClient] implementation backed by [ApiClient].
///
/// `null` values for [maxRetries] and [timeout] resolve to
/// [BduiConfig.defaultMaxRetries] and [BduiConfig.defaultTimeout] respectively,
/// so updating [BduiConfig] at startup automatically applies everywhere.
///
/// Used automatically by [ApiWidget] when no custom [httpClient] is provided.
class DefaultBduiHttpClient implements BduiHttpClient {
  /// Creates a [DefaultBduiHttpClient].
  const DefaultBduiHttpClient();

  @override
  Future<ApiResponse> get(
    String url, {
    Map<String, String>? headers,
    Duration? cacheDuration,
    int? maxRetries,
    Duration? timeout,
  }) =>
      ApiClient.get(
        url,
        headers: headers,
        cacheDuration: cacheDuration,
        maxRetries: maxRetries ?? BduiConfig.defaultMaxRetries,
        timeout: timeout ?? BduiConfig.defaultTimeout,
      );

  @override
  Future<ApiResponse> getWithRefresh(
    String url, {
    Map<String, String>? headers,
    Duration? cacheDuration,
    int? maxRetries,
    Duration? timeout,
    void Function(ApiResponse freshResponse)? onRefresh,
  }) =>
      ApiClient.getWithRefresh(
        url,
        headers: headers,
        cacheDuration: cacheDuration,
        maxRetries: maxRetries ?? BduiConfig.defaultMaxRetries,
        timeout: timeout ?? BduiConfig.defaultTimeout,
        onRefresh: onRefresh,
      );

  @override
  Future<ApiResponse> post(
    String url, {
    Map<String, String>? headers,
    dynamic body,
    int? maxRetries,
    Duration? timeout,
  }) =>
      ApiClient.post(
        url,
        headers: headers,
        body: body,
        maxRetries: maxRetries ?? BduiConfig.defaultMaxRetries,
        timeout: timeout ?? BduiConfig.defaultTimeout,
      );

  @override
  Future<ApiResponse> put(
    String url, {
    Map<String, String>? headers,
    dynamic body,
    int? maxRetries,
    Duration? timeout,
  }) =>
      ApiClient.put(
        url,
        headers: headers,
        body: body,
        maxRetries: maxRetries ?? BduiConfig.defaultMaxRetries,
        timeout: timeout ?? BduiConfig.defaultTimeout,
      );

  @override
  Future<ApiResponse> patch(
    String url, {
    Map<String, String>? headers,
    dynamic body,
    int? maxRetries,
    Duration? timeout,
  }) =>
      ApiClient.patch(
        url,
        headers: headers,
        body: body,
        maxRetries: maxRetries ?? BduiConfig.defaultMaxRetries,
        timeout: timeout ?? BduiConfig.defaultTimeout,
      );

  @override
  Future<ApiResponse> delete(
    String url, {
    Map<String, String>? headers,
    int? maxRetries,
    Duration? timeout,
  }) =>
      ApiClient.delete(
        url,
        headers: headers,
        maxRetries: maxRetries ?? BduiConfig.defaultMaxRetries,
        timeout: timeout ?? BduiConfig.defaultTimeout,
      );

  @override
  Future<ApiResponse> execute(ApiRequest request) {
    switch (request.method) {
      case HttpMethod.get:
        return get(
          request.endpoint,
          headers: request.headers,
          cacheDuration: request.cacheDuration,
          maxRetries: request.maxRetries,
          timeout: request.timeout,
        );
      case HttpMethod.post:
        return post(
          request.endpoint,
          headers: request.headers,
          body: request.body,
          maxRetries: request.maxRetries,
          timeout: request.timeout,
        );
      case HttpMethod.put:
        return put(
          request.endpoint,
          headers: request.headers,
          body: request.body,
          maxRetries: request.maxRetries,
          timeout: request.timeout,
        );
      case HttpMethod.patch:
        return patch(
          request.endpoint,
          headers: request.headers,
          body: request.body,
          maxRetries: request.maxRetries,
          timeout: request.timeout,
        );
      case HttpMethod.delete:
        return delete(
          request.endpoint,
          headers: request.headers,
          maxRetries: request.maxRetries,
          timeout: request.timeout,
        );
    }
  }
}
