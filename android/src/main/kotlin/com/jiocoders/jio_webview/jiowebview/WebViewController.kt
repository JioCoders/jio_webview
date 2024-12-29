package android.src.main.kotlin.com.epay.sbi.webview

import android.util.Log
import android.webkit.WebView

class WebViewController(private val webView: WebView) {

    fun loadUrl(url: String) {
        Log.d("WebViewController", "LoadUrl :: $url");
        webView.loadUrl(url)
    }

    fun canGoBack(): Boolean {
        return webView.canGoBack()
    }

    fun goBack() {
        if (canGoBack()) {
            webView.goBack()
        }
    }

    fun goForward() {
        if (webView.canGoForward()) {
            webView.goForward()
        }
    }

    fun reload() {
        webView.reload()
    }

    fun getCurrentUrl(): String? {
        return webView.url
    }
}
