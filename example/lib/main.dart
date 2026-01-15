import 'dart:async';
import 'dart:developer' as developer;

import 'package:flutter/material.dart';
import 'package:jio_webview/jio_webview.dart';
import 'package:url_launcher/url_launcher.dart';

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
  static const String webUrl = 'https://jiocoders.com/';
  late final WebViewController _webViewController;
  final String kLogExamplePage = '''
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>HTML string</title>
    <script>
        function sendIosMessageToFlutter() {
            if (window.webkit && window.webkit.messageHandlers.JioFlutterJsInterface) {
                window.webkit.messageHandlers.JioFlutterJsInterface.postMessage("Hello from HTML!");
            } else {
                console.log("Flutter interface not available.");
            }
        }
    </script>
    <script>
        function postSomeMessage(message) {
            window.webkit.messageHandlers.headerInfo.postMessage(message)
        }
    </script>
    <script type="text/javascript">
        const functionAlert = (message) => alert(message);
        window.fAlert = functionAlert;
        
        const mLogs = (msg) => console.info(msg);
        window.fLog = mLogs;
//-------experimental-----------
        // fromFlutter(newTitle) {
        //     document.getElementById("title").innerHTML = newTitle;
        //     sendBack();
        // }
        // window.function = fff;
        function sendBack() {
            window.webkit.messageHandler.headerInfo.postMessage("Hello from JS");
        }
    </script>
</head>
<body onLoad="console.log('Logging that the page is loading.')">

<h3>Local Html Page</h3>
<style>
    .btn-group button {
      padding: 8px; 12px;
      display: block;
      width: 60%;
      margin: 5px 0px 10px 0px;
    }
</style>
<div class="btn-group">
    <ul><ul>
    <button onclick="sendIosMessageToFlutter()"><b>Send iOS Message</b></button>
    <button onclick="window.JioFlutterJsInterface.postMessage('js_close')"><b>Call Flutter</b></button>
    <button onclick="console.error('This is an error message.')"><b>Error</b></button>
    <button onclick="console.debug('This is a debug message.')"><b>Debug</b></button>
    <button onclick="console.log('This is a log message.')"><b>Log</b></button>
    <button onclick="alert('Alert from WebView!')"><b>Alert</b></button>
    <button onclick="prompt('Prompt from WebView!')"><b>Prompt</b></button>
    <button onclick="window.open('https://www.w3schools.com/jsref/tryit.asp?filename=tryjsref_win_open')"><b>Pop-up Open</b></button>
    <button onclick="window.close()"><b>Pop-up Close</b></button>
</div>

<p>
  <i>The navigation delegate is set to block navigation to the youtube website.</i>
</p>
  <ul><ul>
    <a href="upi://pay?pa=upiaddress@okhdfcbank&pn=JohnDoe&cu=INR">Buy Now</a>
    <br/>
    <br/>
    <a href="https://www.youtube.com/">https://www.youtube.com/</a>
    <br/>
    <br/>
    <a href="https://www.google.com/">https://www.google.com/</a>
  <br/>
</body>
</html>
''';

  Future<void> setupController() async {
    _webViewController.registerJavaScriptListener(
      NavigationDelegate(
        onPageStarted: (url) {
          developer.log("Main.onPageStarted::$url");
          setState(() {
            isLoading = true;
          });
        },
        onProgress: (progress) {
          developer.log("Main.onProgress::$progress");
        },
        onPageFinished: (url) {
          developer.log("Main.onPageFinished::$url");
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
          if (request.url.startsWith('upi://pay?')) {
            _launchURL(request.url);
            return NavigationDecision.prevent;
          }
          return NavigationDecision.navigate;
        },
      ),
      jsChannel: /**/
          JavascriptChannel(
              name: 'JioFlutterJsInterface',
              onMessageReceived: (JavaScriptMessage message) {
                developer.log('Main::Message Received::${message.message}');
              }),
    );
  }

  void _launchURL(String url) async {
    var result = await launchUrl(Uri.parse(url));
    debugPrint(result.toString());
    if (result == true) {
      developer.log("UPI Success");
    } else if (result == false) {
      developer.log("UPI Fail");
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Jio WebView example app'),
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
                final userAgent = await _webViewController.getUserAgent();
                developer.log('defaultUserAgent:: $userAgent');
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
                // const homeUrl =
                //     'https://www.w3schools.com/jsref/tryit.asp?filename=tryjsref_win_open';
                // await _webViewController.loadUrl(homeUrl);
                await _webViewController.loadHtmlString(kLogExamplePage);
              },
            ),
          ],
        ),
        body: Stack(
          children: [
            NativeWebView(
              headers: const {},
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
