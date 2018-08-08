//
//  GameViewController.swift
//  Dance Dance Evolution
//
//  Created by Daniel Harlos on 19/07/2018.
//  Copyright © 2018 Hans Guntersson. All rights reserved.
//

import UIKit
import SpriteKit

class GameViewController: CustomViewController {
    override func viewDidLoad() {
        super.viewDidLoad()

    }

    override var shouldAutorotate: Bool {
        return true
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .allButUpsideDown
        } else {
            return .all
        }
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
}
