import 'package:flutter/foundation.dart' show debugPrint;

import '../core/bdui_config.dart';

/// Centralized logger for backend_driven_ui package
class BduiLogger {
  /// Package prefix for all log messages
  static const String _prefix = '[BDUI]';

  /// Log a debug message
  static void debug(String message) {
    if (!BduiConfig.enableLogging) return;
    debugPrint('$_prefix $message');
  }

  /// Log a warning message
  static void warn(String message) {
    if (!BduiConfig.enableLogging) return;
    debugPrint('$_prefix ⚠️ $message');
  }

  /// Log an error message
  static void error(String message) {
    if (!BduiConfig.enableLogging) return;
    debugPrint('$_prefix ❌ $message');
  }

  /// Log a success message
  static void success(String message) {
    if (!BduiConfig.enableLogging) return;
    debugPrint('$_prefix ✅ $message');
  }

  /// Log an info message
  static void info(String message) {
    if (!BduiConfig.enableLogging) return;
    debugPrint('$_prefix ℹ️ $message');
  }

  /// Log a network-related message
  static void network(String message) {
    if (!BduiConfig.enableLogging) return;
    debugPrint('$_prefix 🌐 $message');
  }

  /// Log a cache-related message
  static void cache(String message) {
    if (!BduiConfig.enableLogging) return;
    debugPrint('$_prefix 💾 $message');
  }
}
