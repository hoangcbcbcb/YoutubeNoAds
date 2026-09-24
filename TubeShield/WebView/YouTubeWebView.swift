//
//  YouTubeWebView.swift
//  TubeShield
//

import SwiftUI
import WebKit

struct YouTubeWebView: UIViewRepresentable {
    @ObservedObject var settings: AppSettings
    @Binding var canGoBack: Bool
    @Binding var canGoForward: Bool
    @Binding var isLoading: Bool
    @Binding var pageTitle: String
    
    // Command triggers
    @Binding var reloadTrigger: Bool
    @Binding var goBackTrigger: Bool
    @Binding var goForwardTrigger: Bool
    @Binding var goHomeTrigger: Bool
    @Binding var pipTrigger: Bool
    @Binding var toggleMusicTrigger: Bool
    @Binding var toggleAudioOnlyTrigger: Bool
    
    func makeCoordinator() -> WebViewCoordinator {
        return WebViewCoordinator(settings: settings)
    }
    
    func makeUIView(context: Context) -> WKWebView {
        let config = WKWebViewConfiguration()
        
        // Critical audio/video configurations for seamless iOS 18 background play & PiP
        config.allowsInlineMediaPlayback = true
        config.mediaTypesRequiringUserActionForPlayback = []
        config.allowsPictureInPictureMediaPlayback = true
        config.suppressesIncrementalRendering = false
        
        // Setup UserContentController and inject scripts & adblock rules
        context.coordinator.configureUserScripts(into: config.userContentController)
        
        let webView = WKWebView(frame: .zero, configuration: config)
        context.coordinator.webView = webView
        
        webView.navigationDelegate = context.coordinator
        webView.uiDelegate = context.coordinator
        webView.scrollView.bounces = true
        webView.allowsBackForwardNavigationGestures = true
        
        // Attach webView to MediaManager for remote controls
        MediaManager.shared.attach(webView: webView)
        
        // Configure User-Agent
        updateUserAgent(for: webView)
        
        // Bind coordinator callbacks
        context.coordinator.onLoadingChange = { loading in
            DispatchQueue.main.async { self.isLoading = loading }
        }
        context.coordinator.onCanGoBackChange = { canBack in
            DispatchQueue.main.async { self.canGoBack = canBack }
        }
        context.coordinator.onCanGoForwardChange = { canForward in
            DispatchQueue.main.async { self.canGoForward = canForward }
        }
        context.coordinator.onTitleChange = { title in
            DispatchQueue.main.async { self.pageTitle = title }
        }
        
        // Load initial YouTube URL
        let initialURLString = settings.isMusicMode ? "https://music.youtube.com" : "https://m.youtube.com"
        let initialURL = URL(string: initialURLString)!
        webView.load(URLRequest(url: initialURL))
        
        return webView
    }
    
    func updateUIView(_ uiView: WKWebView, context: Context) {
        // Handle trigger events
        if reloadTrigger {
            DispatchQueue.main.async { self.reloadTrigger = false }
            uiView.reload()
        }
        if goBackTrigger {
            DispatchQueue.main.async { self.goBackTrigger = false }
            if uiView.canGoBack { uiView.goBack() }
        }
        if goForwardTrigger {
            DispatchQueue.main.async { self.goForwardTrigger = false }
            if uiView.canGoForward { uiView.goForward() }
        }
        if goHomeTrigger {
            DispatchQueue.main.async { self.goHomeTrigger = false }
            let url = settings.isMusicMode ? "https://music.youtube.com" : "https://m.youtube.com"
            uiView.load(URLRequest(url: URL(string: url)!))
        }
        if pipTrigger {
            DispatchQueue.main.async { self.pipTrigger = false }
            uiView.evaluateJavaScript("window.__tubeshield_triggerPiP && window.__tubeshield_triggerPiP();", completionHandler: nil)
        }
        if toggleMusicTrigger {
            DispatchQueue.main.async { self.toggleMusicTrigger = false }
            settings.isMusicMode.toggle()
            let destination = settings.isMusicMode ? "https://music.youtube.com" : "https://m.youtube.com"
            uiView.load(URLRequest(url: URL(string: destination)!))
        }
        if toggleAudioOnlyTrigger {
            DispatchQueue.main.async { self.toggleAudioOnlyTrigger = false }
            settings.isAudioOnlyMode.toggle()
            uiView.evaluateJavaScript("window.__tubeshield_setAudioOnly && window.__tubeshield_setAudioOnly(\(settings.isAudioOnlyMode));", completionHandler: nil)
        }
    }
    
    private func updateUserAgent(for webView: WKWebView) {
        if settings.desktopMode {
            webView.customUserAgent = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.0 Safari/605.1.15"
        } else {
            webView.customUserAgent = "Mozilla/5.0 (iPhone; CPU iPhone OS 18_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.0 Mobile/15E148 Safari/604.1"
        }
    }
}
