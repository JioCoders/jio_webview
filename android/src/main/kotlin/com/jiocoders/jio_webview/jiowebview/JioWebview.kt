package com.jiocoders.jio_webview.jiowebview

import android.content.Context
import android.src.main.kotlin.com.epay.sbi.webview.WebViewController
import android.util.Log
import android.webkit.JavascriptInterface
import android.webkit.WebView
import android.webkit.WebViewClient
import android.webkit.WebChromeClient
import com.jiocoders.jio_webview.JioWebviewPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.platform.PlatformView

class JioWebview(
    context: Context,
    private val creationParams: Map<String, Any>?,
    private val methodChannel: MethodChannel
) : PlatformView, MethodChannel.MethodCallHandler {
    private val webView: WebView = WebView(context).apply {
        webViewClient = WebViewClient()
        webChromeClient = WebChromeClient()
        settings.javaScriptEnabled = true
    }
    private val webViewController = WebViewController(webView)

    init {
        // Load the initial URL if provided
        val initialUrl = creationParams?.get("initialUrl") as? String
        if (!initialUrl.isNullOrEmpty()) {
            webViewController.loadUrl(initialUrl)
        }

        // Set up MethodChannel to handle Flutter method calls
        methodChannel.setMethodCallHandler(this)

        // Add a JavaScript interface
        webView.addJavascriptInterface(WebAppInterface(), "AndroidInterface")
    }

    override fun getView(): WebView = webView

    override fun dispose() {
        webView.destroy()
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "loadUrl" -> {
                val url = call.argument<String>("url")
                if (url != null) {
                    Log.d(JioWebviewPlugin.TAG_APP, "URL :: $url")
                    webView.loadUrl(url)
                    result.success(null)
                } else {
                    result.error("INVALID_URL", "URL is null", null)
                }
            }

            "reload" -> {
                webViewController.reload()
                result.success(null)
            }

            "getCurrentUrl" -> result.success(webViewController.getCurrentUrl())
            "canGoBack" -> result.success(webView.canGoBack())
            "goBack" -> {
                if (webViewController.canGoBack()) {
                    webViewController.goBack()
                    result.success(true)
                } else {
                    result.success(false)
                }
            }

            "evaluateJavascript" -> {
                val script = call.argument<String>("script")
                if (script != null) {
                    webView.evaluateJavascript(script) { value -> result.success(value) }
                } else {
                    result.error("INVALID_SCRIPT", "Script is null", null)
                }
            }

            "loadHtmlAsset" -> {
                val assetPath = call.argument<String>("assetPath") ?: ""
//                val htmlContent = context!!.assets.open(assetPath).bufferedReader().use { it.readText() }
//                webView.loadDataWithBaseURL(null, htmlContent, "text/html", "UTF-8", null)
                result.success(null)
            }

            "loadHtmlString" -> {
                val htmlString = call.argument<String>("htmlString") ?: ""
                webView.loadDataWithBaseURL(null, htmlString, "text/html", "UTF-8", null)
                result.success(null)
            }

            "clearCache" -> {
                webView.clearCache(true)
                result.success(null)
            }

            "clearLocalStorage" -> {
                android.webkit.WebStorage.getInstance().deleteAllData()
                result.success(null)
            }

            "getUserAgent" -> result.success(webView.settings.userAgentString)
            "setUserAgent" -> {
                val userAgent = call.argument<String>("userAgent") ?: ""
                webView.settings.userAgentString = userAgent
                result.success(null)
            }

            "runJavaScript" -> {
                val script = call.argument<String>("script") ?: ""
                webView.evaluateJavascript(script) { value ->
                    result.success(value)
                }
            }

            else -> result.notImplemented()
        }
    }

    // JavaScript interface for communication
    private class WebAppInterface {
        @JavascriptInterface
        fun showToast(message: String) {
            // Example: This can be expanded for custom JS-to-Native communication
            Log.d(JioWebviewPlugin.TAG_APP, "Message from JavaScript: $message")
        }
    }
}
