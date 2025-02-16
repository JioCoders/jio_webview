import 'package:flutter/services.dart';
import 'package:jio_webview_platform_interface/plugin/plugin_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockPluginPlatformInterface
    with MockPlatformInterfaceMixin
    implements PluginPlatformInterface {
  @override
  Future<String?> getPlatformInfo() => Future.value('95');

  @override
  MethodChannel getMethodChannel() {
    return const MethodChannel('com.jiocoders/jio_webview_test');
  }
}
