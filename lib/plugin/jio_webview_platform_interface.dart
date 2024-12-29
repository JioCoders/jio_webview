import 'package:flutter/services.dart';
import 'package:jio_webview/plugin/jio_webview_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

abstract class JioWebviewPlatform extends PlatformInterface {
  /// Constructs a JioWebviewPlatform.
  JioWebviewPlatform() : super(token: _token);

  static final Object _token = Object();

  static JioWebviewPlatform _instance = MethodChannelJioWebview();

  /// The default instance of [JioWebviewPlatform] to use.
  ///
  /// Defaults to [MethodChannelJioWebview].
  static JioWebviewPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [JioWebviewPlatform] when
  /// they register themselves.
  static set instance(JioWebviewPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  MethodChannel getMethodChannel() {
    throw UnimplementedError('methodChannel() has not been implemented.');
  }

  Future<String?> getPlatformInfo() {
    throw UnimplementedError('platformInfo() has not been implemented.');
  }
}
