package com.jiocoders.jio_webview.jiowebview

import android.content.Context
import android.os.Handler
import android.os.Looper
import android.util.Log
import android.webkit.JavascriptInterface
import android.webkit.WebView
import android.webkit.WebSettings
import com.jiocoders.jio_webview.JioWebviewPlugin
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.platform.PlatformView

class JioAndroidWebview(
    context: Context,
    private val creationParams: Map<*, *>?,
    private val methodChannel: MethodChannel
) : PlatformView {
    private val webView: WebView = WebView(context).apply {
        webViewClient = JioWebViewClient(methodChannel)
        webChromeClient = JioWebChromeClient(methodChannel)
        settings.apply {
            // Set javascript mode
            javaScriptEnabled = true
            domStorageEnabled = true
            // Set user agent
            val defaultUserAgent = WebSettings.getDefaultUserAgent(context)
            val customUserAgent = "$defaultUserAgent MyCustomApp/2.0"
            userAgentString = customUserAgent
            // Set pop-up window
            javaScriptCanOpenWindowsAutomatically = true
            setSupportMultipleWindows(false)
            // Set no cache mode
            settings.cacheMode = WebSettings.LOAD_NO_CACHE
            mixedContentMode = WebSettings.LOAD_NO_CACHE
        }
    }
    private val webViewController = JioWebViewController(webView)

    init {
//        setWebViewProxy(webView, "192.168.1.1", 8080) // Set Proxy

        // Load the initial URL if provided
        val initialUrl = creationParams?.get("initialUrl") as? String
        initialUrl?.let {
            webView.loadUrl(it)
        }

        // Set up MethodChannel to handle Flutter method calls

        val methodChannelHandler = JioWebViewMethodChannelHandler(webView)
        methodChannel.setMethodCallHandler(methodChannelHandler)

        // Add a JavaScript interface
        webView.addJavascriptInterface(WebAppInterface(methodChannel), "FlutterWebView")
    }

    override fun getView(): WebView = webView

    override fun dispose() {
        webView.apply {
            stopLoading()
            clearHistory()
            clearCache(true)
            removeAllViews()
            destroy()
        }
        methodChannel.setMethodCallHandler(null)
    }

    // JavaScript interface for communication
    private class WebAppInterface(private val methodChannel: MethodChannel) {
        @JavascriptInterface
        fun postMessage(message: String) {
            // Example: This can be expanded for custom JS-to-Native communication
            Log.d(JioWebviewPlugin.TAG_APP, "Message from JavaScript: $message")
            Handler(Looper.getMainLooper()).post {
                methodChannel.invokeMethod("onJioInterfaceMessage", mapOf("type" to "flutterEvent", "message" to message))
            }
        }

        @JavascriptInterface
        fun jioMessage(message: String) {
            // Example: This can be expanded for custom JS-to-Native communication
            Log.d(JioWebviewPlugin.TAG_APP, "Message from jioMessage: $message")
            Handler(Looper.getMainLooper()).post {
                methodChannel.invokeMethod("onJioInterfaceMessage", mapOf("type" to "flutterEvent", "message" to message))
            }
        }
    }
}
