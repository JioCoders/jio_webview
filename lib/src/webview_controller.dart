import 'dart:developer' as developer;

import 'package:flutter/services.dart';
import 'package:jio_webview/src/utils/javascript_channel.dart';
import 'package:jio_webview/src/utils/javascript_message.dart';
import 'package:jio_webview/src/utils/typedef_handler.dart';

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

  Future<String> getCurrentUrl() async =>
      await _channel.invokeMethod('getCurrentUrl') ?? '';

  Future<void> loadUrl(String url) async {
    _channel.invokeMethod('loadUrl', {'url': url});
  }

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

  Future<String> evaluateJavascript(String script) async =>
      await _channel.invokeMethod('evaluateJavaScript', {'script': script}) ??
      '';

  Future<String> runJavaScript(String script) async =>
      await _channel.invokeMethod('runJavaScript', {'script': script}) ?? '';

  Future<void> registerPopupWindowJavaScriptListener(
      NavigationDelegate delegate,
      {required JavascriptChannel jsChannel}) async {
    developer.log('javaScriptChannelRegistered::${jsChannel.name}');
    // Flutter side: listening for popup creation events, handle navigation and JS Events
    _channel.setMethodCallHandler((call) async {
      developer.log(
          'Received::Method - ${call.method}, Argument - ${call.arguments}');
      final args = call.arguments as Map<dynamic, dynamic>? ?? {};
      switch (call.method) {
        case 'onUpiUrlDetected':
          TypedefHandler handler = TypedefHandler(onUpiUrlDetected: (url) {
            developer.log('UPI URL detected::$url');
          });
          if (handler.onUpiUrlDetected != null) {
            handler.onUpiUrlDetected!(args['url']);
          }
          break;
        case 'onPageError':
          TypedefHandler handler = TypedefHandler();
          if (handler.onPageError != null) {
            handler.onPageError!(args['error']);
          }
          break;
        case "onJioInterfaceMessage":
          String messageString = args['message'];
          final jsMessage = JavaScriptMessage(message: messageString);
          jsChannel.onMessageReceived.call(jsMessage);
          return String;
        // Handle pop-ups
        case "onPopupWindowCreated":
          String url = args['url'];
          developer.log("Popup window created with URL: $url");
          break;
        case 'onPopupWindowClosed':
          developer.log("Pop-up window closed successfully!");
          break;
        // Handle other cases as needed
        case 'onJsAlert':
          developer.log("JS Alert: ${args['message']}");
          break;
        case 'onJsPrompt':
          developer.log("JS Prompt: ${args['message']}");
          break;
        case 'onConsoleMessage':
          developer.log("Console Log: ${args['message']}");
          break;
        case "onTitleReceived":
          String titleString = args['title'];
          developer.log("Title Received: $titleString");
          break;
        case "onPageStarted":
          delegate.onPageStarted?.call(args["url"]);
          break;
        case 'onProgressChanged':
          delegate.onProgress?.call(args["progress"]);
          break;
        case "onPageFinished":
          delegate.onPageFinished?.call(args["url"]);
          break;
        case "onHttpError":
          final httpError = HttpResponseError(args["error"]);
          delegate.onHttpError?.call(httpError);
          break;
        // Handle navigation request
        case "onNavigationRequest":
          final request = NavigationRequest(args["url"]);
          final decision = await delegate.onNavigationRequest?.call(request);
          return decision == NavigationDecision.prevent
              ? "prevent"
              : "navigate";
        default:
          developer.log("Unknown method: ${call.method}");
          break;
      }
    });
  }
}

class JsMessageDelegate {
  final void Function(String message)? onMessageReceived;

  JsMessageDelegate({
    this.onMessageReceived,
  });
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
