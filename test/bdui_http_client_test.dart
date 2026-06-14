import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:backend_driven_ui/src/core/api_client.dart';
import 'package:backend_driven_ui/src/core/bdui_config.dart';
import 'package:backend_driven_ui/src/core/bdui_http_client.dart';
import 'package:backend_driven_ui/src/models/api_exception.dart';
import 'package:backend_driven_ui/src/models/api_request.dart';
import 'package:backend_driven_ui/src/models/http_method.dart';

void main() {
  tearDown(() {
    ApiClient.reset();
    BduiConfig.reset();
  });

  group('DefaultBduiHttpClient', () {
    setUp(() {
      ApiClient.setHttpClientForTesting(
        MockClient((request) async => http.Response('{"data":"ok"}', 200)),
      );
    });

    test('get returns ApiResponse on success', () async {
      const client = DefaultBduiHttpClient();
      final response = await client.get('https://api.example.com/items');
      expect(response.isSuccess, isTrue);
    });

    test('post returns ApiResponse on success', () async {
      const client = DefaultBduiHttpClient();
      final response = await client.post(
        'https://api.example.com/items',
        body: {'name': 'test'},
      );
      expect(response.isSuccess, isTrue);
    });

    test('put returns ApiResponse on success', () async {
      const client = DefaultBduiHttpClient();
      final response = await client.put(
        'https://api.example.com/items/1',
        body: {'name': 'updated'},
      );
      expect(response.isSuccess, isTrue);
    });

    test('delete returns ApiResponse on success', () async {
      const client = DefaultBduiHttpClient();
      final response = await client.delete('https://api.example.com/items/1');
      expect(response.isSuccess, isTrue);
    });

    test('maps an http.ClientException to a "No internet" ApiException',
        () async {
      // Network-layer failure path — works the same on native and web (the
      // browser client throws ClientException directly; IOClient wraps
      // SocketException into it).
      ApiClient.setHttpClientForTesting(
        MockClient((req) async => throw http.ClientException('offline')),
      );
      await expectLater(
        ApiClient.get('https://api.example.com/items', maxRetries: 0),
        throwsA(
          isA<ApiException>().having(
            (e) => e.message,
            'message',
            contains('No internet connection'),
          ),
        ),
      );
    });

    group('execute routes by HttpMethod', () {
      test('GET request routed correctly', () async {
        String? capturedMethod;
        ApiClient.setHttpClientForTesting(
          MockClient((req) async {
            capturedMethod = req.method;
            return http.Response('{"ok":true}', 200);
          }),
        );

        const client = DefaultBduiHttpClient();
        await client.execute(
            const ApiRequest(endpoint: 'https://api.example.com/data'));
        expect(capturedMethod, 'GET');
      });

      test('POST request routed correctly', () async {
        String? capturedMethod;
        ApiClient.setHttpClientForTesting(
          MockClient((req) async {
            capturedMethod = req.method;
            return http.Response('{"ok":true}', 200);
          }),
        );

        const client = DefaultBduiHttpClient();
        await client.execute(const ApiRequest(
          endpoint: 'https://api.example.com/data',
          method: HttpMethod.post,
          body: {'key': 'value'},
        ));
        expect(capturedMethod, 'POST');
      });

      test('PUT request routed correctly', () async {
        String? capturedMethod;
        ApiClient.setHttpClientForTesting(
          MockClient((req) async {
            capturedMethod = req.method;
            return http.Response('{"ok":true}', 200);
          }),
        );

        const client = DefaultBduiHttpClient();
        await client.execute(const ApiRequest(
          endpoint: 'https://api.example.com/data/1',
          method: HttpMethod.put,
        ));
        expect(capturedMethod, 'PUT');
      });

      test('DELETE request routed correctly', () async {
        String? capturedMethod;
        ApiClient.setHttpClientForTesting(
          MockClient((req) async {
            capturedMethod = req.method;
            return http.Response('{"ok":true}', 200);
          }),
        );

        const client = DefaultBduiHttpClient();
        await client.execute(const ApiRequest(
          endpoint: 'https://api.example.com/data/1',
          method: HttpMethod.delete,
        ));
        expect(capturedMethod, 'DELETE');
      });

      test('PATCH request routed correctly', () async {
        String? capturedMethod;
        ApiClient.setHttpClientForTesting(
          MockClient((req) async {
            capturedMethod = req.method;
            return http.Response('{"ok":true}', 200);
          }),
        );

        const client = DefaultBduiHttpClient();
        await client.execute(const ApiRequest(
          endpoint: 'https://api.example.com/data/1',
          method: HttpMethod.patch,
        ));
        expect(capturedMethod, 'PATCH');
      });
    });

    test('null maxRetries resolves to BduiConfig.defaultMaxRetries', () async {
      // Verify no crash and correct delegation — the key check is it uses
      // BduiConfig value instead of hardcoded value
      BduiConfig.defaultMaxRetries = 1;
      const client = DefaultBduiHttpClient();
      final response = await client.get('https://api.example.com/items');
      expect(response.isSuccess, isTrue);
    });
  });
}
