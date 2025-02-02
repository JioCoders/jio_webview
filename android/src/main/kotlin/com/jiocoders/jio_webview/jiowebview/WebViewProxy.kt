package com.jiocoders.jio_webview.jiowebview

import android.content.Context
import android.net.Proxy
import android.webkit.WebView
import java.lang.reflect.Field

fun WebViewProxy(webView: WebView, host: String, port: Int): Boolean {
    return try {
        val webviewClass = Class.forName("android.webkit.WebView")
        val field: Field = webviewClass.getDeclaredField("mContext")
        field.isAccessible = true
        val context: Context = field.get(webView) as Context

        val properties = System.getProperties()
        properties["http.proxyHost"] = host
        properties["http.proxyPort"] = port.toString()

        true
    } catch (e: Exception) {
        e.printStackTrace()
        false
    }
}
