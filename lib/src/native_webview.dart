import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:jio_webview/jio_webview.dart';

class NativeWebView extends StatelessWidget {
  const NativeWebView({super.key, required this.onControllerCreated});

  final void Function(WebViewController controller)? onControllerCreated;

  @override
  Widget build(BuildContext context) {
    final jioWebView = JioWebview();

    final MethodChannel channel = jioWebView.getMethodChannel();
    final viewTypeValue = channel.name;
    const webUrl = 'https://google.com/';

    if (defaultTargetPlatform == TargetPlatform.android) {
      return PlatformViewLink(
        viewType: viewTypeValue,
        onCreatePlatformView: (PlatformViewCreationParams params) {
          final controller = WebViewController(params.id);
          if (onControllerCreated != null) {
            onControllerCreated?.call(controller);
          }
          return PlatformViewsService.initSurfaceAndroidView(
            id: params.id,
            creationParams: const {'initialUrl': webUrl},
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
        viewType: viewTypeValue,
        onPlatformViewCreated: (int viewId) {
          final controller = WebViewController(viewId);
          onControllerCreated?.call(controller);
        },
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
