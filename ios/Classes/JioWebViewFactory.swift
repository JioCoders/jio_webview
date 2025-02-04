import Flutter

public class JioWebviewFactory: NSObject, FlutterPlatformViewFactory {
    private var messenger: FlutterBinaryMessenger

    public init(binaryMessenger: FlutterBinaryMessenger) {
        self.messenger = binaryMessenger
        super.init()
    }

    public func create(withFrame frame: CGRect, viewIdentifier viewId: Int64, arguments args: Any?) -> FlutterPlatformView {
        return NativeWebview(frame: frame, viewId: viewId, viewIdentifier: args, binaryMessenger: messenger)
    }

    func createArgsCodec() -> FlutterMessageCodec & NSObjectProtocol {
        return FlutterStandardMessageCodec.sharedInstance()
    }
}

// NativeWebview - Flutter PlatformView
public class NativeWebview: NSObject, FlutterPlatformView {
    private var webViewController: WebViewController

    init(frame: CGRect, viewIdentifier viewId: Int64, arguments args: Any?, binaryMessenger messenger: FlutterBinaryMessenger) {
        // Extract URL and other params from arguments
        var initialUrl: String? = nil
        if let arguments = args as? [String: Any] {
            initialUrl = arguments["initialUrl"] as? String
        }

        // Initialize the JioWebViewController with the viewId and initial URL
        self.webViewController = WebViewController(frame: frame, viewId: viewId, binaryMessenger: messenger!, initialUrl: initialUrl)
        super.init()
    }

    public func view() -> UIView {
        return webViewController.getWebView()
    }
}
