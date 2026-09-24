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
    
    @State private var showSettings = false
    
    var body: some View {
        ZStack(alignment: .bottom) {
            Color.black.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Loading progress indicator
                if isLoading {
                    ProgressView()
                        .progressViewStyle(LinearProgressViewStyle(tint: .red))
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
                    pipTrigger: $pipTrigger
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
            if settings.isAutoPiPEnabled {
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
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(canGoBack ? .white : .gray.opacity(0.4))
                    .frame(maxWidth: .infinity)
            }
            .disabled(!canGoBack)
            
            // Forward Button
            Button {
                goForwardTrigger = true
            } label: {
                Image(systemName: "chevron.forward")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(canGoForward ? .white : .gray.opacity(0.4))
                    .frame(maxWidth: .infinity)
            }
            .disabled(!canGoForward)
            
            // Home Button
            Button {
                goHomeTrigger = true
            } label: {
                Image(systemName: "house.fill")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
            }
            
            // Picture-in-Picture Button
            Button {
                pipTrigger = true
            } label: {
                Image(systemName: "pip.enter")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.green)
                    .frame(maxWidth: .infinity)
            }
            
            // Reload Button
            Button {
                reloadTrigger = true
            } label: {
                Image(systemName: "arrow.clockwise")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
            }
            
            // Settings Button
            Button {
                showSettings = true
            } label: {
                Image(systemName: "gearshape.fill")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
            }
        }
        .frame(height: 48)
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
