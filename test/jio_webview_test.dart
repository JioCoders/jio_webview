import 'package:flutter/foundation.dart';
import 'package:flutter/src/services/platform_channel.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jio_webview/jio_webview.dart';
import 'package:jio_webview/plugin/jio_webview_platform_interface.dart';
import 'package:jio_webview/plugin/jio_webview_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockJioWebviewPlatform
    with MockPlatformInterfaceMixin
    implements JioWebviewPlatform {
  @override
  Future<String?> getPlatformInfo() => Future.value('95');

  @override
  MethodChannel getMethodChannel() {
    return const MethodChannel('com.jiocoders/jio_webview_test');
  }
}

void main() {
  final JioWebviewPlatform initialPlatform = JioWebviewPlatform.instance;

  test('$MethodChannelJioWebview is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelJioWebview>());
  });

  test('getPlatformInfo', () async {
    JioWebview jioWebviewPlugin = JioWebview();
    MockJioWebviewPlatform fakePlatform = MockJioWebviewPlatform();
    JioWebviewPlatform.instance = fakePlatform;

    debugPrint('Channel :: ${fakePlatform.getMethodChannel().name}');
    expect(await jioWebviewPlugin.getPlatformInfo(), '95');
  });
}
