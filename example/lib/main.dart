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
  static const String webUrl = 'https://iocode.shop';
  late final WebViewController _webViewController;

  @override
  void initState() {
    super.initState();
  }

  Future<void> setupController() async {
    // final oldUserAgent = await _webViewController.getUserAgent();
    // final newUserAgent = '$oldUserAgent CustomAgent';
    // _webViewController.setUserAgent(newUserAgent);
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
    // Future.delayed(Duration.zero, () => _webViewController.loadUrl(webUrl));
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
                // _webViewController
                //     .evaluateJavascript("alert('Hello from WebView')");
                // _webViewController
                //     .evaluateJavascript("console.log('Console message test')");
                // _webViewController.evaluateJavascript(
                //     "window.open('https://www.google.com');");
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
