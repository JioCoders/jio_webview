import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jio_webview/jio_webview.dart';
import 'package:jio_webview_platform_interface/plugin/plugin_method_channel.dart';
import 'package:jio_webview_platform_interface/plugin/plugin_platform_interface.dart';

import 'mock_plugin_platform_interface.dart';

void main() {
  final PluginPlatformInterface initialPlatform =
      PluginPlatformInterface.instance;

  test('$MethodChannelPlugin is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelPlugin>());
  });

  test('getPlatformInfo', () async {
    JioPluginPlatform jioWebviewPlugin = JioPluginPlatform();
    MockPluginPlatformInterface fakePlatform = MockPluginPlatformInterface();
    PluginPlatformInterface.instance = fakePlatform;

    debugPrint('Channel :: ${fakePlatform.getMethodChannel().name}');
    expect(await jioWebviewPlugin.getPlatformInfo(), '95');
  });
}
