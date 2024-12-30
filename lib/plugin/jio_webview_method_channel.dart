import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'jio_webview_platform_interface.dart';

/// An implementation of [JioWebviewPlatform] that uses method channels.
class MethodChannelJioWebview extends JioWebviewPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('com.jiocoders/jio_webview');

  @override
  MethodChannel getMethodChannel() {
    return methodChannel;
  }

  @override
  Future<String?> getPlatformInfo() async {
    final version = await methodChannel.invokeMethod<String>('getPlatformInfo');
    return version;
  }
}
