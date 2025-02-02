package com.jiocoders.jio_webview.jiowebview

import io.flutter.plugin.common.MethodChannel
import android.net.http.SslError
import android.util.Log
import android.webkit.SslErrorHandler
import android.webkit.WebResourceError
import android.webkit.WebResourceRequest
import android.webkit.WebView
import android.webkit.WebViewClient
import com.jiocoders.jio_webview.JioWebviewPlugin

// Custom WebViewClient for handling navigation events
internal class JioWebViewClient(private val methodChannel: MethodChannel) : WebViewClient() {
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

//    override fun onReceivedSslError(
//        view: WebView?,
//        handler: SslErrorHandler?,
//        error: SslError?
//    ) {
//        // Ignore SSL certificate errors and proceed with loading
//        handler?.proceed()  // Ignore SSL certificate errors
//        Log.w("WebViewClint", "SSL Error ignored: ${error?.primaryError}")
//    }
//    val proxyHeaders = mapOf(
//        "Proxy-Authorization" to "Basic " + android.util.Base64.encodeToString(
//            "username:password".toByteArray(),
//            android.util.Base64.NO_WRAP
//        )
//    )
//    override fun shouldInterceptRequest(view: WebView?, request: WebResourceRequest?): WebResourceResponse? {
//        request?.requestHeaders?.putAll(proxyHeaders)
//        request?.requestHeaders?.put("User-Agent", "ForcedUserAgent/3.0")
//        return super.shouldInterceptRequest(view, request)
//    }

    override fun shouldOverrideUrlLoading(view: WebView?, request: WebResourceRequest?): Boolean {
        val url = request?.url?.toString() ?: ""
        // Invoke method on the Flutter side through method channel
        methodChannel.invokeMethod(
            "onNavigationRequest",
            mapOf("url" to url),
            object : MethodChannel.Result {
                // Check the result from Flutter side
                override fun success(result: Any?) {
                    // Handle the success response
                    // If result is "prevent", do not load the URL. Otherwise, load the URL in the WebView
                    Log.d(JioWebviewPlugin.TAG_APP, "shouldOverrideUrlLoading.result :: $result :: $url")
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
