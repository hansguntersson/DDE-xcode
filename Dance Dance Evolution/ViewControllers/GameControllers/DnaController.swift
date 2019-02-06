//  Created by Cristian Buse on 03/01/2019.
//  Copyright © 2019 Hans Guntersson. All rights reserved.

import UIKit

class DnaController: UIViewController {
    @IBOutlet var dnaScrollView: DnaScrollView!
    @IBOutlet var blendLabel: UILabel!
    @IBOutlet var blendStepper: UIStepper!
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        dnaScrollView.dnaView.orientation = .vertical
        dnaScrollView.dnaView.baseTypes = DnaSequence(length: 100).nucleobaseTypesSequence()
        dnaScrollView.dnaView.isUserInteractionEnabled = true
        dnaScrollView.dnaView.editMode = true
    }
    @IBAction func blendHasChanged(_ sender: UIStepper) {
        blendLabel.text = String(Int32(sender.value))
        let blendMode: CGBlendMode = CGBlendMode(rawValue: Int32(sender.value))!
        dnaScrollView.dnaView.blend = blendMode
        dnaScrollView.dnaView.setNeedsDisplay()
    }
}
