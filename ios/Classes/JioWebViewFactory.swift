import Flutter
import UIKit
import WebKit

public class JioWebviewFactory: NSObject, FlutterPlatformViewFactory {
    private let registrar: FlutterPluginRegistrar

    public init(registrar: FlutterPluginRegistrar) {
        self.registrar = registrar
        super.init()
    }

    public func create(withFrame frame: CGRect, viewIdentifier viewId: Int64, arguments args: Any?) -> FlutterPlatformView {
        return NativeWebview(frame: frame, viewId: viewId, registrar: registrar)
    }
}

// WebViewController - Handles WebView logic
public class WebViewController: NSObject, WKNavigationDelegate {
    private var webView: WKWebView
    private var methodChannel: FlutterMethodChannel

    init(webView: WKWebView, viewId: Int64, registrar: FlutterPluginRegistrar) {
        self.webView = webView

        // Get the Flutter engine's binary messenger
        let messenger = registrar.messenger()

        // Set up a Flutter method channel to communicate with Flutter side
        methodChannel = FlutterMethodChannel(name: "com.jiocoders/jio_webview_\(viewId)", binaryMessenger: messenger)
        super.init()

        // Assign self as the navigation delegate
        webView.navigationDelegate = self

        // Set up the method channel to handle method calls from Flutter
        methodChannel.setMethodCallHandler { [weak self] call, result in
            self?.handleMethodCall(call, result: result)
        }
    }

    // WKNavigationDelegate Methods
    public func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        methodChannel.invokeMethod("onPageStarted", arguments: ["url": webView.url?.absoluteString ?? ""])
    }

    public func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        methodChannel.invokeMethod("onPageFinished", arguments: ["url": webView.url?.absoluteString ?? ""])
    }

    public func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        methodChannel.invokeMethod("onHttpError", arguments: ["error": error.localizedDescription])
    }

    public func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        let url = navigationAction.request.url?.absoluteString ?? ""
        methodChannel.invokeMethod("onNavigationRequest", arguments: ["url": url]) { result in
            if let decision = result as? String, decision == "prevent" {
                decisionHandler(.cancel)
            } else {
                decisionHandler(.allow)
            }
        }
    }

    // handle method calls
    private func handleMethodCall(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "setNavigationDelegate":
            // This is automatically handled by the navigation delegate setup
            result(nil)
        case "loadUrl":
            if let arguments = call.arguments as? [String: Any],
               let url = arguments["url"] as? String {
                loadUrl(url: url, result: result)
            } else {
                result(FlutterError(code: "INVALID_ARGUMENTS", message: "URL not provided", details: nil))
            }
        case "goBack":
            goBack(result: result)
        case "goForward":
            goForward(result: result)
        case "reload":
            reload(result: result)
        case "getCurrentUrl":
            getCurrentUrl(result: result)
        default:
            result(FlutterMethodNotImplemented)
        }
    }

    func loadUrl(url: String, result: @escaping FlutterResult) {
        if let validUrl = URL(string: url) {
            webView.load(URLRequest(url: validUrl))
            result(nil)
        } else {
            result(FlutterError(code: "INVALID_URL", message: "URL is invalid", details: nil))
        }
    }

    private func goBack(result: @escaping FlutterResult) {
        if webView.canGoBack {
            webView.goBack()
            result(nil)
        } else {
            result(FlutterError(code: "NO_HISTORY", message: "No history to go back to", details: nil))
        }
    }

    private func goForward(result: @escaping FlutterResult) {
        if webView.canGoForward {
            webView.goForward()
            result(nil)
        } else {
            result(FlutterError(code: "NO_HISTORY", message: "No history to go forward to", details: nil))
        }
    }

    private func reload(result: @escaping FlutterResult) {
        webView.reload()
        print("Webview :: Reloading")
        result(nil)
    }

    private func getCurrentUrl(result: @escaping FlutterResult) {
        result(webView.url?.absoluteString)
    }

    func getWebView() -> WKWebView {
        return webView
    }
}

// NativeWebview - Flutter PlatformView
public class NativeWebview: NSObject, FlutterPlatformView {
    private var webViewController: WebViewController

    init(frame: CGRect, viewId: Int64, registrar: FlutterPluginRegistrar) {
        let webView = WKWebView(frame: frame)
        self.webViewController = WebViewController(webView: webView, viewId: viewId, registrar: registrar)
        super.init()

        // Load default URL
        webViewController.loadUrl(url: "https://jiocoders.com", result: { _ in })
    }

    public func view() -> UIView {
        return webViewController.getWebView()
    }
}
