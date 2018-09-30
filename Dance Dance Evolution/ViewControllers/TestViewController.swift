//
//  TestViewController.swift
//  Dance Dance Evolution
//
//  Created by Cristian Buse on 30/09/2018.
//  Copyright © 2018 Hans Guntersson. All rights reserved.
//

import UIKit

class TestViewController: HiddenStatusBarController {
    @IBOutlet var scroll: DNASequenceScrollView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        scroll.setSequence(dnaSequence: DnaSequence(length: 60))
    }
    
    @IBAction func goBack(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
}
