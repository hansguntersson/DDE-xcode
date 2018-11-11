//  Created by Cristian Buse on 17/08/2018.
//  Copyright © 2018 Hans Guntersson. All rights reserved.

import AVFoundation

class DDESound {
    private let parentFolder: String = "audio/"
    private let _sound: Sound
    
    enum Sound: String {
        case areYouReady = "areyouready"
        case vShort150bpm = "dd_evo_vshort_150bpm"
        case vShort200bpm = "ddevo_vshort_200bpm"
        case highFidelity = "highfidelity"
        case hyperMutator = "hypermutator"
        case mutation = "mutation"
    }
    
    private var audioPlayer: AVAudioPlayer?
    
    init(sound: Sound) {
        _sound = sound
        if let soundURL = getSoundURL(sound: sound) {
            do {
                audioPlayer = try AVAudioPlayer(contentsOf: soundURL)
                audioPlayer!.prepareToPlay()
            } catch {
                print("Cannot get contents of sound \(sound)")
            }
        }
    }
    
    func play() {
        if Settings.isSoundOn {
            audioPlayer?.play()
        }
    }
    
    func pause() {
        if Settings.isSoundOn {
            audioPlayer?.pause()
        }
    }
    
    func stop() {
        if Settings.isSoundOn {
            audioPlayer?.stop()
        }
    }
    
    private func getSoundURL(sound: Sound) -> URL? {
        let soundType: String = "mp3" // must switch sound if different
        
        if let soundPath: String = Bundle.main.path(forResource: parentFolder + sound.rawValue, ofType: soundType) {
            return URL.init(fileURLWithPath: soundPath)
        } else {
            return nil
        }
    }
    
    deinit {
        print("Sound \(_sound) was unloaded")
    }
}
