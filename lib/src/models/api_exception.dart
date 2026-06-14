/// API Exception
class ApiException implements Exception {
  /// Error message
  final String message;

  /// HTTP status code (if available)
  final int? statusCode;

  /// Original error
  final dynamic originalError;

  /// Creates an API exception
  const ApiException({
    required this.message,
    this.statusCode,
    this.originalError,
  });

  /// Whether this is a network error
  bool get isNetworkError => statusCode == null;

  /// Whether this is a timeout error
  bool get isTimeout => message.contains('timeout');

  /// Whether this is a server error (5xx)
  bool get isServerError => statusCode != null && statusCode! >= 500;

  /// Whether this is a client error (4xx)
  bool get isClientError =>
      statusCode != null && statusCode! >= 400 && statusCode! < 500;

  @override
  String toString() =>
      'ApiException: $message${statusCode != null ? ' ($statusCode)' : ''}';
}
