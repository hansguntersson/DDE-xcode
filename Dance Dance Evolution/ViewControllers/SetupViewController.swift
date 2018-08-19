//  Created by Cristian Buse on 14/08/2018.
//  Copyright © 2018 Hans Guntersson. All rights reserved.

import UIKit

class SetupViewController: CustomViewController {

    @IBOutlet var soundOn: UISwitch!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        soundOn.isOn = Settings.isSoundOn()
    }
    
    
    
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        
        
        
        
    }
    
    @IBAction func soundToggled(_ sender: UISwitch) {
        Settings.setSoundOn(isOn: sender.isOn)
    }
    @IBAction func goBack(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
}
