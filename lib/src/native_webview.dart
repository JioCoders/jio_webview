import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:jio_webview/jio_webview.dart';
import 'package:jio_webview_platform_interface/webview/webview_method_channel.dart';
import 'package:jio_webview_platform_interface/webview/webview_platform_interface.dart';

class NativeWebView extends StatelessWidget {
  const NativeWebView(
      {super.key, required this.onControllerCreated, required this.webUrl});

  final String webUrl;
  final void Function(WebViewController controller)? onControllerCreated;

  @override
  Widget build(BuildContext context) {
    final jioPlugin = JioPluginPlatform();

    final MethodChannel channel = jioPlugin.getMethodChannel();
    final creationParams = {'initialUrl': webUrl};
    final viewTypeValue = channel.name;

    if (defaultTargetPlatform == TargetPlatform.android) {
      return PlatformViewLink(
        key: key,
        viewType: viewTypeValue,
        onCreatePlatformView: (PlatformViewCreationParams params) {
          final mc = MethodChannel('com.jiocoders/jio_webview_${params.id}');
          WebviewPlatformInterface.instance =
              MethodChannelWebview(customMethodChannel: mc);
          final controller = WebViewController(params.id);
          if (onControllerCreated != null) {
            onControllerCreated?.call(controller);
          }
          return PlatformViewsService.initSurfaceAndroidView(
            id: params.id,
            creationParams: creationParams,
            viewType: viewTypeValue,
            layoutDirection: TextDirection.ltr,
            creationParamsCodec: const StandardMessageCodec(),
          )
            ..addOnPlatformViewCreatedListener(params.onPlatformViewCreated)
            ..create();
        },
        surfaceFactory:
            (BuildContext context, PlatformViewController controller) {
          return AndroidViewSurface(
            controller: controller as AndroidViewController,
            gestureRecognizers: const <Factory<OneSequenceGestureRecognizer>>{},
            hitTestBehavior: PlatformViewHitTestBehavior.opaque,
          );
        },
      );
    } else if (defaultTargetPlatform == TargetPlatform.iOS) {
      return UiKitView(
        key: key,
        creationParams: creationParams,
        viewType: viewTypeValue,
        onPlatformViewCreated: (int viewId) {
          final controller = WebViewController(viewId);
          onControllerCreated?.call(controller);
        },
        layoutDirection: TextDirection.ltr,
        creationParamsCodec: const StandardMessageCodec(),
      );
    } else {
      return const Center(
        child: Text(
          'WebView is not supported on this platform.',
          style: TextStyle(color: Colors.red),
        ),
      );
    }
  }
}
