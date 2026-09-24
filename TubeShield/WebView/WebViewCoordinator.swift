//
//  WebViewCoordinator.swift
//  TubeShield
//

import Foundation
import WebKit
import Combine

class WebViewCoordinator: NSObject, WKNavigationDelegate, WKUIDelegate, WKScriptMessageHandler {
    weak var webView: WKWebView?
    var settings: AppSettings
    var onTitleChange: ((String) -> Void)?
    var onLoadingChange: ((Bool) -> Void)?
    var onCanGoBackChange: ((Bool) -> Void)?
    var onCanGoForwardChange: ((Bool) -> Void)?
    
    private var cancellables = Set<AnyCancellable>()
    
    init(settings: AppSettings) {
        self.settings = settings
        super.init()
    }
    
    // MARK: - Script Injection Setup
    
    func configureUserScripts(into controller: WKUserContentController) {
        controller.removeAllUserScripts()
        controller.removeScriptMessageHandler(forName: "tubeShieldMedia")
        controller.add(self, name: "tubeShieldMedia")
        
        // 1. Background Play & Visibility Spoofing (Always top priority)
        if settings.isBackgroundPlayEnabled, let bgScript = loadScript(name: "background_play") {
            let userScript = WKUserScript(source: bgScript, injectionTime: .atDocumentStart, forMainFrameOnly: false)
            controller.addUserScript(userScript)
        }
        
        // 2. AdBlock Script
        if settings.isAdBlockEnabled, let adScript = loadScript(name: "adblock") {
            let userScript = WKUserScript(source: adScript, injectionTime: .atDocumentStart, forMainFrameOnly: false)
            controller.addUserScript(userScript)
        }
        
        // 3. SponsorBlock Script
        if settings.isSponsorBlockEnabled, let sponsorScript = loadScript(name: "sponsorblock") {
            let userScript = WKUserScript(source: sponsorScript, injectionTime: .atDocumentEnd, forMainFrameOnly: false)
            controller.addUserScript(userScript)
        }
        
        // 4. PiP Controller Script
        let pipScript = loadScript(name: "pip_controller") ?? ""
        let userScript = WKUserScript(source: pipScript, injectionTime: .atDocumentEnd, forMainFrameOnly: false)
        controller.addUserScript(userScript)
        
        // 5. Load Content Rule List (declarative blocking)
        if settings.isAdBlockEnabled {
            loadContentRuleList(into: controller)
        }
    }
    
    private func loadScript(name: String) -> String? {
        if let path = Bundle.main.path(forResource: name, ofType: "js", inDirectory: "Scripts") {
            return try? String(contentsOfFile: path, encoding: .utf8)
        }
        if let path = Bundle.main.path(forResource: name, ofType: "js") {
            return try? String(contentsOfFile: path, encoding: .utf8)
        }
        return nil
    }
    
    private func loadContentRuleList(into controller: WKUserContentController) {
        guard let path = Bundle.main.path(forResource: "adblock_content_rules", ofType: "json", inDirectory: "Rules") ??
                         Bundle.main.path(forResource: "adblock_content_rules", ofType: "json") else {
            return
        }
        
        guard let jsonString = try? String(contentsOfFile: path, encoding: .utf8) else {
            return
        }
        
        WKContentRuleListStore.default().compileContentRuleList(
            forIdentifier: "TubeShieldAdBlockRules",
            encodedContentRuleList: jsonString
        ) { ruleList, error in
            if let ruleList = ruleList {
                DispatchQueue.main.async {
                    controller.add(ruleList)
                }
            } else if let error = error {
                print("[TubeShield] Content rule compilation failed: \(error)")
            }
        }
    }
    
    // MARK: - WKScriptMessageHandler
    
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        guard message.name == "tubeShieldMedia",
              let dict = message.body as? [String: Any] else { return }
        
        let title = dict["title"] as? String ?? "YouTube"
        let artist = dict["artist"] as? String ?? "YouTube"
        let artworkUrl = dict["artworkUrl"] as? String
        let duration = dict["duration"] as? Double ?? 0
        let currentTime = dict["currentTime"] as? Double ?? 0
        let isPlaying = dict["isPlaying"] as? Bool ?? false
        
        MediaManager.shared.updateNowPlaying(
            title: title,
            artist: artist,
            artworkUrl: artworkUrl,
            duration: duration,
            currentTime: currentTime,
            isPlaying: isPlaying
        )
    }
    
    // MARK: - WKNavigationDelegate
    
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        onLoadingChange?(true)
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        onLoadingChange?(false)
        onCanGoBackChange?(webView.canGoBack)
        onCanGoForwardChange?(webView.canGoForward)
        if let title = webView.title {
            onTitleChange?(title)
        }
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        onLoadingChange?(false)
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        if let url = navigationAction.request.url {
            // Block external scheme redirects (e.g., trying to force open native YouTube App or App Store)
            if url.scheme == "youtube" || url.scheme == "vnd.youtube" {
                decisionHandler(.cancel)
                return
            }
        }
        decisionHandler(.allow)
    }
    
    // MARK: - WKUIDelegate
    
    // Intercept window.open or target="_blank" to stay within TubeShield
    func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
        if navigationAction.targetFrame == nil {
            webView.load(navigationAction.request)
        }
        return nil
    }
}
