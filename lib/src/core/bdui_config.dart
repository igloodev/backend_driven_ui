/// Centralized configuration for Backend-Driven UI package
///
/// All configurable limits and settings in one place for easy tuning.
///
/// Example:
/// ```dart
/// // Configure at app startup
/// BduiConfig.maxWidgetDepth = 100;
/// BduiConfig.enableLogging = false; // Disable in production
/// ```
class BduiConfig {
  BduiConfig._();

  // ============ Widget Parsing Limits ============

  /// Maximum widget nesting depth to prevent stack overflow.
  /// Default: 50
  static int maxWidgetDepth = 50;

  /// Maximum children count per widget to prevent memory exhaustion.
  /// Default: 500
  static int maxChildren = 500;

  /// Maximum action nesting depth to prevent infinite recursion.
  /// Default: 10
  static int maxActionDepth = 10;

  // ============ Network Settings ============

  /// Global base URL prepended to all relative endpoint paths.
  ///
  /// Set once at app startup to avoid repeating the full URL on every widget:
  /// ```dart
  /// BduiConfig.baseUrl = 'https://api.myapp.com';
  ///
  /// // Then use relative paths everywhere:
  /// ApiWidget(endpoint: '/products')
  /// BackendDrivenScreen(endpoint: '/screens/home')
  /// ```
  ///
  /// Endpoints that already start with `http://` or `https://` are used as-is.
  /// Default: '' (empty — full URLs required)
  static String baseUrl = '';

  /// Maximum cache entries for API responses.
  /// Default: 100
  static int maxCacheEntries = 100;

  /// Default cache duration for API responses.
  /// Default: 5 minutes
  static Duration defaultCacheDuration = const Duration(minutes: 5);

  /// Default request timeout.
  /// Default: 30 seconds
  static Duration defaultTimeout = const Duration(seconds: 30);

  /// Default max retries for failed requests.
  /// Default: 3
  static int defaultMaxRetries = 3;

  /// Maximum allowed retries (hard limit).
  /// Default: 10
  static int maxAllowedRetries = 10;

  /// Maximum total duration for all retry attempts.
  /// Default: 2 minutes
  static Duration maxRetryDuration = const Duration(minutes: 2);

  // ============ Logging Settings ============

  /// Whether to enable debug logging.
  /// Set to false in production for better performance.
  /// Default: true (enabled in debug mode)
  static bool enableLogging = true;

  // ============ Security Settings ============

  /// Whether to validate URLs for SSRF protection.
  /// Default: true
  static bool enableUrlValidation = true;

  /// Allowed URL schemes for security validation.
  /// Default: ['http', 'https']
  static List<String> allowedUrlSchemes = ['http', 'https'];

  // ============ Reset ============

  /// Reset all config values to defaults
  static void reset() {
    maxWidgetDepth = 50;
    maxChildren = 500;
    maxActionDepth = 10;
    baseUrl = '';
    maxCacheEntries = 100;
    defaultCacheDuration = const Duration(minutes: 5);
    defaultTimeout = const Duration(seconds: 30);
    defaultMaxRetries = 3;
    maxAllowedRetries = 10;
    maxRetryDuration = const Duration(minutes: 2);
    enableLogging = true;
    enableUrlValidation = true;
    allowedUrlSchemes = ['http', 'https'];
  }
}
