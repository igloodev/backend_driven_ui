import 'package:flutter/widgets.dart';

import '../utils/logger.dart';

/// In-memory API cache with LRU eviction and memory pressure handling
class ApiCache with WidgetsBindingObserver {
  final Map<String, CacheEntry> _cache = {};
  final int _maxEntries;
  bool _isObserving = false;

  /// Creates an API cache
  ApiCache({int maxEntries = 100}) : _maxEntries = maxEntries {
    _startObserving();
  }

  /// Start observing memory pressure events
  void _startObserving() {
    if (_isObserving) return;

    try {
      // Check if binding is initialized
      final binding = WidgetsBinding.instance;
      binding.addObserver(this);
      // Only set flag AFTER successful registration
      _isObserving = true;
    } catch (e) {
      // WidgetsBinding not initialized yet
      // Will retry on first cache access
      _isObserving = false;
    }
  }

  @override
  void didHaveMemoryPressure() {
    BduiLogger.cache('Memory pressure detected - clearing cache');
    clear();
  }

  /// Dispose the cache and stop observing
  void dispose() {
    if (_isObserving) {
      try {
        WidgetsBinding.instance.removeObserver(this);
      } catch (e) {
        // Ignore if binding not available
      }
      _isObserving = false;
    }
    clear();
  }

  /// Get cached data
  ///
  /// Returns null if key doesn't exist, is expired, or data type doesn't match.
  T? get<T>(String key) {
    // Ensure we're observing (retry if binding wasn't ready at construction)
    if (!_isObserving) {
      _startObserving();
    }

    final entry = _cache[key];

    if (entry == null || entry.isExpired) {
      if (entry != null) {
        _cache.remove(key);
      }
      return null;
    }

    // Type-safe cast
    final data = entry.data;
    if (data is! T) {
      BduiLogger.warn(
          'Cache type mismatch for key "$key": expected $T, got ${data.runtimeType}');
      return null;
    }

    // Move to end (LRU)
    _cache.remove(key);
    _cache[key] = entry;

    return data;
  }

  /// Set cached data
  void set<T>(
    String key,
    T data, {
    Duration duration = const Duration(minutes: 5),
  }) {
    // LRU eviction - check both length AND non-empty
    if (_cache.isNotEmpty && _cache.length >= _maxEntries) {
      final oldestKey = _cache.keys.first;
      _cache.remove(oldestKey);
    }

    _cache[key] = CacheEntry(
      data: data,
      expiresAt: DateTime.now().add(duration),
    );
  }

  /// Check if key exists and is valid
  bool has(String key) {
    final entry = _cache[key];
    return entry != null && !entry.isExpired;
  }

  /// Remove specific key
  void remove(String key) {
    _cache.remove(key);
  }

  /// Clear all cache
  void clear() {
    _cache.clear();
  }

  /// Get cache size
  int get size => _cache.length;

  /// Remove expired entries
  void cleanup() {
    _cache.removeWhere((key, value) => value.isExpired);
  }

  /// Reduce cache size by half
  void reduceSize() {
    if (_cache.isEmpty) return;

    final targetSize = _cache.length ~/ 2;
    final keysToRemove =
        _cache.keys.take(_cache.length - targetSize).toList();
    for (final key in keysToRemove) {
      _cache.remove(key);
    }
    BduiLogger.cache('Reduced cache size to ${_cache.length} entries');
  }
}

/// Cache entry with expiration
class CacheEntry {
  final dynamic data;
  final DateTime expiresAt;

  const CacheEntry({
    required this.data,
    required this.expiresAt,
  });

  bool get isExpired => DateTime.now().isAfter(expiresAt);

  Duration get timeUntilExpiry => expiresAt.difference(DateTime.now());
}
