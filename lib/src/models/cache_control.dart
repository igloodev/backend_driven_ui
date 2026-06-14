import '../utils/bdui_logger.dart';

/// Cache policy from backend response
enum CachePolicy {
  /// Use cached data if available, otherwise fetch fresh
  cache,

  /// Always fetch fresh data, never use cache
  noCache,

  /// Use cache but refresh in background (stale-while-revalidate)
  refresh,
}

/// Cache control settings from API response
class CacheControl {
  /// Cache policy
  final CachePolicy policy;

  /// Time-to-live in seconds (null = use client default)
  final int? ttlSeconds;

  /// Creates cache control settings
  const CacheControl({
    this.policy = CachePolicy.cache,
    this.ttlSeconds,
  });

  /// Default cache control (cache with 5 min TTL)
  static const defaultControl = CacheControl(
    policy: CachePolicy.cache,
    ttlSeconds: 300,
  );

  /// No cache control
  static const noCache = CacheControl(
    policy: CachePolicy.noCache,
  );

  /// Parse cache control from API response JSON
  ///
  /// Expected format:
  /// ```json
  /// {
  ///   "cachePolicy": "cache",  // "cache" | "noCache" | "refresh"
  ///   "cacheTTL": 300,         // seconds (optional)
  ///   "ui": { ... }            // actual UI data
  /// }
  /// ```
  factory CacheControl.fromJson(Map<String, dynamic> json) {
    CachePolicy policy = CachePolicy.cache;

    final policyStr = json['cachePolicy'] as String?;
    if (policyStr != null) {
      switch (policyStr.toLowerCase()) {
        case 'nocache':
        case 'no-cache':
        case 'no_cache':
          policy = CachePolicy.noCache;
          break;
        case 'refresh':
        case 'stale-while-revalidate':
          policy = CachePolicy.refresh;
          break;
        case 'cache':
          policy = CachePolicy.cache;
          break;
        default:
          BduiLogger.warn(
            'CacheControl: unknown cachePolicy "$policyStr", defaulting to noCache',
          );
          policy = CachePolicy.noCache;
      }
    }

    return CacheControl(
      policy: policy,
      ttlSeconds: json['cacheTTL'] as int?,
    );
  }

  /// Whether caching is enabled
  bool get isCacheEnabled => policy != CachePolicy.noCache;

  /// Get TTL as Duration
  Duration? get ttl =>
      ttlSeconds != null ? Duration(seconds: ttlSeconds!) : null;

  /// Whether to refresh in background
  bool get shouldRefreshInBackground => policy == CachePolicy.refresh;

  @override
  String toString() => 'CacheControl(policy: $policy, ttl: ${ttlSeconds}s)';
}
