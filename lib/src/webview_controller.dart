import 'package:flutter/services.dart';

typedef NavigationDelegateHandler = Future<NavigationDecision> Function(
    NavigationRequest request);

class WebViewController {
  final MethodChannel _channel;

  WebViewController(int viewId)
      : _channel = MethodChannel('com.jiocoders/jio_webview_$viewId');

  Future<void> reload() async => _channel.invokeMethod('reload');

  Future<bool> canGoBack() async =>
      await _channel.invokeMethod('canGoBack') ?? false;

  Future<void> goBack() async => _channel.invokeMethod('goBack');

  Future<void> loadUrl(String url) async {
    _channel.invokeMethod('loadUrl', {'url': url});
  }

  Future<String> evaluateJavascript(String script) async =>
      await _channel.invokeMethod('evaluateJavascript', {'script': script}) ??
      '';

  Future<void> loadHtmlAsset(String assetPath) async =>
      _channel.invokeMethod('loadHtmlAsset', {'assetPath': assetPath});

  Future<void> loadHtmlString(String htmlString) async =>
      _channel.invokeMethod('loadHtmlString', {'htmlString': htmlString});

  Future<void> clearCache() async => _channel.invokeMethod('clearCache');

  Future<void> clearLocalStorage() async =>
      _channel.invokeMethod('clearLocalStorage');

  Future<String> getUserAgent() async =>
      await _channel.invokeMethod('getUserAgent') ?? '';

  Future<void> setUserAgent(String userAgent) async =>
      _channel.invokeMethod('setUserAgent', {'userAgent': userAgent});

  Future<String> runJavaScript(String script) async =>
      await _channel.invokeMethod('runJavaScript', {'script': script}) ?? '';

  Future<void> setNavigationDelegate(NavigationDelegate delegate) async {
    _channel.setMethodCallHandler((MethodCall call) async {
      switch (call.method) {
        case "onPageStarted":
          delegate.onPageStarted?.call(call.arguments["url"]);
          break;
        case "onPageFinished":
          delegate.onPageFinished?.call(call.arguments["url"]);
          break;
        case "onHttpError":
          delegate.onHttpError
              ?.call(HttpResponseError(call.arguments["error"]));
          break;
        case "onNavigationRequest":
          final request = NavigationRequest(call.arguments["url"]);
          final decision = await delegate.onNavigationRequest?.call(request);
          return decision == NavigationDecision.prevent
              ? "prevent"
              : "navigate";
        default:
          return null;
      }
    });
  }
}

class NavigationDelegate {
  final void Function(int progress)? onProgress;
  final void Function(String url)? onPageStarted;
  final void Function(String url)? onPageFinished;
  final void Function(HttpResponseError error)? onHttpError;
  final NavigationDelegateHandler? onNavigationRequest;

  NavigationDelegate({
    this.onProgress,
    this.onPageStarted,
    this.onPageFinished,
    this.onHttpError,
    this.onNavigationRequest,
  });
}

class NavigationRequest {
  final String url;

  NavigationRequest(this.url);
}

enum NavigationDecision { navigate, prevent }

class HttpResponseError {
  final String description;

  HttpResponseError(this.description);
}
