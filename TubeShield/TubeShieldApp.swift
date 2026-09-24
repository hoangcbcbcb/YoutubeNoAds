//
//  TubeShieldApp.swift
//  TubeShield
//
//  Created for iOS 18 - YouTube AdBlocker, Background Play, SponsorBlock & PiP
//

import SwiftUI
import AVFoundation

@main
struct TubeShieldApp: App {
    @StateObject private var settings = AppSettings.shared
    @Environment(\.scenePhase) private var scenePhase
    
    init() {
        configureAudioSession()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(settings)
                .preferredColorScheme(.dark)
                .onAppear {
                    configureAudioSession()
                }
        }
        .onChange(of: scenePhase) { newPhase in
            if newPhase == .background || newPhase == .inactive {
                // Ensure audio session and silent keeper remain active when user locks screen
                configureAudioSession()
            }
        }
    }
    
    private func configureAudioSession() {
        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.playback, mode: .default, options: [.mixWithOthers, .allowAirPlay, .allowBluetoothA2DP])
            try session.setActive(true)
            SilentAudioPlayer.shared.start()
        } catch {
            print("Failed to configure AVAudioSession: \(error.localizedDescription)")
        }
    }
}
