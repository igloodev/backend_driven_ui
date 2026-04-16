/// Callback for custom action handling.
typedef CustomActionCallback = Future<void> Function(
  String name,
  Map<String, dynamic>? params,
);

/// Callback for navigation — allows the app to override default [Navigator] behaviour.
typedef NavigationCallback = Future<void> Function(
  String route,
  Map<String, dynamic>? arguments,
);

/// Callback for URL launching — wire in `url_launcher` or any custom handler.
///
/// Example:
/// ```dart
/// onLaunchUrl: (url) async {
///   if (await canLaunchUrl(Uri.parse(url))) {
///     await launchUrl(Uri.parse(url));
///   }
/// }
/// ```
typedef LaunchUrlCallback = Future<void> Function(String url);

/// Callback invoked after a successful `api` action.
typedef ApiCallback = void Function(String endpoint, dynamic data);

/// Callback invoked when an `api` action fails.
typedef ApiErrorCallback = void Function(String endpoint, String error);
