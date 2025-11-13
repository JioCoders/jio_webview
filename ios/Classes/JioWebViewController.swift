import Flutter
import UIKit
@preconcurrency import WebKit

// WebViewController - Handles WebView logic and managing WKWebView
public class WebViewController:
                NSObject,
//                UIViewController,
                WKUIDelegate,
                WKNavigationDelegate,
                WKScriptMessageHandler {

    private var methodChannel: FlutterMethodChannel?
    private var webView: WKWebView!
    var popupWebView: WKWebView?

    init(frame: CGRect, viewId: Int64, messenger: FlutterBinaryMessenger, initialUrl: String?) {
//        super.init(nibName: nil, bundle: nil)
        super.init()

        // Set up WKPreferences preferences
        let preferences = WKPreferences()
        preferences.javaScriptEnabled = true
        preferences.javaScriptCanOpenWindowsAutomatically = true

        // Set up the WKWebView configuration
        let configuration = WKWebViewConfiguration()
        configuration.preferences = preferences

        let contentController = WKUserContentController()

        // Set the script message handler
        contentController.add(self, name: "FlutterWebView") // JavaScript message handler
        webConfiguration.userContentController = contentController
        // Example: Disable cookies or other privacy-related settings
        webConfiguration.websiteDataStore = WKWebsiteDataStore.nonPersistent()
        // Example: Handle Web Privacy or Tracking policies
        webConfiguration.processPool = WKProcessPool()

        // Create the WebView
//        self.webView = WKWebView(frame: CGRect.zero, configuration: configuration)
        self.webView = WKWebView(frame: frame, configuration: configuration)
        self.webView.autoresizingMask = [.flexibleWidth, .flexibleHeight]

        guard let webView = self.webView else { return }
//        if let rootViewController = UIApplication.shared.keyWindow?.rootViewController {
//            rootViewController.view.addSubview(webView!)
//            // Add the WKWebView as a subview and set constraints (for full-screen WebView)
//            webView?.translatesAutoresizingMaskIntoConstraints = false
//            NSLayoutConstraint.activate([
//                webView!.topAnchor.constraint(equalTo: rootViewController.view.topAnchor),
//                webView!.bottomAnchor.constraint(equalTo: rootViewController.view.bottomAnchor),
//                webView!.leftAnchor.constraint(equalTo: rootViewController.view.leftAnchor),
//                webView!.rightAnchor.constraint(equalTo: rootViewController.view.rightAnchor)
//            ])
//        }

        webView.uiDelegate = self
        // Assign self and set as the navigation delegate to handle navigation requests
        webView.navigationDelegate = self

//        if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String{
//            userAgent =  userAgent + "v\(version)"
//            webView.evaluateJavaScript("navigator.userAgent") { (result, error) in
//                if let defaultUserAgent = result as? String {
//                     customUserAgent = defaultUserAgent + " \(userAgent)"
//                    self.webView.customUserAgent = customUserAgent
//                    print("customUserAgent-\(customUserAgent)") //for Future testing
//                }
//            }
//        }

        // Set up a Flutter method channel to communicate with Flutter side
        methodChannel = FlutterMethodChannel(name: "com.jiocoders/jio_webview_\(viewId)", binaryMessenger: messenger)

        // Set up the method channel to handle method calls from Flutter
        methodChannel?.setMethodCallHandler { [weak self] call, result in
            self?.handleMethodCall(call, result: result)
        }

        // If we have a URL and headers, load it into the webview
        let headers = dict?["headers"] as? [String: String] ?? [:]
        if let url = initialUrl, let requestURL = URL(string: url) {
            let request = URLRequest(url: requestURL)
            for (key, value) in headers {
                request.setValue(value, forHTTPHeaderField: key)
            }
            webView.load(request)
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

//    public override func viewDidLoad() {
//        super.viewDidLoad()
//    }

    // MARK: - WKUIDelegate Methods (for handling popups)
    public func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
        // Here we create a new WKWebView instance to handle the popup
        // You can add this new popupWebView to your view hierarchy here or manage it accordingly
        popupWebView = WKWebView(frame: webView.bounds, configuration: configuration)
        self.popupWebView!.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.popupWebView!.navigationDelegate = self
        self.popupWebView!.uiDelegate = self
        webView.addSubview(popupWebView!)

        // Notify Flutter that a popup has been created
        methodChannel?.invokeMethod("onPopupWindowCreated", arguments: ["url": navigationAction.request.url?.absoluteString ?? ""])

        // Return the newly created WebView for the popup
        return popupWebView
    }

    public func webViewDidClose(_ webView: WKWebView) {
       webView.removeFromSuperview()
        popupWebView = nil
    }

    // MARK: - WKNavigationDelegate Methods
    public func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        methodChannel?.invokeMethod("onPageStarted", arguments: ["url": webView.url?.absoluteString ?? ""])
    }

    public func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        methodChannel?.invokeMethod("onPageFinished", arguments: ["url": webView.url?.absoluteString ?? ""])
    }

    public func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        methodChannel?.invokeMethod("onHttpError", arguments: ["error": error.localizedDescription])
    }

    public func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        if let url = navigationAction.request.url,
           url.scheme == "upi" {
          // Notify Flutter if a specific custom URL scheme (e.g., UPI) is detected
          methodChannel?.invokeMethod("onUpiUrlDetected", arguments: ["url": url.absoluteString])
        }

        let urlString = navigationAction.request.url?.absoluteString ?? ""
        // Call Flutter to get navigation decision
        methodChannel?.invokeMethod("onNavigationRequest", arguments: ["url": urlString]) { (result) in
            if let resultString = result as? String {
                print("decidePolicyFor::\(resultString):: \(urlString)")
                if resultString == "prevent" {
                    decisionHandler(.cancel) // Prevent the navigation
                } else {
                    decisionHandler(.allow) // Allow the navigation
                }
            } else {
                // Default to allowing navigation if no decision was received
                decisionHandler(.allow)
            }
        }
    }

    // MARK: - WKScriptMessageHandler
    public func userContentController(_ userContentController: WKUserContentController,
        didReceive message: WKScriptMessage
    ) {
        print("Received Event::\(message.name)***")
        // Forward the message from JS to Flutter
        // Ensure invokeMethod is called on the main thread
        let flutterEvent = "onJioInterfaceMessage"
        switch message.name {
        case "FlutterWebView":
            DispatchQueue.main.async {
                self.methodChannel?.invokeMethod(flutterEvent, arguments: ["type": "flutterEvent", "message": message.body])
            }
        default:
            // Handle JS console messages
            if let messageBody = message.body as? [String: Any],
               let _ = messageBody["type"] as? String,
               let _ = messageBody["message"] as? String {
                // Send logs back to Flutter
                // Ensure invokeMethod is called on the main thread
                DispatchQueue.main.async {
                    self.methodChannel?.invokeMethod("onConsoleMessage", arguments: messageBody) //["type": type, "message": logMessage])
                }
            }
            break // You can handle the default case if needed, or leave it empty if no action is required
        }
    }

    // MARK: - Handle Flutter Method Calls
    private func handleMethodCall(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "loadUrl":
            if let args = call.arguments as? [String: Any],
               let urlString = args["url"] as? String, // Ensure it's a valid string
               let url = URL(string: urlString) { // Check if the string can be converted to a valid URL
                self.loadUrl(url, result: result)
            } else {
                result(FlutterError(code: "INVALID_URL", message: "Invalid URL", details: nil))
            }
        case "goBack":
            goBack(result: result)
        case "goForward":
            goForward(result: result)
        case "reload":
            reload(result: result)
        case "getCurrentUrl":
            getCurrentUrl(result: result)
        case "getUserAgent":
            getUserAgent(result: result)
        case "setUserAgent":
            if let arguments = call.arguments as? [String: Any],
               let userAgent = arguments["userAgent"] as? String {
                setUserAgent(userAgent, result: result)
            } else {
                result(FlutterError(code: "INVALID_ARGUMENTS", message: "UserAgent not provided", details: nil))
            }
        case "clearCache":
            self.clearWebViewCache()
            result(nil)
        case "clearLocalStorage":
            result(nil)
        case "evaluateJavaScript":
            if let args = call.arguments as? [String: Any],
               let script = args["script"] as? String {
                webView.evaluateJavaScript(script) { (response, error) in
                    if let error = error {
                        result(FlutterError(code: "JS_ERROR", message: error.localizedDescription, details: nil))
                    } else {
                        result(response)
                    }
                }
            } else {
                result(FlutterError(code: "INVALID_ARGUMENT", message: "JavaScript code is required", details: nil))
            }
        case "loadHtmlString":
            if let args = call.arguments as? [String: Any],
               let htmlString = args["htmlString"] as? String {
                self.loadHtmlString(htmlString, result: result)
            } else {
                result(FlutterError(code: "INVALID_ARGUMENT", message: "htmlString argument is missing", details: nil))
            }
        case "setNavigationDelegate":
            // This is automatically handled by the navigation delegate setup
            result(nil)
        case "onNavigationRequest":
            let urlString = call.arguments as? String ?? ""
            self.handleNavigationRequest(urlString: urlString, result: result)
        default:
            result(FlutterMethodNotImplemented)
        }
    }

    // Method to handle navigation request from Flutter
    private func handleNavigationRequest(urlString: String, result: @escaping FlutterResult) {
        let request = NavigationRequest(url: urlString)
            // self.onNavigationRequest(request: request) { decision in
            //    result(decision == .prevent ? "prevent" : "navigate")
            // }
    }

    // Define NavigationRequest struct to pass data to Flutter
    struct NavigationRequest {
        var url: String
    }

    // Load URL in WebView
    private func loadUrl(_ url: URL, result: @escaping FlutterResult) {
        // Check if URL is valid
        if UIApplication.shared.canOpenURL(url) {
            let request = URLRequest(url: url)
            webView.load(request)
            result(nil) // Return nil if successful
        } else {
            // Return an error if the URL can't be opened
            result(FlutterError(code: "INVALID_URL", message: "Cannot open the URL", details: nil))
        }
    }

    // Method to go back, if backstack history is available
    private func goBack(result: @escaping FlutterResult) {
        print("WKWebview :: goBack")
        if webView.canGoBack {
            webView.goBack()
            result(nil)
        } else {
            result(FlutterError(code: "NO_HISTORY", message: "No history to go back to", details: nil))
        }
    }

    // Method to go forward, if history is available
    private func goForward(result: @escaping FlutterResult) {
        if webView.canGoForward {
            webView.goForward()
            result(nil)
        } else {
            result(FlutterError(code: "NO_HISTORY", message: "No history to go forward to", details: nil))
        }
    }

    // Method to reload the WebView
    private func reload(result: @escaping FlutterResult) {
        webView.reload()
        print("WKWebview :: Reloading")
        result(nil)
    }

    // Method to get the current URL
    private func getCurrentUrl(result: @escaping FlutterResult) {
        result(webView.url?.absoluteString ?? "")
    }

    // Method to get the current User-Agent String
    private func getUserAgent(result: @escaping FlutterResult) {
        if let userAgent = webView.value(forKey: "userAgent") as? String {
            result(userAgent)
        } else {
            result(FlutterError(code: "USER_AGENT_ERROR", message: "Unable to fetch UserAgent", details: nil))
        }
    }

    // Method to set a custom User-Agent
    private func setUserAgent(_ userAgent: String, result: @escaping FlutterResult) {
        webView.customUserAgent = userAgent
        result(nil)
    }

    // Method to load HTML string into WKWebView
    private func loadHtmlString(_ htmlString: String, result: @escaping FlutterResult) {
        webView.loadHTMLString(htmlString, baseURL: nil)
        result(nil)  // Return null to indicate success
    }

    // Method to clear WebView cache
    private func clearWebViewCache() {
        WKWebsiteDataStore.default().removeData(ofTypes:
            [WKWebsiteDataTypeDiskCache, WKWebsiteDataTypeMemoryCache],
            modifiedSince: Date(timeIntervalSince1970: 0),
            completionHandler: {
                print("WebView cache cleared successfully!")
            })

        // Ensure WebView is using WKWebView
        // guard let webView = self.webView else { return }
        // Optionally, you can also perform additional cleanup for the webView
        // webView.navigationDelegate = nil
        // webView.uiDelegate = nil
        // webView.stopLoading()
    }

    func getWebView() -> WKWebView {
        return webView
    }
}
