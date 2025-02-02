package com.jiocoders.jio_webview.jiowebview

import android.util.Log
import android.webkit.WebView
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import com.jiocoders.jio_webview.JioWebviewPlugin

class JioWebViewMethodChannelHandler(private val webView: WebView) : MethodChannel.MethodCallHandler {
    private var webViewController = JioWebViewController(webView)

    init {
        requireNotNull(webView) { "WebView must not be null" }
        webViewController = JioWebViewController(webView)
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "loadUrl" -> {
                val url = call.argument<String>("url")
                if (url != null) {
                    Log.d(JioWebviewPlugin.TAG_APP, "LOAD_URL :: $url")
                    webView.loadUrl(url)
                    result.success(null)
                } else {
                    result.error("INVALID_URL", "URL is null", null)
                }
            }

            "reload" -> {
                Log.d(JioWebviewPlugin.TAG_APP, "RELOAD_NATIVE :: ${webView.url}")
                webViewController.reload()
                result.success(null)
            }

            "getCurrentUrl" -> result.success(webViewController.getCurrentUrl())
            "canGoBack" -> result.success(webView.canGoBack())
            "goBack" -> {
                Log.d(JioWebviewPlugin.TAG_APP, "GOBACK_NATIVE :: ${webView.url}")
                if (webViewController.canGoBack()) {
                    webViewController.goBack()
                    result.success(true)
                } else {
                    result.success(false)
                }
            }

            "evaluateJavaScript" -> {
                val script = call.argument<String>("script")
                if (script != null) {
                    webView.evaluateJavascript(script) { value -> result.success(value) }
                } else {
                    result.error("INVALID_SCRIPT", "Script is null", null)
                }
            }

            "runJavaScript" -> {
                val script = call.argument<String>("script") ?: ""
                webView.evaluateJavascript(script) { value ->
                    result.success(value)
                }
            }

            "loadHtmlAsset" -> {
                val assetPath = call.argument<String>("assetPath") ?: return result.error(
                    "INVALID_ASSET",
                    "Asset path is null",
                    null
                )
//                try {
//                    val htmlContent = context.assets.open(assetPath).bufferedReader().use { it.readText() }
//                    webView.loadDataWithBaseURL(null, htmlContent, "text/html", "UTF-8", null)
                result.success(null)
//                } catch (e: Exception) {
//                    result.error("ASSET_LOAD_ERROR", "Failed to load asset", e.localizedMessage)
//                }
            }

            "loadHtmlString" -> {
                val htmlString = call.argument<String>("htmlString") ?: ""
                webView.loadDataWithBaseURL(null, htmlString, "text/html", "UTF-8", null)
                result.success(null)
            }

            "clearCache" -> {
                try {
                    webView.clearCache(true)
                } catch (_: Exception) {
                } finally {
                    result.success(null)
                }
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

            else -> result.notImplemented()

        }
    }
}