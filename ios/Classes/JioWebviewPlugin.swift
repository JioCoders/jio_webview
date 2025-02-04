import Flutter

public class JioWebviewPlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "com.jiocoders/jio_webview", binaryMessenger: registrar.messenger())
    let instance = JioWebviewPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)

    let factory = JioWebviewFactory(binaryMessenger: registrar.messenger())
    registrar.register(factory, withId: "com.jiocoders/jio_webview")
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "getPlatformInfo":
      result("iOS " + UIDevice.current.systemVersion)
    default:
      result(FlutterMethodNotImplemented)
    }
  }
}
