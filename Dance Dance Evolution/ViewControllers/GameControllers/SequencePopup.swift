//
//  SequencePopup.swift
//  Dance Dance Evolution
//
//  Created by Cristian Buse on 26/06/2019.
//  Copyright © 2019 Hans Guntersson. All rights reserved.
//

import UIKit

class SequencePopup: HiddenStatusBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleAddTap))
        view.addGestureRecognizer(tapGesture)
    }
    
    
    @objc private func handleAddTap() {
        dismiss(animated: false, completion: nil)
    }
    
}
