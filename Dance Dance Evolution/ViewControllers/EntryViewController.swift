//  Created by Cristian Buse on 05/08/2018.
//  Copyright © 2018 Hans Guntersson. All rights reserved.

import UIKit

class EntryViewController: CustomViewController {
    @IBOutlet var entryLogo: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addTapGestures()
        
        print("EntryScreen was loaded")
    }
    
    private func addTapGestures() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        self.view.addGestureRecognizer(tapGesture)
    }
    
    @objc func handleTap() {
        goToMainScreen()
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
                if self.isViewActive() {
                    self.goToMainScreen()
                }
            }
        )
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        self.entryLogo.alpha = 1.0
    }
    
    func goToMainScreen() {
        performSegue(withIdentifier: "goToMainScreen", sender: self)
    }
    
    deinit {
        print("EntryScreen was de-initialized")
    }
}
