import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:backend_driven_ui/src/core/api_client.dart';
import 'package:backend_driven_ui/src/core/bdui_config.dart';
import 'package:backend_driven_ui/src/models/api_exception.dart';

void main() {
  tearDown(() {
    ApiClient.reset();
    BduiConfig.reset();
  });

  group('ApiClient invalid JSON handling', () {
    test('throws ApiException with "Invalid JSON response" on malformed body',
        () async {
      ApiClient.setHttpClientForTesting(
          MockClient((_) async => http.Response('not valid json {{{', 200)));

      await expectLater(
        ApiClient.get('https://api.example.com/data', maxRetries: 0),
        throwsA(
          isA<ApiException>().having(
            (e) => e.message,
            'message',
            contains('Invalid JSON response'),
          ),
        ),
      );
    });

    test('throws ApiException preserving the HTTP status code', () async {
      ApiClient.setHttpClientForTesting(
          MockClient((_) async => http.Response('<html>Not JSON</html>', 200)));

      await expectLater(
        ApiClient.get('https://api.example.com/data', maxRetries: 0),
        throwsA(
          isA<ApiException>().having((e) => e.statusCode, 'statusCode', 200),
        ),
      );
    });

    test('valid JSON does not throw', () async {
      ApiClient.setHttpClientForTesting(
          MockClient((_) async => http.Response('{"name":"test"}', 200)));

      final response = await ApiClient.get(
        'https://api.example.com/data',
        maxRetries: 0,
      );
      expect(response.isSuccess, isTrue);
      expect(response.data, isA<Map>());
    });

    test('empty body returns null data without throwing', () async {
      ApiClient.setHttpClientForTesting(
          MockClient((_) async => http.Response('', 200)));

      final response = await ApiClient.get(
        'https://api.example.com/data',
        maxRetries: 0,
      );
      expect(response.isSuccess, isTrue);
      expect(response.data, isNull);
    });

    test('4xx response throws ApiException with status code', () async {
      ApiClient.setHttpClientForTesting(MockClient(
          (_) async => http.Response('{"message":"Not Found"}', 404)));

      await expectLater(
        ApiClient.get('https://api.example.com/data', maxRetries: 0),
        throwsA(
          isA<ApiException>().having((e) => e.statusCode, 'statusCode', 404),
        ),
      );
    });

    test('5xx response throws ApiException with status code', () async {
      ApiClient.setHttpClientForTesting(MockClient(
          (_) async => http.Response('{"error":"Server Error"}', 500)));

      await expectLater(
        ApiClient.get('https://api.example.com/data', maxRetries: 0),
        throwsA(
          isA<ApiException>().having((e) => e.statusCode, 'statusCode', 500),
        ),
      );
    });
  });
}
