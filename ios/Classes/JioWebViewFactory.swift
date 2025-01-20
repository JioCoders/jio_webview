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
public class WebViewController: NSObject, WKNavigationDelegate, WKUIDelegate {
    private var webView: WKWebView
    var popupWebView: WKWebView?
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

        webView.uiDelegate = self

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
        print("decidePolicyFor:: \(url)")
        methodChannel.invokeMethod("onNavigationRequest", arguments: ["url": url]) { result in
            if let decision = result as? String, decision == "prevent" {
                decisionHandler(.cancel)
            } else {
                decisionHandler(.allow)
            }
        }
    }

    // WKUIDelegate Methods (for handling popups)
    public func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
        // Here we create a new WKWebView instance to handle the popup
//        let popupWebView = WKWebView(frame: webView.frame, configuration: configuration)
//        popupWebView.uiDelegate = self  // Set the UI delegate for the popup webview

        let preferences = WKPreferences()
        preferences.javaScriptEnabled = true
        preferences.javaScriptCanOpenWindowsAutomatically = true

        // You can add this new popupWebView to your view hierarchy here or manage it accordingly
        popupWebView = WKWebView(frame: webView.bounds, configuration: configuration)
        configuration.preferences = preferences
        self.popupWebView!.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.popupWebView!.navigationDelegate = self
        self.popupWebView!.uiDelegate = self
        webView.addSubview(popupWebView!)

        // Notify Flutter that a popup has been created
        methodChannel.invokeMethod("onPopupWindowCreated", arguments: ["url": navigationAction.request.url?.absoluteString ?? ""])

        // Return the newly created WebView for the popup
        return popupWebView
    }

    public func webViewDidClose(_ webView: WKWebView) {
       webView.removeFromSuperview()
        popupWebView = nil
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
        case "setUserAgent":
            if let arguments = call.arguments as? [String: Any],
               let userAgent = arguments["userAgent"] as? String {
                setUserAgent(userAgent, result: result)
            } else {
                result(FlutterError(code: "INVALID_ARGUMENTS", message: "UserAgent not provided", details: nil))
            }
        case "getUserAgent":
            getUserAgent(result: result)
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

    // Set a custom user agent string
    private func setUserAgent(_ userAgent: String, result: @escaping FlutterResult) {
        webView.customUserAgent = userAgent
        result(nil)
    }

    // Get the current user agent string
    private func getUserAgent(result: @escaping FlutterResult) {
        if let userAgent = webView.value(forKey: "userAgent") as? String {
            result(userAgent)
        } else {
            result(FlutterError(code: "USER_AGENT_ERROR", message: "Unable to fetch UserAgent", details: nil))
        }
    }

    func getWebView() -> WKWebView {
        return webView
    }
}

// NativeWebview - Flutter PlatformView
public class NativeWebview: NSObject, FlutterPlatformView {
    private var webViewController: WebViewController

    init(frame: CGRect, viewId: Int64, registrar: FlutterPluginRegistrar) {
        let preferences = WKPreferences()
        preferences.javaScriptEnabled = true
        preferences.javaScriptCanOpenWindowsAutomatically = true

        let configuration = WKWebViewConfiguration()
        configuration.preferences = preferences

//        let webView = WKWebView(frame: frame) // Without configuration
        let webView = WKWebView(frame: frame, configuration: configuration) // With configuration
//        webView.autoresizingMask = [.flexibleWidth, .flexibleHeight]

        self.webViewController = WebViewController(webView: webView, viewId: viewId, registrar: registrar)
        super.init()

        // Load default URL
        webViewController.loadUrl(url: "https://pub.dev", result: { _ in })
    }

    public func view() -> UIView {
        return webViewController.getWebView()
    }
}
