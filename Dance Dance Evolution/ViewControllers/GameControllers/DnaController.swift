//  Created by Cristian Buse on 03/01/2019.
//  Copyright © 2019 Hans Guntersson. All rights reserved.

import UIKit

class DnaController: HiddenStatusBarController {
    @IBOutlet var dnaScrollView: DnaScrollView!
    @IBOutlet var dnaMapScrollView: DnaScrollView!
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        let dnaView = dnaScrollView.dnaView!
        dnaView.isDrawingEnabled = false
        dnaView.areMainLettersEnabled = true
        dnaView.arePairLettersEnabled = true
        dnaView.baseTypes = DnaSequence(length: 60).nucleobaseTypesSequence()
        dnaView.startOffsetSegments = 3
        dnaView.endOffsetSegments = 4
        dnaView.isUserInteractionEnabled = true
        dnaView.autoOrientation = .device
        
        let dnaMap = dnaMapScrollView.dnaView!
        dnaView.syncMapView = dnaMap
        dnaMap.helixOrientation = .vertical
        dnaView.isDrawingEnabled = true
    }
    @IBAction func btnTap(_ sender: UIButton) {
        dnaScrollView.dnaView.editMode = !dnaScrollView.dnaView.editMode
    }
    @IBAction func dismissView(_ sender: UIButton) {
        dismiss(animated: false, completion: nil)
    }
    @IBAction func testBtn(_ sender: UIButton) {
        dnaScrollView.scrollToBottom()
    }
}
