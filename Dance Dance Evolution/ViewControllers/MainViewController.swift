//  Created by Cristian Buse on 05/08/2018.
//  Copyright © 2018 Hans Guntersson. All rights reserved.

import UIKit

class MainViewController: CustomViewController {
    @IBOutlet var resistanceLogo: CustomImageView!
    @IBOutlet var btnResume: UIButton!
    @IBOutlet var btnStart: UIButton!
    @IBOutlet var btnSetup: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addGestures()
        addPaddingToLogo()
        addBorderToButtons()
        
        //btnResume.isHidden = true
    }
    
    private func addGestures() {
        let logoTapGesture = UITapGestureRecognizer(target: self, action: #selector(handleLogoTap))
        resistanceLogo.addGestureRecognizer(logoTapGesture)
    }
    
    private func addPaddingToLogo() {
        let padding = CGFloat(7)
        if let paddingView = resistanceLogo.addPaddingView(top: padding, left: padding, bottom: padding, right: padding) {
            paddingView.backgroundColor = resistanceLogo.backgroundColor
            paddingView.layer.cornerRadius = 10
        }
    }
    
    private func addBorderToButtons() {
        addBorderToButton(button: btnResume, borderWidth: 1.0, borderColor: UIColor.white, cornerRadius: 10.0)
        addBorderToButton(button: btnStart, borderWidth: 1.0, borderColor: UIColor.white, cornerRadius: 10.0)
        addBorderToButton(button: btnSetup, borderWidth: 1.0, borderColor: UIColor.white, cornerRadius: 10.0)
    }
    
    private func addBorderToButton(button: UIButton, borderWidth: CGFloat, borderColor: UIColor, cornerRadius: CGFloat) {
        button.layer.borderWidth = borderWidth
        button.layer.borderColor = borderColor.cgColor
        button.layer.cornerRadius = cornerRadius
        //button.titleLabel?.font = UIFont(name: "System", size: 25.0)
    }
    
    @objc private func handleLogoTap() {
        goToEntryScreen()
    }
    
    private func goToEntryScreen() {
        
    }
    
    @IBAction func setupWasPressed(_ sender: UIButton) {
        goToSetupScreen()
    }
    
    private func goToSetupScreen() {
        performSegue(withIdentifier: "goToSetupScreen", sender: self)
    }
}
