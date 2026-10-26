import SwiftUI
import WebKit
import UIKit

@MainActor
final class JournalBrowserModel: NSObject, ObservableObject, WKNavigationDelegate, WKUIDelegate {
    @Published var isLoading = false
    @Published var canGoBack = false
    @Published var canGoForward = false
    @Published var errorMessage: String?
    let webView: WKWebView
    private var endpoint: URL?

    override init() {
        let configuration = WKWebViewConfiguration()
        configuration.websiteDataStore = .default()
        webView = WKWebView(frame: .zero, configuration: configuration)
        super.init()
        webView.navigationDelegate = self
        webView.uiDelegate = self
        webView.allowsBackForwardNavigationGestures = true
        webView.isOpaque = false
        webView.backgroundColor = UIColor(red: 0.96, green: 0.95, blue: 0.92, alpha: 1)
        webView.scrollView.backgroundColor = webView.backgroundColor
    }

    func open(_ url: URL) {
        endpoint = url
        errorMessage = nil
        isLoading = true
        webView.load(URLRequest(url: url))
    }

    private func sameOrigin(_ url: URL) -> Bool {
        guard let endpoint else { return false }
        func port(_ value: URL) -> Int { value.port ?? (value.scheme == "https" ? 443 : 80) }
        return url.scheme == endpoint.scheme && url.host?.lowercased() == endpoint.host?.lowercased() && port(url) == port(endpoint)
    }

    func webView(_ webView: WKWebView, decidePolicyFor action: WKNavigationAction,
                 decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        guard let url = action.request.url else { decisionHandler(.cancel); return }
        if sameOrigin(url) { decisionHandler(.allow); return }
        if action.navigationType == .linkActivated, ["http", "https", "mailto", "tel"].contains(url.scheme ?? "") {
            UIApplication.shared.open(url)
        }
        decisionHandler(.cancel)
    }

    func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration,
                 for action: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
        if let url = action.request.url, sameOrigin(url) { webView.load(action.request) }
        return nil
    }

    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        isLoading = true
        errorMessage = nil
    }
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        isLoading = false
        canGoBack = webView.canGoBack
        canGoForward = webView.canGoForward
    }
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) { report(error) }
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) { report(error) }
    private func report(_ error: Error) {
        if (error as NSError).code == NSURLErrorCancelled { return }
        isLoading = false
        errorMessage = "请确认电脑或服务器正在运行，并检查网络和连接地址。\n" + error.localizedDescription
    }
}

struct JournalWebView: UIViewRepresentable {
    @ObservedObject var browser: JournalBrowserModel
    func makeUIView(context: Context) -> WKWebView { browser.webView }
    func updateUIView(_ uiView: WKWebView, context: Context) {}
}

