//  Created by Daniel Harlos on 19/07/2018.
//  Copyright © 2018 Hans Guntersson. All rights reserved.

import UIKit

class GameViewController: CustomViewController {
    private var gameSound150bpm: DDESound?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        gameSound150bpm = DDESound(sound: .vShort150bpm)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if Settings.isSoundOn() {
            gameSound150bpm?.playSound(stopIfAlreadyPlaying: false)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        gameSound150bpm = nil
    }
}
