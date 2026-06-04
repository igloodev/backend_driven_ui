/// HTTP methods supported by [ApiWidget] and [BackendDrivenScreen].
enum HttpMethod {
  get,
  post,
  put,
  delete,
  patch,
  head,
  options;

  /// Uppercase string representation — e.g. `'GET'`, `'POST'`, `'HEAD'`.
  String get value => name.toUpperCase();
}
