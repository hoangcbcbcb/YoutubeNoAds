//
//  AppSettings.swift
//  TubeShield
//

import Foundation
import Combine

class AppSettings: ObservableObject {
    static let shared = AppSettings()
    
    @Published var isAdBlockEnabled: Bool {
        didSet { UserDefaults.standard.set(isAdBlockEnabled, forKey: "isAdBlockEnabled") }
    }
    
    @Published var isSponsorBlockEnabled: Bool {
        didSet { UserDefaults.standard.set(isSponsorBlockEnabled, forKey: "isSponsorBlockEnabled") }
    }
    
    @Published var isBackgroundPlayEnabled: Bool {
        didSet { UserDefaults.standard.set(isBackgroundPlayEnabled, forKey: "isBackgroundPlayEnabled") }
    }
    
    @Published var isAutoPiPEnabled: Bool {
        didSet { UserDefaults.standard.set(isAutoPiPEnabled, forKey: "isAutoPiPEnabled") }
    }
    
    @Published var desktopMode: Bool {
        didSet { UserDefaults.standard.set(desktopMode, forKey: "desktopMode") }
    }
    
    @Published var isAudioOnlyMode: Bool {
        didSet { UserDefaults.standard.set(isAudioOnlyMode, forKey: "isAudioOnlyMode") }
    }
    
    @Published var isMusicMode: Bool {
        didSet { UserDefaults.standard.set(isMusicMode, forKey: "isMusicMode") }
    }
    
    init() {
        // Defaults: Everything enabled for the best YouTube experience
        if UserDefaults.standard.object(forKey: "isAdBlockEnabled") == nil {
            self.isAdBlockEnabled = true
        } else {
            self.isAdBlockEnabled = UserDefaults.standard.bool(forKey: "isAdBlockEnabled")
        }
        
        if UserDefaults.standard.object(forKey: "isSponsorBlockEnabled") == nil {
            self.isSponsorBlockEnabled = true
        } else {
            self.isSponsorBlockEnabled = UserDefaults.standard.bool(forKey: "isSponsorBlockEnabled")
        }
        
        if UserDefaults.standard.object(forKey: "isBackgroundPlayEnabled") == nil {
            self.isBackgroundPlayEnabled = true
        } else {
            self.isBackgroundPlayEnabled = UserDefaults.standard.bool(forKey: "isBackgroundPlayEnabled")
        }
        
        if UserDefaults.standard.object(forKey: "isAutoPiPEnabled") == nil {
            self.isAutoPiPEnabled = false
        } else {
            self.isAutoPiPEnabled = UserDefaults.standard.bool(forKey: "isAutoPiPEnabled")
        }
        
        self.desktopMode = UserDefaults.standard.bool(forKey: "desktopMode")
        self.isAudioOnlyMode = UserDefaults.standard.bool(forKey: "isAudioOnlyMode")
        self.isMusicMode = UserDefaults.standard.bool(forKey: "isMusicMode")
    }
}
