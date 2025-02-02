package com.jiocoders.jio_webview

import android.util.Log
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

class JioPluginMethodChannelHandler() : MethodChannel.MethodCallHandler {

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {

            "getPlatformVersion" -> {
                Log.d(JioWebviewPlugin.TAG_APP, "Call.getPlatformVersion")
                result.success("Android ${android.os.Build.VERSION.RELEASE}")
            }

            else -> result.notImplemented()
        }
    }
}