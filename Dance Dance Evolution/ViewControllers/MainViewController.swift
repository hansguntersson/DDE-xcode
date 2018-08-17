//
//  MainViewController.swift
//  Dance Dance Evolution
//
//  Created by Cristian Buse on 05/08/2018.
//  Copyright © 2018 Hans Guntersson. All rights reserved.
//

import UIKit

class MainViewController: CustomViewController {

    @IBOutlet weak var resistanceLogo: UIImageView!
    @IBOutlet weak var btnSetup: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addPaddingToLogo()
        let logoTapGesture = UITapGestureRecognizer(target: self, action: #selector(handleLogoTap))
        resistanceLogo.addGestureRecognizer(logoTapGesture)
    }
    
    func addPaddingToLogo() {
        let padding = CGFloat(7)
        if let paddingView = resistanceLogo.addPaddingView(top: padding, left: padding, bottom: padding, right: padding) {
            paddingView.backgroundColor = resistanceLogo.backgroundColor
            paddingView.layer.cornerRadius = 5
        }
        
    }
    
    @IBAction func setupWasPressed(_ sender: UIButton) {
        goToSetupScreen()
    }
    
    @objc func handleLogoTap() {
        
    }
    
    func goToSetupScreen() {
        performSegue(withIdentifier: "goToSetupScreen", sender: self)
    }
}
