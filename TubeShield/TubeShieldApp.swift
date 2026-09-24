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
            if newPhase == .active {
                configureAudioSession()
            }
        }
    }
    
    private func configureAudioSession() {
        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.playback, mode: .moviePlayback, options: [.allowAirPlay, .allowBluetoothA2DP])
            try session.setActive(true)
        } catch {
            print("Failed to configure AVAudioSession: \(error.localizedDescription)")
        }
    }
}
