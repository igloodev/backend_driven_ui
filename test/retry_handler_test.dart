import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:backend_driven_ui/src/core/retry_handler.dart';
import 'package:backend_driven_ui/src/models/api_exception.dart';

void main() {
  group('RetryHandler.defaultShouldRetry', () {
    group('ApiException with status code', () {
      test('4xx client error returns false', () {
        expect(
          RetryHandler.defaultShouldRetry(
              const ApiException(message: 'Not Found', statusCode: 404)),
          isFalse,
        );
      });

      test('400 returns false', () {
        expect(
          RetryHandler.defaultShouldRetry(
              const ApiException(message: 'Bad Request', statusCode: 400)),
          isFalse,
        );
      });

      test('499 returns false', () {
        expect(
          RetryHandler.defaultShouldRetry(
              const ApiException(message: 'Client Error', statusCode: 499)),
          isFalse,
        );
      });

      test('500 server error returns true', () {
        expect(
          RetryHandler.defaultShouldRetry(
              const ApiException(message: 'Internal Server Error', statusCode: 500)),
          isTrue,
        );
      });

      test('503 returns true', () {
        expect(
          RetryHandler.defaultShouldRetry(
              const ApiException(message: 'Service Unavailable', statusCode: 503)),
          isTrue,
        );
      });
    });

    group('ApiException without status code (network/timeout)', () {
      test('timeout message returns true', () {
        expect(
          RetryHandler.defaultShouldRetry(
              const ApiException(message: 'Request timeout. Please check your internet connection.')),
          isTrue,
        );
      });

      test('no internet message returns true (isNetworkError)', () {
        expect(
          RetryHandler.defaultShouldRetry(
              const ApiException(message: 'No internet connection.')),
          isTrue,
        );
      });

      test('generic no-code exception returns true (isNetworkError)', () {
        expect(
          RetryHandler.defaultShouldRetry(
              const ApiException(message: 'Something went wrong')),
          isTrue,
        );
      });
    });

    group('Low-level exceptions', () {
      test('SocketException returns true', () {
        expect(
          RetryHandler.defaultShouldRetry(
              const SocketException('Connection refused')),
          isTrue,
        );
      });

      test('generic Exception with timeout in message returns true', () {
        expect(
          RetryHandler.defaultShouldRetry(Exception('timeout exceeded')),
          isTrue,
        );
      });

      test('generic Exception with connection in message returns true', () {
        expect(
          RetryHandler.defaultShouldRetry(Exception('connection reset by peer')),
          isTrue,
        );
      });

      test('unrelated Exception returns false', () {
        expect(
          RetryHandler.defaultShouldRetry(Exception('something unexpected')),
          isFalse,
        );
      });
    });

    test('non-Exception error returns false', () {
      expect(RetryHandler.defaultShouldRetry('some string error'), isFalse);
      expect(RetryHandler.defaultShouldRetry(42), isFalse);
      expect(RetryHandler.defaultShouldRetry(null), isFalse);
    });
  });

  group('RetryHandler.retry', () {
    test('returns result immediately on success', () async {
      final result = await RetryHandler.retry(action: () async => 'ok');
      expect(result, 'ok');
    });

    test('retries and succeeds on second attempt', () async {
      int attempts = 0;
      final result = await RetryHandler.retry(
        action: () async {
          attempts++;
          if (attempts < 2) throw const SocketException('fail');
          return 'success';
        },
        maxRetries: 3,
        initialDelay: Duration.zero,
      );
      expect(result, 'success');
      expect(attempts, 2);
    });

    test('does not retry 4xx ApiException', () async {
      int attempts = 0;
      expect(
        () => RetryHandler.retry(
          action: () async {
            attempts++;
            throw const ApiException(message: 'Not Found', statusCode: 404);
          },
          maxRetries: 3,
          initialDelay: Duration.zero,
        ),
        throwsA(isA<ApiException>()),
      );
      await Future.delayed(Duration.zero);
      expect(attempts, 1);
    });

    test('exhausts retries and rethrows', () async {
      int attempts = 0;
      await expectLater(
        RetryHandler.retry(
          action: () async {
            attempts++;
            throw const ApiException(message: 'Server Error', statusCode: 500);
          },
          maxRetries: 3,
          initialDelay: Duration.zero,
        ),
        throwsA(isA<ApiException>()),
      );
      expect(attempts, 3);
    });
  });
}
