import 'package:flutter_test/flutter_test.dart';
import 'package:backend_driven_ui/backend_driven_ui.dart';

void main() {
  group('HttpMethod enum', () {
    test('has all 7 methods', () {
      expect(HttpMethod.values.length, 7);
    });

    test('GET value', () => expect(HttpMethod.get.value, 'GET'));
    test('POST value', () => expect(HttpMethod.post.value, 'POST'));
    test('PUT value', () => expect(HttpMethod.put.value, 'PUT'));
    test('PATCH value', () => expect(HttpMethod.patch.value, 'PATCH'));
    test('DELETE value', () => expect(HttpMethod.delete.value, 'DELETE'));
    test('HEAD value', () => expect(HttpMethod.head.value, 'HEAD'));
    test('OPTIONS value', () => expect(HttpMethod.options.value, 'OPTIONS'));

    test('head is in values', () {
      expect(HttpMethod.values, contains(HttpMethod.head));
    });

    test('options is in values', () {
      expect(HttpMethod.values, contains(HttpMethod.options));
    });
  });
}
