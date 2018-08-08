//
//  MainViewController.swift
//  Dance Dance Evolution
//
//  Created by Cristian Buse on 05/08/2018.
//  Copyright © 2018 Hans Guntersson. All rights reserved.
//

import UIKit

class MainViewController: CustomViewController {

    @IBOutlet weak var ResistanceLogo: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Make sure evertything is positioned as per constraints
        self.view.layoutIfNeeded()
        
        // Replace the image with itself but with insets
        let insetSize = CGFloat(-10)
        let insets = UIEdgeInsets(top: insetSize, left: insetSize, bottom: insetSize, right: insetSize)
        ResistanceLogo.image = ResistanceLogo.image!.withAlignmentRectInsets(insets)
        ResistanceLogo.layer.cornerRadius = 5
 
    }

}
