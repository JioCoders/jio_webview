package com.jiocoders.jio_webview

import com.jiocoders.jio_webview.jiowebview.JioWebViewFactory

import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler

/** JioWebviewPlugin */
class JioWebviewPlugin : FlutterPlugin {
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

        val methodChannelHandler = JioPluginMethodChannelHandler()
        channel.setMethodCallHandler(methodChannelHandler)

        flutterBinding.platformViewRegistry.registerViewFactory(
            CHANNEL_NAME, JioWebViewFactory(messenger)
        )
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }
}
