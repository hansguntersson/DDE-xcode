//
//  Extensions.swift
//  Dance Dance Evolution
//
//  Created by Cristian Buse on 12/08/2018.
//  Copyright © 2018 Hans Guntersson. All rights reserved.
//

import UIKit

extension UIView {
    func getPaddingViewTag() -> Int {
        return 0xACEDCAFE
    }

    func addPaddingView(top: CGFloat, left: CGFloat, bottom: CGFloat, right: CGFloat) -> UIView? {
        guard let superview = self.superview else {
            return nil
        }
        
        // Remove old paddingView if there is one
        if let paddingView = self.getPaddingView() {
            paddingView.removeFromSuperview()
        }
        
        let paddingFrame = CGRect(
            x: self.frame.origin.x - left
            , y: self.frame.origin.y - right
            , width: self.frame.width + left + right
            , height: self.frame.height + top + bottom
        )
        let paddingView = UIView(frame: paddingFrame)
        paddingView.tag = self.getPaddingViewTag()
        
        superview.addSubview(paddingView)
        superview.bringSubviewToFront(self)
        
        // Necessary to avoid conflicts that the AutoLayout would encounter
        paddingView.translatesAutoresizingMaskIntoConstraints = false
        
        // Add constraints
        paddingView.topAnchor.constraint(equalTo: self.topAnchor, constant: -top).isActive = true
        paddingView.leftAnchor.constraint(equalTo: self.leftAnchor, constant: -left).isActive = true
        paddingView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: bottom).isActive = true
        paddingView.rightAnchor.constraint(equalTo: self.rightAnchor, constant: right).isActive = true
        
        return paddingView
    }
    
    func getPaddingView() -> UIView? {
        guard let paddingView = self.superview?.viewWithTag(self.getPaddingViewTag()) else {
            return nil
        }
        return paddingView
    }
}
