// test/webview_platform_interface_test.dart

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jio_webview_platform_interface/webview/webview_platform_interface.dart';
import 'fake_webview_platform.dart'; // Import the fake implementation

void main() {
  // This ensures Flutter bindings are initialized.
  TestWidgetsFlutterBinding.ensureInitialized();

  group('WebviewPlatformInterface Tests', () {
    late FakeWebviewPlatform fakePlatform;

    setUp(() {
      // Create a fake platform instance and assign it.
      fakePlatform = FakeWebviewPlatform(
        customMethodChannel: const MethodChannel('com.jiocoders/test_webview'),
      );
      WebviewPlatformInterface.instance = fakePlatform;
    });

    test('getWebviewMethodChannel returns correct channel', () {
      final channel = WebviewPlatformInterface.instance.getWebviewMethodChannel();
      expect(channel.name, equals('com.jiocoders/test_webview'));
    });

    test('reload completes successfully', () async {
      await WebviewPlatformInterface.instance.reload();
    });

    test('canGoBack returns true', () async {
      final result = await WebviewPlatformInterface.instance.canGoBack();
      expect(result, isTrue);
    });

    test('getCurrentUrl returns expected URL', () async {
      final url = await WebviewPlatformInterface.instance.getCurrentUrl();
      expect(url, equals('https://example.com'));
    });

    test('getUserAgent returns fake user agent', () async {
      final userAgent = await WebviewPlatformInterface.instance.getUserAgent();
      expect(userAgent, equals('fakeUserAgent'));
    });

    test('evaluateJavascript returns expected result', () async {
      final result = await WebviewPlatformInterface.instance.evaluateJavascript('alert("Hi")');
      expect(result, equals('evaluated:alert("Hi")'));
    });

    test('runJavaScript returns expected result', () async {
      final result = await WebviewPlatformInterface.instance.runJavaScript('alert("Hi")');
      expect(result, equals('ran:alert("Hi")'));
    });
  });
}
