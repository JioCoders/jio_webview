// test/fake_webview_platform.dart

import 'package:flutter/services.dart';
import 'package:jio_webview_platform_interface/webview/webview_platform_interface.dart';

/// A fake implementation of [WebviewPlatformInterface] for testing.
class FakeWebviewPlatform extends WebviewPlatformInterface {
  FakeWebviewPlatform({super.customMethodChannel});

  @override
  MethodChannel getWebviewMethodChannel() {
    return methodChannel;
  }

  @override
  Future<void> reload() async {
    // Simply complete.
  }

  @override
  Future<bool> canGoBack() async {
    return true;
  }

  @override
  Future<void> goBack() async {
    // Simply complete.
  }

  @override
  Future<String> getCurrentUrl() async {
    return 'https://example.com';
  }

  @override
  Future<void> loadUrl(String url) async {
    // For testing, we do nothing or you could record the url if needed.
  }

  @override
  Future<void> loadHtmlAsset(String assetPath) async {
    // Do nothing.
  }

  @override
  Future<void> loadHtmlString(String htmlString) async {
    // Do nothing.
  }

  @override
  Future<void> clearCache() async {
    // Do nothing.
  }

  @override
  Future<void> clearLocalStorage() async {
    // Do nothing.
  }

  @override
  Future<String> getUserAgent() async {
    return 'fakeUserAgent';
  }

  @override
  Future<void> setUserAgent(String userAgent) async {
    // Do nothing.
  }

  @override
  Future<String> evaluateJavascript(String script) async {
    return 'evaluated:$script';
  }

  @override
  Future<String> runJavaScript(String script) async {
    return 'ran:$script';
  }
}
