# jio_webview

A Flutter plugin for both android and iOS which provides native webview.

Published package url -
```
https://pub.dev/packages/jio_webview
```

## Usage

[Example](https://github.com/JioCoders/jio_webview/blob/main/example/lib/main.dart)

To use this package :

- add the dependency to your [pubspec.yaml](https://github.com/JioCoders/jio_webview/blob/main/pubspec.yaml) file.

```yaml
dependencies:
  flutter:
    sdk: flutter
  jio_webview:
```

### How to use

```dart
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
  bool isLoading = false;
  static const String webUrl = 'https://jiocoders.com';
  late final WebViewController _webViewController;

  @override
  void initState() {
    super.initState();
  }

  Future<void> setupController() async {
    _webViewController.setNavigationDelegate(
      NavigationDelegate(
        onPageStarted: (url) {
          developer.log("Page started loading: $url");
          setState(() {
            isLoading = true;
          });
        },
        onPageFinished: (url) {
          developer.log("Page finished loading: $url");
          setState(() {
            isLoading = false;
          });
        },
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
    _webViewController.registerPopupWindowListener();
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
              icon: const Icon(Icons.run_circle),
              onPressed: () async {
                _webViewController
                    .evaluateJavascript("console.log('Console message test')");
                _webViewController.evaluateJavascript("""
                    var newWin = window.open('https://www.w3schools.com/jsref/tryit.asp?filename=tryjsref_win_open');
                    if (!newWin || newWin.closed || typeof newWin.closed == 'undefined') { 
                        console.log('Pop-up blocked'); 
                    } else {
                        console.log('Pop-up opened successfully!'); 
                    }
                  """);
              },
            ),
            IconButton(
              icon: const Icon(Icons.home),
              onPressed: () async {
                const homeUrl =
                    'https://www.w3schools.com/jsref/tryit.asp?filename=tryjsref_win_open';
                await _webViewController.loadUrl(homeUrl);
              },
            ),
          ],
        ),
        body: Stack(
          children: [
            NativeWebView(
              webUrl: webUrl,
              onControllerCreated: (wc) {
                _webViewController = wc;
                setupController();
              },
            ),
            isLoading
                ? const Center(child: CircularProgressIndicator())
                : const SizedBox()
          ],
        ),
      ),
    );
  }
}


```

# License

Copyright (c) 2024 Jiocoders

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.

## Getting Started

For help getting started with Flutter, view our online [documentation](https://flutter.io/).

For help on editing package code, view the [documentation](https://flutter.io/developing-packages/).
