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
        dnaView.baseTypes = DnaSequence(length: 30).nucleobaseTypesSequence()
        dnaView.isUserInteractionEnabled = true
        
        dnaView.syncMapView = dnaMapView
        
        
        
    }
    @IBAction func btnTap(_ sender: UIButton) {
        dnaScrollView.dnaView.editMode = !dnaScrollView.dnaView.editMode
    }
    @IBAction func dismissView(_ sender: UIButton) {
        dismiss(animated: false, completion: nil)
    }
    @IBAction func testBtn(_ sender: UIButton) {
        print(dnaScrollView.dnaView.height)
        dnaScrollView.scrollRectToVisible(CGRect(x: 0, y: dnaScrollView.dnaView.height-1, width: 1, height: 1), animated: false)
    }
}
