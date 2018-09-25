//  Created by Cristian Buse on 05/08/2018.
//  Copyright © 2018 Hans Guntersson. All rights reserved.

import UIKit

class HiddenStatusBarController: UIViewController {
    
    class StatusBarOptions {
        var isHidden: Bool = true
        var animation: UIStatusBarAnimation = .none
        var style: UIStatusBarStyle = .lightContent
    }
    
    private var isViewCurrentlyActive: Bool = false
    private let statusBarOptions = StatusBarOptions()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addPanGestures()
        print(name() + " was loaded")
    }
    
    func name() -> String {
        return String(describing: type(of: self))
    }
    
    private func addPanGestures() {
        let topEdgePan = UIScreenEdgePanGestureRecognizer(target: self, action: #selector(screenTopEdgePan))
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
        return isViewCurrentlyActive
    }
    
    override var prefersStatusBarHidden: Bool {
        return statusBarOptions.isHidden
    }
    override var preferredStatusBarUpdateAnimation: UIStatusBarAnimation {
        return statusBarOptions.animation
    }
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return statusBarOptions.style
    }
    override var preferredScreenEdgesDeferringSystemGestures: UIRectEdge {
        return UIRectEdge.top
    }

    @objc func screenTopEdgePan(_ recognizer: UIScreenEdgePanGestureRecognizer) {
        if statusBarOptions.isHidden {
            statusBarOptions.isHidden = false
            statusBarOptions.animation = .slide
            
            self.setNeedsStatusBarAppearanceUpdate()
            hideStatusBar()
        }
    }
    
    private func hideStatusBar() {
        if !statusBarOptions.isHidden {
            statusBarOptions.isHidden = true
            statusBarOptions.animation = .fade
            
            UIView.animate(withDuration: 7
                , animations: {
                    self.setNeedsStatusBarAppearanceUpdate()
                }
            )
        }
    }
    
    deinit {
        print(name() + " was unloaded")
    }
}
