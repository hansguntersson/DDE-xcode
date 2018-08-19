//  Created by Cristian Buse on 17/08/2018.
//  Copyright © 2018 Hans Guntersson. All rights reserved.

import AVFoundation

class DDESound {
    enum Sound {
        case areYouReady
        case vShort150bpm
        case vShort200bpm
        case highFidelity
        case hyperMutator
        case mutation
    }
    
    private var audioPlayer = AVAudioPlayer()
    private var isPlayerSet: Bool = false
    
    init(sound: Sound) {
        if let soundURL = getSoundURL(sound: sound) {
            do {
                audioPlayer = try AVAudioPlayer(contentsOf: soundURL)
                isPlayerSet = true
                audioPlayer.prepareToPlay()
            } catch {
                isPlayerSet = false
                print("Cannot get contents of sound /(sound)")
            }
        }
    }
    
    func playSound(stopIfAlreadyPlaying: Bool) {
        if isPlayerSet {
            if stopIfAlreadyPlaying {
                
                // not sure yet if this is relevant
            }
            audioPlayer.play()
        }
    }
    
    private func getSoundURL(sound: Sound) -> URL? {
        let soundName: String
        let soundType: String
        let parentFolder: String = "audio/"
        
        switch sound {
        case .areYouReady:
            soundName = parentFolder + "areyouready"
            soundType = "mp3"
        case .vShort150bpm:
            soundName = parentFolder + "dd_evo_vshort_150bpm"
            soundType = "mp3"
        case .vShort200bpm:
            soundName = parentFolder + "ddevo_vshort_200bpm"
            soundType = "mp3"
        case .highFidelity:
            soundName = parentFolder + "highfidelity"
            soundType = "mp3"
        case .hyperMutator:
            soundName = parentFolder + "hypermutator"
            soundType = "mp3"
        case .mutation:
            soundName = parentFolder + "mutation"
            soundType = "mp3"
        }
        
        if let soundPath: String = Bundle.main.path(forResource: soundName, ofType: soundType) {
            return URL.init(fileURLWithPath: soundPath)
        } else {
            return nil
        }
    }
}
