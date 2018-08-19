//  Created by Cristian Buse on 05/08/2018.
//  Copyright © 2018 Hans Guntersson. All rights reserved.

import UIKit

class CustomViewController: UIViewController {
    private var isViewCurrentlyActive: Bool = false
    private var isStatusBarHidden: Bool = true
    private var statusBarAnimation: UIStatusBarAnimation = UIStatusBarAnimation.slide
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let topEdgePan = UIScreenEdgePanGestureRecognizer(target: self, action: #selector(screenEdgePan))
        topEdgePan.edges = UIRectEdge.top
        view.addGestureRecognizer(topEdgePan)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        isViewCurrentlyActive = true
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        isViewCurrentlyActive = false
    }
    
    func isViewActive() -> Bool {
        return self.isViewCurrentlyActive
    }
    
    override var prefersStatusBarHidden: Bool {
        return self.isStatusBarHidden
    }
    override var preferredStatusBarUpdateAnimation: UIStatusBarAnimation {
        return self.statusBarAnimation
    }
    override var preferredScreenEdgesDeferringSystemGestures: UIRectEdge {
        return UIRectEdge.top
    }
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return UIStatusBarStyle.lightContent
    }
    
    @objc func screenEdgePan(_ recognizer: UIScreenEdgePanGestureRecognizer) {
        if self.isStatusBarHidden {
            self.isStatusBarHidden = false
            self.statusBarAnimation = UIStatusBarAnimation.slide
            UIView.animate(withDuration: 0.4
               , animations: {
                    self.setNeedsStatusBarAppearanceUpdate()
                    self.view.layoutIfNeeded()
                }
                , completion: { (finished: Bool) in
                    self.setStatusBarOff()
                }
            )
        }
    }
    
    private func setStatusBarOff() {
        self.isStatusBarHidden = true
        self.statusBarAnimation = UIStatusBarAnimation.fade
        UIView.animate(withDuration: 7
            , animations: {
                self.setNeedsStatusBarAppearanceUpdate()
                self.view.layoutIfNeeded()
            }
        )
    }
}
