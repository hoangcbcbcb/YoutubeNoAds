//
//  SilentAudioPlayer.swift
//  TubeShield
//
//  Plays an inaudible, silent audio loop to prevent iOS from suspending WKWebView in the background
//

import Foundation
import AVFoundation

class SilentAudioPlayer {
    static let shared = SilentAudioPlayer()
    private var audioPlayer: AVAudioPlayer?
    
    private init() {
        setupPlayer()
    }
    
    private func setupPlayer() {
        // Generate a valid, lightweight 1-second silent WAV in memory
        let sampleRate: Int32 = 44100
        let channels: Int16 = 1
        let bitsPerSample: Int16 = 16
        let numSamples: Int32 = sampleRate
        let subChunk2Size: Int32 = numSamples * Int32(channels) * Int32(bitsPerSample / 8)
        let chunkSize: Int32 = 36 + subChunk2Size
        
        var data = Data()
        // RIFF header
        data.append(contentsOf: [0x52, 0x49, 0x46, 0x46]) // "RIFF"
        data.append(contentsOf: withUnsafeBytes(of: chunkSize.littleEndian) { Array($0) })
        data.append(contentsOf: [0x57, 0x41, 0x56, 0x45]) // "WAVE"
        // fmt chunk
        data.append(contentsOf: [0x66, 0x6d, 0x74, 0x20]) // "fmt "
        let subchunk1Size: Int32 = 16
        data.append(contentsOf: withUnsafeBytes(of: subchunk1Size.littleEndian) { Array($0) })
        let audioFormat: Int16 = 1 // PCM
        data.append(contentsOf: withUnsafeBytes(of: audioFormat.littleEndian) { Array($0) })
        data.append(contentsOf: withUnsafeBytes(of: channels.littleEndian) { Array($0) })
        data.append(contentsOf: withUnsafeBytes(of: sampleRate.littleEndian) { Array($0) })
        let byteRate: Int32 = sampleRate * Int32(channels) * Int32(bitsPerSample / 8)
        data.append(contentsOf: withUnsafeBytes(of: byteRate.littleEndian) { Array($0) })
        let blockAlign: Int16 = channels * (bitsPerSample / 8)
        data.append(contentsOf: withUnsafeBytes(of: blockAlign.littleEndian) { Array($0) })
        data.append(contentsOf: withUnsafeBytes(of: bitsPerSample.littleEndian) { Array($0) })
        // data chunk
        data.append(contentsOf: [0x64, 0x61, 0x74, 0x61]) // "data"
        data.append(contentsOf: withUnsafeBytes(of: subChunk2Size.littleEndian) { Array($0) })
        data.append(Data(count: Int(subChunk2Size))) // Zeroed silence
        
        do {
            audioPlayer = try AVAudioPlayer(data: data)
            audioPlayer?.numberOfLoops = -1 // Loop indefinitely
            audioPlayer?.volume = 0.01 // Inaudible
            audioPlayer?.prepareToPlay()
        } catch {
            print("[TubeShield] SilentAudioPlayer initialization failed: \(error.localizedDescription)")
        }
    }
    
    func start() {
        guard let player = audioPlayer, !player.isPlaying else { return }
        player.play()
        print("[TubeShield] Background silent audio keeper active.")
    }
    
    func stop() {
        audioPlayer?.stop()
    }
}
