package com.jiocoders.jio_webview.jiowebview

import android.util.Log
import android.view.Gravity
import android.view.WindowManager
import android.webkit.ConsoleMessage
import android.webkit.JsPromptResult
import android.webkit.JsResult
import android.webkit.WebChromeClient
import android.webkit.WebSettings
import android.webkit.WebView
import android.webkit.WebView.WebViewTransport
import android.widget.PopupWindow
import android.widget.Toast
import io.flutter.plugin.common.MethodChannel

// Custom JioChromeClient to handle popups
internal class JioWebChromeClient(private val methodChannel: MethodChannel) : WebChromeClient() {
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
                settings.domStorageEnabled = true
                settings.cacheMode = WebSettings.LOAD_NO_CACHE
                settings.javaScriptCanOpenWindowsAutomatically = true // Important for pop-ups
                settings.setSupportMultipleWindows(true)  // Allow multiple windows (required for pop-ups)
                webChromeClient = view.webChromeClient
//                webChromeClient = this@JioWebChromeClient
                webViewClient = JioWebViewClient(methodChannel) // handle loading of URLs in

                // Add JavaScript Interface to listen for popup closure
                addJavascriptInterface(object {
                    @android.webkit.JavascriptInterface
                    fun onPopupClosed() {
                        // Handle popup window close event
                        Log.d("WebView", "Popup window closed!")
                        Toast.makeText(context, "Popup closed", Toast.LENGTH_SHORT).show()
                    }
                }, "Android")
            }

            // Set up a new frame layout to hold the popup
//             view?.addView(newWebView)
//            val cxt = view?.context as? Context
//            if(cxt != null){
//                val frameLayout = FrameLayout(cxt)
//                frameLayout.addView(newWebView)
//            }
//            val dialog = Dialog(view.context, android.R.style.Theme_Black_NoTitleBar_Fullscreen)
//            dialog.setContentView(newWebView)
//            dialog.show()

            // Create a PopupWindow for the new WebView
//            val popupWindow = PopupWindow(newWebView, 600, 800)
            val popupWindow = PopupWindow(
                newWebView,
                WindowManager.LayoutParams.MATCH_PARENT,
                WindowManager.LayoutParams.MATCH_PARENT
            )
            popupWindow.isFocusable = true
            popupWindow.isOutsideTouchable = true

            // Show the PopupWindow
//            PopupWindowCompat.showAsDropDown(popupWindow, findViewById(R.id.rootLayout), Gravity.CENTER, 0, 0)
//            window.setFlags(WindowManager.LayoutParams.FLAG_FULLSCREEN, WindowManager.LayoutParams.FLAG_FULLSCREEN)
            popupWindow.showAtLocation(newWebView, Gravity.NO_GRAVITY, 0, 0)

            // Detect popup window dismissal
            popupWindow.setOnDismissListener {
                // Trigger the JavaScript function when the popup is closed
                newWebView.evaluateJavascript(
                    "window.onunload = function() { Android.onPopupClosed(); };",
                    null
                )
            }
            // Dismiss the popup when clicked outside
//            popupWindow.setOnTouchListener {_, _ ->
//                popupWindow.dismiss()
//                true
//            }

            // You can add the new frameLayout to your view hierarchy here or use it in a dialog, etc.
            // Send back the WebView instance for pop-up handling
//            val transport = resultMsg?.obj as? WebView.WebViewTransport
//            transport?.webView = newWebView
//            resultMsg?.sendToTarget()

            // Add the new WebView to the WebView that initiated the popup
            (resultMsg?.obj as? WebView)?.addView(newWebView)

            (resultMsg?.obj as WebViewTransport).webView = newWebView
            resultMsg.sendToTarget()

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

    //    void checkPopupOpened(){
    //        _channel.setMethodCallHandler((MethodCall call) async {
    //            if (call.method == 'onPopupOpened') {
    //                String url = call.arguments['url']; // Expecting a 'url' string
    //                developer.log('Popup opened with URL: $url');
    //            }
    //        });
    //    }

    // Additional methods like onReceivedTitle or onProgressChanged can be overridden as needed
    override fun onReceivedTitle(view: WebView?, title: String?) {
        super.onReceivedTitle(view, title)
        // Optionalley, send the title of the page to Flutter
        methodChannel.invokeMethod("onTitleReceived", mapOf("title" to title))
    }

    // Handle progress changes
    override fun onProgressChanged(view: WebView?, newProgress: Int) {
        methodChannel.invokeMethod("onProgressChanged", mapOf("progress" to newProgress))
    }

    // Handle custom view (for video fullscreen, etc.)
    override fun onShowCustomView(view: android.view.View?, callback: CustomViewCallback?) {
        super.onShowCustomView(view, callback)
        Log.d("WebChromeClient", "onShowCustomView")
        methodChannel.invokeMethod("onShowCustomView", null)
    }

    override fun onHideCustomView() {
        super.onHideCustomView()
        Log.d("WebChromeClient", "onHideCustomView")
        methodChannel.invokeMethod("onHideCustomView", null)
    }

    override fun onCloseWindow(window: WebView?) {
        super.onCloseWindow(window)
        Log.d("WebChromeClient", "onCloseWindow: Pop-up closed")
        methodChannel.invokeMethod("onPopupWindowClosed", null)
    }
}
