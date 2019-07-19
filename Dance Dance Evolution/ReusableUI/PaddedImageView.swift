//  Created by Cristian Buse on 18/08/2018.
//  Copyright © 2018 Hans Guntersson. All rights reserved.

import UIKit

class PaddedImageView: UIImageView {
    private(set) var paddingView: UIView? = nil
    
    override var alpha: CGFloat {
        didSet {
            paddingView?.alpha = alpha
        }
    }
    override var isHidden: Bool {
        didSet {
            paddingView?.isHidden = isHidden
        }
    }
    
    // -------------------------------------------------------------------------
    // Mark: - Constraints between self and paddingView
    // -------------------------------------------------------------------------
    private var topConstraint: NSLayoutConstraint?
    private var leftConstraint: NSLayoutConstraint?
    private var bottomConstraint: NSLayoutConstraint?
    private var rightConstraint: NSLayoutConstraint?
    
    // -------------------------------------------------------------------------
    // Mark: - Set/Remove padding
    // -------------------------------------------------------------------------
    func setPadding(anySide: CGFloat) -> UIView? {
        return self.setPadding(top: anySide, left: anySide, bottom: anySide, right: anySide)
    }
    func setPadding(top: CGFloat, left: CGFloat, bottom: CGFloat, right: CGFloat) -> UIView? {
        if paddingView == nil {
            addPaddingView(top: top, left: left, bottom: bottom, right: right)
        } else {
            topConstraint!.constant = -top
            leftConstraint!.constant = -left
            bottomConstraint!.constant = bottom
            rightConstraint!.constant = right
        }
        return paddingView
    }
    func removePadding() {
        paddingView?.removeFromSuperview()
        paddingView = nil
    }
    
    // -------------------------------------------------------------------------
    // Mark: - Create Padding View
    // -------------------------------------------------------------------------
    private func addPaddingView(top: CGFloat, left: CGFloat, bottom: CGFloat, right: CGFloat) {
        guard let superview = self.superview else {
            return
        }
        let paddingWidth = self.frame.width + left + right
        let paddingHeight = self.frame.height + top + bottom
        let paddingFrame = CGRect(x: 0, y: 0, width: paddingWidth, height: paddingHeight)
        paddingView = UIView(frame: paddingFrame)
        paddingView!.translatesAutoresizingMaskIntoConstraints = false
        superview.addSubview(paddingView!)
        superview.bringSubviewToFront(self)
        
        topConstraint = paddingView!.topAnchor.constraint(equalTo: self.topAnchor, constant: -top)
        leftConstraint = paddingView!.leftAnchor.constraint(equalTo: self.leftAnchor, constant: -left)
        bottomConstraint = paddingView!.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: bottom)
        rightConstraint = paddingView!.rightAnchor.constraint(equalTo: self.rightAnchor, constant: right)
        
        topConstraint!.isActive = true
        leftConstraint!.isActive = true
        bottomConstraint!.isActive = true
        rightConstraint!.isActive = true
    }
}
