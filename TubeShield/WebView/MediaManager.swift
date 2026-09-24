//
//  MediaManager.swift
//  TubeShield
//
//  Handles iOS Lock Screen & Control Center (MPNowPlayingInfoCenter / MPRemoteCommandCenter)
//

import Foundation
import MediaPlayer
import WebKit

class MediaManager {
    static let shared = MediaManager()
    
    private weak var webView: WKWebView?
    private var currentArtworkUrl: String?
    private var currentArtworkImage: UIImage?
    
    private init() {
        setupRemoteCommands()
    }
    
    func attach(webView: WKWebView) {
        self.webView = webView
    }
    
    // MARK: - Now Playing Info Updates
    
    func updateNowPlaying(
        title: String,
        artist: String,
        artworkUrl: String?,
        duration: Double,
        currentTime: Double,
        isPlaying: Bool
    ) {
        var nowPlayingInfo = [String: Any]()
        
        nowPlayingInfo[MPMediaItemPropertyTitle] = title
        nowPlayingInfo[MPMediaItemPropertyArtist] = artist
        nowPlayingInfo[MPMediaItemPropertyPlaybackDuration] = duration
        nowPlayingInfo[MPNowPlayingInfoPropertyElapsedPlaybackTime] = currentTime
        nowPlayingInfo[MPNowPlayingInfoPropertyPlaybackRate] = isPlaying ? 1.0 : 0.0
        
        // Artwork caching & setting
        if let artworkUrl = artworkUrl, !artworkUrl.isEmpty {
            if artworkUrl == currentArtworkUrl, let cachedImage = currentArtworkImage {
                let artwork = MPMediaItemArtwork(boundsSize: cachedImage.size) { _ in cachedImage }
                nowPlayingInfo[MPMediaItemPropertyArtwork] = artwork
                MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
            } else {
                currentArtworkUrl = artworkUrl
                fetchArtwork(from: artworkUrl) { [weak self] image in
                    guard let self = self, let image = image else { return }
                    self.currentArtworkImage = image
                    var updatedInfo = MPNowPlayingInfoCenter.default().nowPlayingInfo ?? [:]
                    let artwork = MPMediaItemArtwork(boundsSize: image.size) { _ in image }
                    updatedInfo[MPMediaItemPropertyArtwork] = artwork
                    MPNowPlayingInfoCenter.default().nowPlayingInfo = updatedInfo
                }
            }
        }
        
        MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
    }
    
    private func fetchArtwork(from urlString: String, completion: @escaping (UIImage?) -> Void) {
        guard let url = URL(string: urlString) else {
            completion(nil)
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, _, _ in
            if let data = data, let image = UIImage(data: data) {
                DispatchQueue.main.async {
                    completion(image)
                }
            } else {
                DispatchQueue.main.async {
                    completion(nil)
                }
            }
        }.resume()
    }
    
    // MARK: - Remote Control Commands
    
    private func setupRemoteCommands() {
        let commandCenter = MPRemoteCommandCenter.shared()
        
        commandCenter.playCommand.isEnabled = true
        commandCenter.playCommand.addTarget { [weak self] _ in
            self?.executeJS("window.__tubeshield_play && window.__tubeshield_play();")
            return .success
        }
        
        commandCenter.pauseCommand.isEnabled = true
        commandCenter.pauseCommand.addTarget { [weak self] _ in
            self?.executeJS("window.__tubeshield_pause && window.__tubeshield_pause();")
            return .success
        }
        
        commandCenter.togglePlayPauseCommand.isEnabled = true
        commandCenter.togglePlayPauseCommand.addTarget { [weak self] _ in
            self?.executeJS("""
                const v = document.querySelector('video');
                if (v) {
                    if (v.paused) { v.play(); } else { v.pause(); }
                }
            """)
            return .success
        }
        
        commandCenter.skipForwardCommand.isEnabled = true
        commandCenter.skipForwardCommand.preferredIntervals = [10]
        commandCenter.skipForwardCommand.addTarget { [weak self] _ in
            self?.executeJS("window.__tubeshield_skip && window.__tubeshield_skip(10);")
            return .success
        }
        
        commandCenter.skipBackwardCommand.isEnabled = true
        commandCenter.skipBackwardCommand.preferredIntervals = [10]
        commandCenter.skipBackwardCommand.addTarget { [weak self] _ in
            self?.executeJS("window.__tubeshield_skip && window.__tubeshield_skip(-10);")
            return .success
        }
        
        commandCenter.changePlaybackPositionCommand.isEnabled = true
        commandCenter.changePlaybackPositionCommand.addTarget { [weak self] event in
            if let positionEvent = event as? MPChangePlaybackPositionCommandEvent {
                self?.executeJS("window.__tubeshield_seek && window.__tubeshield_seek(\(positionEvent.positionTime));")
                return .success
            }
            return .commandFailed
        }
    }
    
    private func executeJS(_ js: String) {
        DispatchQueue.main.async {
            self.webView?.evaluateJavaScript(js, completionHandler: nil)
        }
    }
}
