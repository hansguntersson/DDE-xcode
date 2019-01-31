//  Created by Cristian Buse on 23/08/2018.
//  Copyright © 2018 Hans Guntersson. All rights reserved.

import UIKit

@IBDesignable
class EdgedLabel: UILabel {
    
    @IBInspectable
    var cornerRadius : CGFloat = 0 {
        didSet {
            setCornerRadius()
        }
    }
    
    @IBInspectable
    var cornerRadiusRatioToMinSize: CGFloat = 0 {
        didSet {
            setCornerRadiusRatio()
        }
    }
    
    private func setCornerRadius() {
        self.layer.cornerRadius = cornerRadius
    }
    
    private func setCornerRadiusRatio() {
        if cornerRadiusRatioToMinSize > 0 {
            let minSize = (frame.width > frame.height ? frame.height : frame.width)
            cornerRadius = cornerRadiusRatioToMinSize * minSize
        }
    }
    
    @IBInspectable
    var borderWidth : CGFloat = 0 {
        didSet {
            setBorderWidth()
        }
    }
    
    private func setBorderWidth() {
        self.layer.borderWidth = borderWidth
    }
    
    @IBInspectable
    var borderColor : UIColor = .clear {
        didSet {
            setBorderColor()
        }
    }
    
    private func setBorderColor() {
        self.layer.borderColor = borderColor.cgColor
    }
    
    override open func layoutSubviews() {
        super.layoutSubviews()
        
        setCornerRadiusRatio()
    }
}
