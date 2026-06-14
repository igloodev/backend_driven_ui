import '../models/api_exception.dart';
import '../utils/bdui_logger.dart';
import 'bdui_config.dart';

/// Retry handler with exponential backoff and safety limits
class RetryHandler {
  /// Retry an action with exponential backoff
  ///
  /// Safety features:
  /// - [maxRetries] is capped at [BduiConfig.maxAllowedRetries]
  /// - Total retry duration is capped at [BduiConfig.maxRetryDuration]
  /// - Unknown errors are NOT retried by default
  static Future<T> retry<T>({
    required Future<T> Function() action,
    int maxRetries = 3,
    Duration initialDelay = const Duration(seconds: 1),
    double backoffMultiplier = 2.0,
    Duration? maxDuration,
    bool Function(dynamic error)? shouldRetry,
  }) async {
    // Cap maxRetries to prevent abuse (uses BduiConfig for configurable limit)
    final effectiveMaxRetries =
        maxRetries.clamp(0, BduiConfig.maxAllowedRetries);
    final effectiveMaxDuration = maxDuration ?? BduiConfig.maxRetryDuration;
    final startTime = DateTime.now();

    int attempt = 0;
    Duration delay = initialDelay;

    while (true) {
      try {
        return await action();
      } catch (e) {
        attempt++;

        // Check total duration limit
        final elapsed = DateTime.now().difference(startTime);
        if (elapsed >= effectiveMaxDuration) {
          BduiLogger.warn(
              'Retry timeout: exceeded max duration of ${effectiveMaxDuration.inSeconds}s');
          rethrow;
        }

        // Check if should retry
        final retriable = shouldRetry?.call(e) ?? defaultShouldRetry(e);
        final canRetry = attempt < effectiveMaxRetries && retriable;

        if (!canRetry) {
          if (attempt >= effectiveMaxRetries) {
            BduiLogger.warn('Retry exhausted: $attempt attempts failed');
          }
          rethrow;
        }

        BduiLogger.debug(
            'Retry attempt $attempt/$effectiveMaxRetries after ${delay.inMilliseconds}ms');

        // Wait with exponential backoff
        await Future.delayed(delay);
        delay = Duration(
          milliseconds: (delay.inMilliseconds * backoffMultiplier).round(),
        );

        // Cap delay to prevent excessive waits
        if (delay.inSeconds > 30) {
          delay = const Duration(seconds: 30);
        }
      }
    }
  }

  /// Default retry predicate for API calls.
  ///
  /// Conservative approach: only retry known-retriable errors.
  /// Unknown errors are NOT retried to prevent infinite loops.
  ///
  /// Decision order:
  /// 1. [ApiException] with a status code → use the code directly (no string parsing).
  /// 2. Network / timeout exceptions (SocketException, TimeoutException) → retry.
  /// 3. Everything else → don't retry.
  static bool defaultShouldRetry(dynamic error) {
    // Use the structured status code when available — avoids false matches
    // from status-code digits appearing in URLs or error messages.
    if (error is ApiException) {
      final code = error.statusCode;
      if (code != null) {
        if (code >= 400 && code < 500) {
          return false; // client error — don't retry
        }
        if (code >= 500) return true; // server error — retry
        return false;
      }
      // No status code → network/timeout error from ApiException message
      return error.isNetworkError || error.isTimeout;
    }

    // Retry on low-level network / timeout errors
    if (error is Exception) {
      final errorStr = error.toString().toLowerCase();
      return errorStr.contains('timeout') ||
          errorStr.contains('socket') ||
          errorStr.contains('connection') ||
          errorStr.contains('network');
    }

    // Don't retry unknown errors (conservative approach)
    return false;
  }
}
