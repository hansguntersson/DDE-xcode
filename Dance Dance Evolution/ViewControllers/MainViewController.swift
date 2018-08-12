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
        
        addPaddingToLogo()
    }
    
    func addPaddingToLogo() {
        let padding = CGFloat(10)
        if let paddingView = ResistanceLogo.addPaddingView(top: padding, left: padding, bottom: padding, right: padding) {
            paddingView.backgroundColor = ResistanceLogo.backgroundColor
            paddingView.layer.cornerRadius = 7
        }
        
    }
}
