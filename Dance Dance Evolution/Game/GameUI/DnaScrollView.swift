//  Created by Cristian Buse on 19/01/2019.
//  Copyright © 2019 Hans Guntersson. All rights reserved.
import UIKit

class DnaScrollView: UIScrollView {
    // The subview that handles all the drawing
    public var dnaView: DnaView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initDnaView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initDnaView()
    }
    
    // -------------------------------------------------------------------------
    // Mark: - Subview and AutoLayout
    // -------------------------------------------------------------------------
    private func initDnaView() {
        dnaView = DnaView()
        dnaView.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(dnaView)
        dnaView.backgroundColor = self.backgroundColor
        
        // AutoLayout Constraints
        dnaView.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 0).isActive = true
        dnaView.rightAnchor.constraint(equalTo: self.rightAnchor, constant: 0).isActive = true
        dnaView.topAnchor.constraint(equalTo: self.topAnchor, constant: 0).isActive = true
        dnaView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: 0).isActive = true
        dnaView.widthAnchor.constraint(greaterThanOrEqualTo: self.widthAnchor, constant: 0).isActive = true
        dnaView.heightAnchor.constraint(greaterThanOrEqualTo: self.heightAnchor, constant: 0).isActive = true
        
        delegate = dnaView
    }
    
    // -------------------------------------------------------------------------
    // Mark: - Scroll
    // -------------------------------------------------------------------------
    func scrollToBottom() {
        if self.dnaView.helixOrientation == .horizontal {
            scrollRectToVisible(CGRect(x: self.dnaView.height - 1, y: 0, width: 1, height: 1), animated: false)
        } else {
            scrollRectToVisible(CGRect(x: 0, y: self.dnaView.height - 1, width: 1, height: 1), animated: false)
        }
    }
    func scrollToTop() {
        scrollRectToVisible(CGRect(x: 0, y: 0, width: 1, height: 1), animated: false)
    }
}
