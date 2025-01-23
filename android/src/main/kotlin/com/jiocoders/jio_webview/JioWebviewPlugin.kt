package com.jiocoders.jio_webview

import androidx.annotation.NonNull
import com.jiocoders.jio_webview.jiowebview.WebViewFactory

import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler

/** JioWebviewPlugin */
class JioWebviewPlugin : FlutterPlugin, MethodCallHandler {
    /// The MethodChannel that will the communication between Flutter and native Android
    ///
    /// This local reference serves to register the plugin with the Flutter Engine and unregister it
    /// when the Flutter Engine is detached from the Activity
    private lateinit var channel: MethodChannel

    companion object {
        const val TAG_APP = "JioWebviewPluginAndroid"
        const val CHANNEL_NAME = "com.jiocoders/jio_webview"
    }

    override fun onAttachedToEngine(flutterBinding: FlutterPlugin.FlutterPluginBinding) {
        val messenger = flutterBinding.binaryMessenger
        channel = MethodChannel(messenger, CHANNEL_NAME)
        channel.setMethodCallHandler(this)

        flutterBinding.platformViewRegistry.registerViewFactory(
            CHANNEL_NAME, WebViewFactory(messenger)
        )
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        if (call.method == "getPlatformInfo") {
            result.success("Android ${android.os.Build.VERSION.RELEASE}")
        } else {
            result.notImplemented()
        }
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }
}
