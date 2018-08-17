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

    @IBOutlet weak var entryLogo: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Add tap gesture to allow user to skip the animation
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        self.view.addGestureRecognizer(tapGesture)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        animateLogo()
    }
    
    func animateLogo() {
        self.view.layoutIfNeeded()
        UIView.animate(withDuration: Settings.getEntryViewDuration()
            , animations: {
                self.entryLogo.alpha = 0.0
                self.view.layoutIfNeeded()
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
        //dismiss(animated: <#T##Bool#>, completion: <#T##(() -> Void)?##(() -> Void)?##() -> Void#>)
        performSegue(withIdentifier: "goToMainScreen", sender: self)
    }
}
