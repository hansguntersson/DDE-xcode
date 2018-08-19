//  Created by Cristian Buse on 18/08/2018.
//  Copyright © 2018 Hans Guntersson. All rights reserved.

import UIKit

class CustomImageView: UIImageView {
    private var paddingView: UIView? = nil
    
    func addPaddingView(top: CGFloat, left: CGFloat, bottom: CGFloat, right: CGFloat) -> UIView? {
        guard let superview = self.superview else {
            return nil
        }
        
        // Remove old paddingView if there is one
        paddingView?.removeFromSuperview()
        
        let paddingFrame = CGRect(
            x: self.frame.origin.x - left
            , y: self.frame.origin.y - right
            , width: self.frame.width + left + right
            , height: self.frame.height + top + bottom
        )
        paddingView = UIView(frame: paddingFrame)
        
        superview.addSubview(paddingView!)
        superview.bringSubviewToFront(self)
        
        // Necessary to avoid conflicts because we want the AutoLayout to use only the below 4 constraints
        paddingView!.translatesAutoresizingMaskIntoConstraints = false
        
        // Add constraints
        paddingView!.topAnchor.constraint(equalTo: self.topAnchor, constant: -top).isActive = true
        paddingView!.leftAnchor.constraint(equalTo: self.leftAnchor, constant: -left).isActive = true
        paddingView!.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: bottom).isActive = true
        paddingView!.rightAnchor.constraint(equalTo: self.rightAnchor, constant: right).isActive = true
        
        return paddingView
    }
    
    func getPaddingView() -> UIView? {
        return paddingView
    }
}
