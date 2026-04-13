import 'package:flutter_test/flutter_test.dart';
import 'package:backend_driven_ui/src/core/bdui_config.dart';

void main() {
  group('BduiConfig', () {
    tearDown(BduiConfig.reset);

    test('has correct defaults', () {
      expect(BduiConfig.maxWidgetDepth, 50);
      expect(BduiConfig.maxChildren, 500);
      expect(BduiConfig.maxActionDepth, 10);
      expect(BduiConfig.maxCacheEntries, 100);
      expect(BduiConfig.defaultCacheDuration, const Duration(minutes: 5));
      expect(BduiConfig.defaultTimeout, const Duration(seconds: 30));
      expect(BduiConfig.defaultMaxRetries, 3);
      expect(BduiConfig.maxAllowedRetries, 10);
      expect(BduiConfig.enableLogging, isTrue);
      expect(BduiConfig.enableUrlValidation, isTrue);
      expect(BduiConfig.allowedUrlSchemes, ['http', 'https']);
      expect(BduiConfig.baseUrl, '');
    });

    test('reset restores all defaults after mutation', () {
      BduiConfig.maxWidgetDepth = 99;
      BduiConfig.maxChildren = 1000;
      BduiConfig.baseUrl = 'https://api.example.com';
      BduiConfig.enableLogging = false;

      BduiConfig.reset();

      expect(BduiConfig.maxWidgetDepth, 50);
      expect(BduiConfig.maxChildren, 500);
      expect(BduiConfig.baseUrl, '');
      expect(BduiConfig.enableLogging, isTrue);
    });

    test('baseUrl can be set and read', () {
      BduiConfig.baseUrl = 'https://api.myapp.com';
      expect(BduiConfig.baseUrl, 'https://api.myapp.com');
    });

    test('values can be independently changed', () {
      BduiConfig.maxWidgetDepth = 25;
      BduiConfig.enableLogging = false;
      expect(BduiConfig.maxWidgetDepth, 25);
      expect(BduiConfig.enableLogging, isFalse);
      // Others should be untouched
      expect(BduiConfig.maxChildren, 500);
    });
  });
}
