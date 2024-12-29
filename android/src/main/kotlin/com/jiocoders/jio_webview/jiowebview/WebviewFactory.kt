package com.jiocoders.jio_webview.jiowebview

import android.content.Context
import android.util.Log
import com.jiocoders.jio_webview.JioWebviewPlugin
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.platform.PlatformView
import io.flutter.plugin.platform.PlatformViewFactory
import io.flutter.plugin.common.StandardMessageCodec

class WebViewFactory(private val messenger: BinaryMessenger) : PlatformViewFactory(StandardMessageCodec.INSTANCE) {

    override fun create(context: Context?, viewId: Int, args: Any?): PlatformView {
        Log.d(JioWebviewPlugin.TAG_APP, "WebViewFactory.viewId :: $viewId")
        val methodChannel = MethodChannel(messenger, "com.jiocoders/jio_webview_$viewId")
        val params = args as? Map<String, Any>
        return JioWebview(context!!, params, methodChannel)
    }
}