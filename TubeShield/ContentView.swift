//
//  ContentView.swift
//  TubeShield
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var settings: AppSettings
    
    @State private var canGoBack = false
    @State private var canGoForward = false
    @State private var isLoading = false
    @State private var pageTitle = ""
    
    // Command Triggers
    @State private var reloadTrigger = false
    @State private var goBackTrigger = false
    @State private var goForwardTrigger = false
    @State private var goHomeTrigger = false
    @State private var pipTrigger = false
    @State private var toggleMusicTrigger = false
    @State private var toggleAudioOnlyTrigger = false
    
    @State private var showSettings = false
    
    var body: some View {
        ZStack(alignment: .bottom) {
            Color.black.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Audio-Only Status Banner
                if settings.isAudioOnlyMode {
                    HStack {
                        Image(systemName: "headphones")
                            .foregroundColor(.cyan)
                        Text("Chế độ chỉ nghe nhạc (Tiết kiệm 90% pin & 4G)")
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(.cyan)
                        Spacer()
                        Button("Tắt") {
                            toggleAudioOnlyTrigger = true
                        }
                        .font(.caption2)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(Color.cyan.opacity(0.2))
                        .foregroundColor(.white)
                        .cornerRadius(10)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color.black.opacity(0.85))
                }
                
                // Loading progress indicator
                if isLoading {
                    ProgressView()
                        .progressViewStyle(LinearProgressViewStyle(tint: settings.isMusicMode ? .pink : .red))
                        .frame(height: 2)
                }
                
                // Embedded YouTube WebView
                YouTubeWebView(
                    settings: settings,
                    canGoBack: $canGoBack,
                    canGoForward: $canGoForward,
                    isLoading: $isLoading,
                    pageTitle: $pageTitle,
                    reloadTrigger: $reloadTrigger,
                    goBackTrigger: $goBackTrigger,
                    goForwardTrigger: $goForwardTrigger,
                    goHomeTrigger: $goHomeTrigger,
                    pipTrigger: $pipTrigger,
                    toggleMusicTrigger: $toggleMusicTrigger,
                    toggleAudioOnlyTrigger: $toggleAudioOnlyTrigger
                )
                .edgesIgnoringSafeArea([.top, .horizontal])
                
                // Bottom Control Bar
                bottomBar
            }
        }
        .sheet(isPresented: $showSettings) {
            SettingsView()
                .environmentObject(settings)
        }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.willResignActiveNotification)) { _ in
            if settings.isAutoPiPEnabled && !settings.isAudioOnlyMode {
                pipTrigger = true
            }
        }
    }
    
    // MARK: - Modern iOS 18 Bottom Toolbar
    private var bottomBar: some View {
        HStack(spacing: 0) {
            // Back Button
            Button {
                goBackTrigger = true
            } label: {
                Image(systemName: "chevron.backward")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(canGoBack ? .white : .gray.opacity(0.4))
                    .frame(maxWidth: .infinity)
            }
            .disabled(!canGoBack)
            
            // Forward Button
            Button {
                goForwardTrigger = true
            } label: {
                Image(systemName: "chevron.forward")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(canGoForward ? .white : .gray.opacity(0.4))
                    .frame(maxWidth: .infinity)
            }
            .disabled(!canGoForward)
            
            // Home Button
            Button {
                goHomeTrigger = true
            } label: {
                Image(systemName: "house.fill")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
            }
            
            // YouTube Music Switcher Button (Red/Pink when active)
            Button {
                toggleMusicTrigger = true
            } label: {
                VStack(spacing: 1) {
                    Image(systemName: "music.note")
                        .font(.system(size: 17, weight: .semibold))
                    Text(settings.isMusicMode ? "Music" : "Video")
                        .font(.system(size: 9, weight: .bold))
                }
                .foregroundColor(settings.isMusicMode ? .pink : .gray)
                .frame(maxWidth: .infinity)
            }
            
            // Audio-Only (Music Mode) Toggle Button (Cyan when active)
            Button {
                toggleAudioOnlyTrigger = true
            } label: {
                VStack(spacing: 1) {
                    Image(systemName: settings.isAudioOnlyMode ? "headphones" : "headphones")
                        .font(.system(size: 17, weight: .semibold))
                    Text("Only Audio")
                        .font(.system(size: 9, weight: .bold))
                }
                .foregroundColor(settings.isAudioOnlyMode ? .cyan : .gray)
                .frame(maxWidth: .infinity)
            }
            
            // Picture-in-Picture Button
            Button {
                pipTrigger = true
            } label: {
                Image(systemName: "pip.enter")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(.green)
                    .frame(maxWidth: .infinity)
            }
            
            // Settings Button
            Button {
                showSettings = true
            } label: {
                Image(systemName: "gearshape.fill")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
            }
        }
        .frame(height: 50)
        .background(
            Rectangle()
                .fill(.ultraThinMaterial)
                .overlay(
                    Divider()
                        .background(Color.white.opacity(0.1)),
                    alignment: .top
                )
        )
    }
}
