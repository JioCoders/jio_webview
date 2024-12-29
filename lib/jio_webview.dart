import 'package:flutter/services.dart';
import 'package:jio_webview/plugin/jio_webview_platform_interface.dart';

export 'package:jio_webview/src/native_webview.dart';
export 'package:jio_webview/src/webview_controller.dart';

class JioWebview {
  MethodChannel getMethodChannel() {
    return JioWebviewPlatform.instance.getMethodChannel();
  }

  Future<String?> getPlatformInfo() {
    return JioWebviewPlatform.instance.getPlatformInfo();
  }
}
