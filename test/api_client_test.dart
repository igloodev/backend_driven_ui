import 'package:flutter_test/flutter_test.dart';
import 'package:backend_driven_ui/src/core/api_client.dart';
import 'package:backend_driven_ui/src/core/bdui_config.dart';

void main() {
  group('ApiClient.resolveUrl', () {
    tearDown(BduiConfig.reset);

    test('full URL returned unchanged when baseUrl is empty', () {
      BduiConfig.baseUrl = '';
      expect(
        ApiClient.resolveUrl('https://api.example.com/products'),
        'https://api.example.com/products',
      );
    });

    test('full https URL returned unchanged even with baseUrl set', () {
      BduiConfig.baseUrl = 'https://other.api.com';
      expect(
        ApiClient.resolveUrl('https://api.example.com/products'),
        'https://api.example.com/products',
      );
    });

    test('full http URL returned unchanged', () {
      BduiConfig.baseUrl = 'https://api.example.com';
      expect(
        ApiClient.resolveUrl('http://localhost/test'),
        'http://localhost/test',
      );
    });

    test('relative path prepended with baseUrl (trailing slash on base)', () {
      BduiConfig.baseUrl = 'https://api.example.com/';
      expect(
        ApiClient.resolveUrl('/products'),
        'https://api.example.com/products',
      );
    });

    test('relative path prepended with baseUrl (no trailing slash on base)',
        () {
      BduiConfig.baseUrl = 'https://api.example.com';
      expect(
        ApiClient.resolveUrl('/products'),
        'https://api.example.com/products',
      );
    });

    test('relative path without leading slash gets slash added', () {
      BduiConfig.baseUrl = 'https://api.example.com';
      expect(
        ApiClient.resolveUrl('products'),
        'https://api.example.com/products',
      );
    });

    test('empty baseUrl returns relative path as-is', () {
      BduiConfig.baseUrl = '';
      expect(ApiClient.resolveUrl('/products'), '/products');
    });
  });

  group('ApiClient URL validation', () {
    test('isUrlSafe accepts valid HTTPS URL', () {
      expect(ApiClient.isUrlSafe('https://api.example.com/data'), isTrue);
    });

    test('isUrlSafe rejects localhost', () {
      expect(ApiClient.isUrlSafe('http://localhost/admin'), isFalse);
    });

    test('isUrlSafe rejects private IP', () {
      expect(ApiClient.isUrlSafe('http://192.168.1.1/data'), isFalse);
    });

    test('isUrlSafe rejects file:// scheme', () {
      expect(ApiClient.isUrlSafe('file:///etc/passwd'), isFalse);
    });

    test('isUrlSafe rejects AWS metadata endpoint', () {
      expect(
        ApiClient.isUrlSafe('http://169.254.169.254/latest/meta-data/'),
        isFalse,
      );
    });

    // These exercise the native (dart:io InternetAddress) IP-literal path,
    // locking in IPv6/IPv4-mapped SSRF coverage that the string fallback alone
    // does not provide.
    test('isUrlSafe rejects IPv6 loopback (::1)', () {
      expect(ApiClient.isUrlSafe('http://[::1]/admin'), isFalse);
    });

    test('isUrlSafe rejects IPv6 unique-local (fc00::/7)', () {
      expect(ApiClient.isUrlSafe('http://[fc00::1]/x'), isFalse);
      expect(ApiClient.isUrlSafe('http://[fd12:3456::1]/x'), isFalse);
    });

    test('isUrlSafe rejects IPv6 link-local (fe80::/10)', () {
      expect(ApiClient.isUrlSafe('http://[fe80::1]/x'), isFalse);
    });

    test('isUrlSafe rejects IPv4-mapped IPv6 private address', () {
      expect(ApiClient.isUrlSafe('http://[::ffff:10.0.0.1]/x'), isFalse);
    });

    test('isUrlSafe accepts a public IPv6 address', () {
      expect(ApiClient.isUrlSafe('http://[2001:4860:4860::8888]/x'), isTrue);
    });

    test('isUrlSafe skipped when validation disabled', () {
      BduiConfig.enableUrlValidation = false;
      expect(ApiClient.isUrlSafe('http://localhost/admin'), isTrue);
      BduiConfig.enableUrlValidation = true;
    });
  });
}
