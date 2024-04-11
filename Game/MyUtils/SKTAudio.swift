//
//  SKTAudio.swift
//  Game
//
//  Created by Nitrotech Asia on 11/04/2024.
//

import AVFoundation
import SpriteKit

class SKTAudio {
    var bgMusic: AVAudioPlayer?
    var soundEffect: AVAudioPlayer?

    static func shared() -> SKTAudio {
        return SKTAudio()
    }

    static let keyMusic = "keyMusic"
    static let keyEffect = "keyEffect"
    static var effectEnable: Bool {
        get {
            return UserDefaults.standard.bool(forKey: keyEffect)
        }

        set {
            UserDefaults.standard.set(newValue, forKey: keyEffect)
            if !newValue {
                SKAction.stop()
            }
        }
    }

    static var musicEnable: Bool {
        get {
            return UserDefaults.standard.bool(forKey: keyMusic)
        }

        set {
            UserDefaults.standard.set(newValue, forKey: keyMusic)
            if !newValue {
                SKTAudio.shared().stopBgMusic()
            }
        }
    }

    func playMusic(_ fileName: String) {
        if !SKTAudio.musicEnable { return }
        guard let url = Bundle.main.url(forResource: fileName, withExtension: nil) else { return }
        
        do {
            bgMusic = try AVAudioPlayer(contentsOf: url)
        } catch let error as NSError {
            print("💧💧💧💧💧💧" + error.localizedDescription)
            bgMusic = nil
        }

        if let bgMusic {
            bgMusic.numberOfLoops = -1
            bgMusic.prepareToPlay()
            bgMusic.play()
        }
    }

    func playSoundEffect(_ fileName: String) {
        guard let url = Bundle.main.url(forResource: fileName, withExtension: nil) else { return }
        
        do {
            soundEffect = try AVAudioPlayer(contentsOf: url)
        } catch let error as NSError {
            print(error.localizedDescription)
            soundEffect = nil
        }
        if let soundEffect {
            soundEffect.numberOfLoops = 0
            soundEffect.prepareToPlay()
            soundEffect.play()
        }
    }

    func stopBgMusic() {
        if let bgMusic, bgMusic.isPlaying {
            bgMusic.stop()
        }
    }

    func pauseBgMusic() {
        if let bgMusic, bgMusic.isPlaying {
            bgMusic.pause()
        }
    }

    func resumeBgMusic() {
        if let bgMusic, !bgMusic.isPlaying {
            bgMusic.play()
        }
    }
}

extension SKAction {
    class func playSoundFileName(_ fileName: String) -> SKAction {
        if !SKTAudio.effectEnable { return SKAction() }
        return SKAction.playSoundFileNamed(fileName, waitForCompletion: false)
    }
}


