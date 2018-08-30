//  Created by Daniel Harlos on 19/07/2018.
//  Copyright © 2018 Hans Guntersson. All rights reserved.

import UIKit

class GameViewController: CustomViewController {
    private var gameMusic150bpm = DDESound(sound: .vShort150bpm)
    private var gameMusic200bpm = DDESound(sound: .vShort200bpm)
    private var mutationSound = DDESound(sound: .mutation)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        print("GameScreen was loaded")
    }
    
    
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        gameMusic150bpm.play(stopIfAlreadyPlaying: false)
    }
    
    
    
    

    @IBAction func goToMainMenu(_ sender: UIButton) {
        dismiss(animated: false, completion: nil)
    }
    
    deinit {
        print("GameScreen was de-initialized")
    }
}
