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
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    const webUrl = 'https://flutter.dev/';
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('WebView example app'),
        ),
        body: JioWebView(
          onControllerCreated: (controller) async {
            await controller.loadUrl(webUrl);
            controller.setNavigationDelegate(
              NavigationDelegate(
                onPageStarted: (url) =>
                    developer.log("Page started loading: $url"),
                onPageFinished: (url) =>
                    developer.log("Page finished loading: $url"),
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
          },
        ),
      ),
    );
  }
}
