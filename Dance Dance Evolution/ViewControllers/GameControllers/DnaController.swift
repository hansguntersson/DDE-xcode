//  Created by Cristian Buse on 03/01/2019.
//  Copyright © 2019 Hans Guntersson. All rights reserved.

import UIKit

class DnaController: UIViewController {
    @IBOutlet var dnaScrollView: DnaScrollView!
    @IBOutlet var dnaMapView: DnaView!
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        let dnaView = dnaScrollView.dnaView!
        dnaView.orientation = .vertical
        dnaView.areMainLettersEnabled = true
        dnaView.arePairLettersEnabled = true
        dnaView.baseTypes = DnaSequence(length: 80).nucleobaseTypesSequence()
        dnaView.isUserInteractionEnabled = true
        
        dnaView.syncMapView = dnaMapView
    }
    @IBAction func btnTap(_ sender: UIButton) {
        dnaScrollView.dnaView.editMode = !dnaScrollView.dnaView.editMode
    }
}
