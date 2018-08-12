//
//  EntryViewController.swift
//  Dance Dance Evolution
//
//  Created by Cristian Buse on 05/08/2018.
//  Copyright © 2018 Hans Guntersson. All rights reserved.
//

import UIKit

class EntryViewController: CustomViewController {
    private var isMainScreenAlreadyPresented: Bool = false

    @IBOutlet weak var EntryLogo: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Make sure evertything is positioned as per constraints
        self.view.layoutIfNeeded()
        
        // Add tap gesture to allow user to skip the animation
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        self.view.addGestureRecognizer(tapGesture)
        
        animateLogo()
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    func animateLogo() {
        UIView.animate(withDuration: Settings.getEntryViewDuration()
            , animations: {
                self.EntryLogo.alpha = 0.0
            }
            , completion: { (finished: Bool) in
                if !self.isMainScreenAlreadyPresented {
                    self.goToMainScreen()
                }
            }
        )
    }
    
    @objc func handleTap() {
        isMainScreenAlreadyPresented = true
        goToMainScreen()
    }
    
    func goToMainScreen() {
        performSegue(withIdentifier: "goToMainScreen", sender: self)
    }
}
