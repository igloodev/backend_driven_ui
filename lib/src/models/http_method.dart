/// HTTP methods supported by [ApiWidget] and [BackendDrivenScreen].
enum HttpMethod {
  get,
  post,
  put,
  delete,
  patch;

  /// Uppercase string representation — e.g. `'GET'`, `'POST'`.
  String get value => name.toUpperCase();
}
