//  Created by Cristian Buse on 19/08/2018.
//  Copyright © 2018 Hans Guntersson. All rights reserved.

import AVFoundation

func appHasLaunched() {
    // Set Audio Session Category to Playback so that Sounds can be played in Silent Mode
    do {
        try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: .mixWithOthers)
    } catch {
        print("Could not set Audio Session to Playback mode!")
    }
    
    
    
    
    
    
}
