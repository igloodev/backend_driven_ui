import 'package:flutter_test/flutter_test.dart';
import 'package:backend_driven_ui/src/models/api_request.dart';
import 'package:backend_driven_ui/src/models/http_method.dart';

void main() {
  group('ApiRequest', () {
    test('default values', () {
      const req = ApiRequest(endpoint: '/api/items');
      expect(req.endpoint, '/api/items');
      expect(req.method, HttpMethod.get);
      expect(req.headers, isNull);
      expect(req.body, isNull);
      expect(req.cacheDuration, isNull);
      expect(req.maxRetries, isNull);
      expect(req.timeout, isNull);
    });

    test('all fields set correctly', () {
      final req = const ApiRequest(
        endpoint: '/api/orders',
        method: HttpMethod.post,
        headers: {'Authorization': 'Bearer token'},
        body: {'item': 1},
        cacheDuration: Duration(minutes: 5),
        maxRetries: 2,
        timeout: Duration(seconds: 10),
      );
      expect(req.endpoint, '/api/orders');
      expect(req.method, HttpMethod.post);
      expect(req.headers, {'Authorization': 'Bearer token'});
      expect(req.body, {'item': 1});
      expect(req.cacheDuration, const Duration(minutes: 5));
      expect(req.maxRetries, 2);
      expect(req.timeout, const Duration(seconds: 10));
    });

    group('copyWith', () {
      const base = ApiRequest(
        endpoint: '/api/products',
        method: HttpMethod.get,
        maxRetries: 3,
      );

      test('returns identical copy when no args given', () {
        final copy = base.copyWith();
        expect(copy.endpoint, base.endpoint);
        expect(copy.method, base.method);
        expect(copy.maxRetries, base.maxRetries);
      });

      test('overrides only the specified field', () {
        final copy = base.copyWith(endpoint: '/api/items');
        expect(copy.endpoint, '/api/items');
        expect(copy.method, HttpMethod.get);
        expect(copy.maxRetries, 3);
      });

      test('can change method', () {
        final copy = base.copyWith(method: HttpMethod.post);
        expect(copy.method, HttpMethod.post);
        expect(copy.endpoint, base.endpoint);
      });

      test('can add headers', () {
        final copy = base.copyWith(headers: {'X-Custom': 'value'});
        expect(copy.headers, {'X-Custom': 'value'});
        expect(copy.endpoint, base.endpoint);
      });

      test('can set cacheDuration', () {
        final copy = base.copyWith(cacheDuration: const Duration(minutes: 10));
        expect(copy.cacheDuration, const Duration(minutes: 10));
      });

      test('can set timeout', () {
        final copy = base.copyWith(timeout: const Duration(seconds: 15));
        expect(copy.timeout, const Duration(seconds: 15));
      });

      test('can clear body by passing null explicitly', () {
        final withBody = const ApiRequest(endpoint: '/api/items', body: {'key': 'value'});
        final cleared = withBody.copyWith(body: null);
        expect(cleared.body, isNull);
        expect(cleared.endpoint, '/api/items');
      });

      test('preserves body when not specified in copyWith', () {
        final withBody = const ApiRequest(endpoint: '/api/items', body: {'key': 'value'});
        final copy = withBody.copyWith(endpoint: '/api/other');
        expect(copy.body, {'key': 'value'});
      });
    });

    group('toString', () {
      test('includes method and endpoint', () {
        const req = ApiRequest(endpoint: '/api/users', method: HttpMethod.post);
        expect(req.toString(), 'ApiRequest(POST /api/users)');
      });

      test('default GET method shown', () {
        const req = ApiRequest(endpoint: '/api/items');
        expect(req.toString(), 'ApiRequest(GET /api/items)');
      });
    });
  });

  group('HttpMethod', () {
    test('value returns uppercase string', () {
      expect(HttpMethod.get.value, 'GET');
      expect(HttpMethod.post.value, 'POST');
      expect(HttpMethod.put.value, 'PUT');
      expect(HttpMethod.delete.value, 'DELETE');
      expect(HttpMethod.patch.value, 'PATCH');
    });
  });
}
