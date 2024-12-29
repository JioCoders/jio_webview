import 'package:flutter/material.dart';
import 'package:jio_webview/jio_webview.dart';

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
    const webUrl = 'https://iocode.shop/';
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('WebView example app'),
        ),
        body: NativeWebView(
          onControllerCreated: (controller) async {
            await controller.loadUrl(webUrl);
          },
        ),
      ),
    );
  }
}
