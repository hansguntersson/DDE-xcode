//  Created by Cristian Buse on 23/08/2018.
//  Copyright © 2018 Hans Guntersson. All rights reserved.

import UIKit

@IBDesignable
class EdgedLabel: UILabel {
    
    override open func layoutSubviews() {
        super.layoutSubviews()
        setCornerRadiusRatio()
    }
    
    @IBInspectable
    var cornerRadius : CGFloat = 0 {
        didSet {
            self.layer.cornerRadius = cornerRadius
        }
    }
    
    @IBInspectable
    var cornerRadiusRatioToMinSize: CGFloat = 0 {
        didSet {
            setCornerRadiusRatio()
        }
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
            self.layer.borderWidth = borderWidth
        }
    }
    
    @IBInspectable
    var borderColor : UIColor = .clear {
        didSet {
            self.layer.borderColor = borderColor.cgColor
        }
    }
}
