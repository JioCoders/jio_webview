import 'package:flutter/material.dart';
import 'package:jio_webview/jio_webview.dart';
import 'dart:developer' as developer;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late final WebViewController _webViewController;

  @override
  void initState() {
    super.initState();
  }

  Future<void> setupController() async {
    const webUrl = 'https://pub.dev/';
    // final oldUserAgent = await _webViewController.getUserAgent();
    // final newUserAgent = '$oldUserAgent CustomAgent';
    // _webViewController.setUserAgent(newUserAgent);
    _webViewController.setNavigationDelegate(
      NavigationDelegate(
        onPageStarted: (url) => developer.log("Page started loading: $url"),
        onPageFinished: (url) => developer.log("Page finished loading: $url"),
        onHttpError: (error) =>
            developer.log("HTTP error: ${error.description}"),
        onNavigationRequest: (request) async {
          if (request.url.startsWith('https://www.youtube.com/')) {
            return NavigationDecision.prevent;
          }
          return NavigationDecision.navigate;
        },
      ),
    );
    Future.delayed(Duration.zero, () => _webViewController.loadUrl(webUrl));
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('WebView example app'),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () async {
                await _webViewController.reload();
              },
            ),
            IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () async {
                if (await _webViewController.canGoBack()) {
                  await _webViewController.goBack();
                }
              },
            ),
            IconButton(
              icon: const Icon(Icons.home),
              onPressed: () async {
                await _webViewController.loadUrl('https://pub.dev/');
              },
            ),
          ],
        ),
        body: NativeWebView(
          onControllerCreated: (wc) {
            _webViewController = wc;
            setupController();
          },
        ),
      ),
    );
  }
}
