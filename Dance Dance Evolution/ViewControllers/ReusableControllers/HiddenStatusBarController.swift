//  Created by Cristian Buse on 05/08/2018.
//  Copyright © 2018 Hans Guntersson. All rights reserved.

import UIKit

class HiddenStatusBarController: UIViewController {
    
    private struct StatusBarOptions {
        var isHidden: Bool
        var animation: UIStatusBarAnimation
        var style: UIStatusBarStyle
    }
    
    private(set) var visible: Bool = false
    private var statusBarOptions = StatusBarOptions(isHidden: true, animation: .none, style: .lightContent)
    var name: String {
        return String(describing: type(of: self))
    }
    
    // -------------------------------------------------------------------------
    // Mark: - Loading
    // -------------------------------------------------------------------------
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addPanGestures()
        print(self.name + " was loaded")
    }
    
    // -------------------------------------------------------------------------
    // Mark: - Gestures
    // -------------------------------------------------------------------------
    private var topEdgePan: UIScreenEdgePanGestureRecognizer!
    private func addPanGestures() {
        topEdgePan = UIScreenEdgePanGestureRecognizer(target: self, action: #selector(topEdgePanWasRecognized))
        topEdgePan.edges = UIRectEdge.top
        view.addGestureRecognizer(topEdgePan)
    }
    
    // -------------------------------------------------------------------------
    // Mark: - Visible property
    // -------------------------------------------------------------------------
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        visible = true
    }
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        visible = false
    }

    // -------------------------------------------------------------------------
    // Mark: - Status Bar & Top Edge overrides
    // -------------------------------------------------------------------------
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
    
    // -------------------------------------------------------------------------
    // Mark: - Top Edge Pan
    // -------------------------------------------------------------------------
    @objc func topEdgePanWasRecognized(_ recognizer: UIScreenEdgePanGestureRecognizer) {
        if UIApplication.shared.isStatusBarHidden && recognizer.state == .began {
            // Make sure gesture is disabled
            topEdgePan.isEnabled = false
    
            showStatusBar()
            hideStatusBar()
        }
    }
    private func showStatusBar() {
        statusBarOptions.isHidden = false
        statusBarOptions.animation = .slide
        self.setNeedsStatusBarAppearanceUpdate()
    }
    private func hideStatusBar() {
        if !UIApplication.shared.isStatusBarHidden {
            statusBarOptions.isHidden = true
            statusBarOptions.animation = .fade
            
            UIView.animate(withDuration: 7
                , animations: {[weak self] in
                    self?.setNeedsStatusBarAppearanceUpdate()
                }
                , completion: {[weak self] finished in
                    self?.topEdgePan.isEnabled = true
                }
            )
        }
    }

    // -------------------------------------------------------------------------
    // Mark: - Deconstructor
    // -------------------------------------------------------------------------
    deinit {
        print(self.name + " was unloaded")
    }
}
