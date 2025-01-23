package com.jiocoders.jio_webview.jiowebview

import android.content.Context
import android.util.Log
import android.webkit.JavascriptInterface
import android.webkit.WebView
import android.webkit.WebViewClient
import android.webkit.WebChromeClient
import android.webkit.ConsoleMessage
import android.webkit.JsPromptResult
import android.webkit.JsResult
import android.webkit.WebResourceError
import android.webkit.WebResourceRequest
import android.webkit.WebSettings
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
        webViewClient = JioWebViewClient(methodChannel)
        webChromeClient = JioWebChromeClient(methodChannel)
        settings.apply {
            javaScriptEnabled = true
            domStorageEnabled = true
            settings.cacheMode = WebSettings.LOAD_NO_CACHE
            javaScriptCanOpenWindowsAutomatically = true  // Important for pop-ups
        }
    }
    private val webViewController = WebViewController(webView)

    init {
        // Load the initial URL if provided
        val initialUrl = creationParams?.get("initialUrl") as? String
        initialUrl?.let {
            webView.loadUrl(it)
        }

        // Set up MethodChannel to handle Flutter method calls
        methodChannel.setMethodCallHandler(this)

        // Add a JavaScript interface
        webView.addJavascriptInterface(WebAppInterface(methodChannel), "AndroidInterface")
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

            "evaluateJavascript" -> {
                val script = call.argument<String>("script")
                if (script != null) {
                    webView.evaluateJavascript(script) { value -> result.success(value) }
                } else {
                    result.error("INVALID_SCRIPT", "Script is null", null)
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
    private class WebAppInterface(private val methodChannel: MethodChannel) {
        @JavascriptInterface
        fun showToast(message: String) {
            // Example: This can be expanded for custom JS-to-Native communication
            Log.d(JioWebviewPlugin.TAG_APP, "Message from JavaScript: $message")
            methodChannel.invokeMethod("onJsMessage", mapOf("message" to message))
        }
    }
}

// Custom WebChromeClient to handle popups
private class JioWebChromeClient(private val methodChannel: MethodChannel) : WebChromeClient() {
    // Handle JS pop-up window test using dummy html script
    override fun onCreateWindow(
        view: WebView?,
        isDialog: Boolean,
        isUserGesture: Boolean,
        resultMsg: android.os.Message?
    ): Boolean {
        Log.d("WebChromeClient", "JS Alert: onCreateWindow prompt")
        val context = view?.context ?: return false // Ensure context is available

        // Handle pop-up window creation
        try {
            val newWebView = WebView(context).apply {
                settings.javaScriptEnabled = true
                settings.domStorageEnabled = false
                settings.cacheMode = WebSettings.LOAD_NO_CACHE
                settings.javaScriptCanOpenWindowsAutomatically = false // for popups
                settings.setSupportMultipleWindows(true)  // Allow multiple windows (required for pop-ups)
                webChromeClient = this@JioWebChromeClient
                webViewClient = WebViewClient() // handle loading of URLs in
            }

            // Set up a new frame layout to hold the popup
            // val frameLayout = FrameLayout(view?.context)
            // frameLayout.addView(newWebView)
            // You can add the new frameLayout to your view hierarchy here or use it in a dialog, etc.
            // Send back the WebView instance for pop-up handling
            val transport = resultMsg?.obj as? WebView.WebViewTransport
            transport?.webView = newWebView
            resultMsg?.sendToTarget()

            // Notify Flutter about the pop-up window creation event
            // methodChannel.invokeMethod("onPopupWindowCreated", mapOf("url" to view?.url ?: ""))
            methodChannel.invokeMethod(
                "onPopupWindowCreated",
                mapOf("url" to (view.url ?: "about:blank"))
            )
            // Indicate we handled the pop-up
            return true
        } catch (e: Exception) {
            Log.e("JioWebChromeClient", "Error handling popup: ${e.message}")
            return false
        }
        // Return true/false to indicate we handled the window creation
    } // Close onCreateWindow

    // Handle JavaScript alerts
    override fun onJsAlert(
        view: WebView?,
        url: String?,
        message: String?,
        result: JsResult?
    ): Boolean {
        Log.d("WebChromeClient", "JS Alert KT: $message")
        methodChannel.invokeMethod("onJsAlert", mapOf("url" to url, "message" to message))
        result?.confirm()
        return true  // Indicate that the alert is handled
    }

    // Handle JavaScript confirm dialogs
    override fun onJsConfirm(
        view: WebView?,
        url: String?,
        message: String?,
        result: JsResult?
    ): Boolean {
        Log.d("WebChromeClient", "JS Confirm: $message")
        methodChannel.invokeMethod("onJsConfirm", mapOf("url" to url, "message" to message))
        result?.confirm()
        return true  // Indicate that the confirm is handled
    }

    // Handle JavaScript prompt dialogs
    override fun onJsPrompt(
        view: WebView?,
        url: String?,
        message: String?,
        defaultValue: String?,
        result: JsPromptResult?
    ): Boolean {
        Log.d("WebChromeClient", "JS Prompt: $message")
        methodChannel.invokeMethod(
            "onJsPrompt",
            mapOf("url" to url, "message" to message, "defaultValue" to defaultValue)
        )
        result?.confirm(defaultValue)
        return true  // Indicate that the prompt is handled
    }

    // Handle JavaScript console messages
    override fun onConsoleMessage(consoleMessage: ConsoleMessage?): Boolean {
        consoleMessage?.let {
            Log.d("WebChromeClient", "Console: ${it.message()}")
            methodChannel.invokeMethod(
                "onConsoleMessage",
                mapOf(
                    "message" to it.message(),
                    "sourceId" to it.sourceId(),
                    "lineNumber" to it.lineNumber()
                )
            )
        }
        return true
    }

    // Handle progress changes
    override fun onProgressChanged(view: WebView?, newProgress: Int) {
        Log.d("WebChromeClient", "Loading Progress: $newProgress")
        methodChannel.invokeMethod("onProgressChanged", mapOf("progress" to newProgress))
    }

    // Handle custom view (for video fullscreen, etc.)
    override fun onShowCustomView(view: android.view.View?, callback: CustomViewCallback?) {
        super.onShowCustomView(view, callback)
        methodChannel.invokeMethod("onShowCustomView", null)
    }

    override fun onHideCustomView() {
        super.onHideCustomView()
        methodChannel.invokeMethod("onHideCustomView", null)
    }

    override fun onCloseWindow(window: WebView?) {
        super.onCloseWindow(window)
        Log.d("WebChromeClient", "onCloseWindow: Pop-up closed")
        methodChannel.invokeMethod("onPopupWindowClosed", null)
    }
}

// Custom WebViewClient for handling navigation events
private class JioWebViewClient(private val methodChannel: MethodChannel) : WebViewClient() {
    override fun onPageStarted(view: WebView?, url: String?, favicon: android.graphics.Bitmap?) {
        super.onPageStarted(view, url, favicon)
        methodChannel.invokeMethod("onPageStarted", mapOf("url" to (url ?: "")))
    }

    override fun onPageFinished(view: WebView?, url: String?) {
        super.onPageFinished(view, url)
        methodChannel.invokeMethod("onPageFinished", mapOf("url" to (url ?: "")))
    }

    override fun onReceivedError(
        view: WebView?,
        request: WebResourceRequest?,
        error: WebResourceError?
    ) {
        super.onReceivedError(view, request, error)
        methodChannel.invokeMethod(
            "onHttpError",
            mapOf("error" to (error?.description?.toString() ?: "Unknown error"))
        )
    }

    override fun shouldOverrideUrlLoading(view: WebView?, request: WebResourceRequest?): Boolean {
        val url = request?.url?.toString() ?: ""
        Log.d(JioWebviewPlugin.TAG_APP, "shouldOverrideUrlLoading.URL :: $url")
        // Invoke method on the Flutter side through method channel
        methodChannel.invokeMethod(
            "onNavigationRequest",
            mapOf("url" to url),
            object : MethodChannel.Result {
                // Check the result from Flutter side
                override fun success(result: Any?) {
                    // Handle the success response
                    // If result is "prevent", do not load the URL. Otherwise, load the URL in the WebView
                    Log.d(
                        JioWebviewPlugin.TAG_APP,
                        "shouldOverrideUrlLoading.result :: $result :: $url"
                    )
                    if (result == "prevent") {
                        // Stop loading the URL
                        // return@invokeMethod
                        return
                    }
                    // Allow loading the URL
                    view?.loadUrl(url)
                }

                override fun error(errorCode: String, errorMessage: String?, errorDetails: Any?) {
                    // Handle error if needed
                    // For now, just log the error
                    Log.e("WebViewClient", "Error handling navigation request: $errorMessage")
                    println("Error: $errorCode, $errorMessage, $errorDetails")
                }

                override fun notImplemented() {
                    // Handle method not implemented if needed
                    // For now, just log the method not implemented
                    Log.w("WebViewClient", "Navigation request method not implemented")
                }
            })
        // Return true to indicate that we are handling the URL loading
        return true
    }
}
