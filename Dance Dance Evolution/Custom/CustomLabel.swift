//  Created by Cristian Buse on 23/08/2018.
//  Copyright © 2018 Hans Guntersson. All rights reserved.
//

import UIKit

@IBDesignable
class CustomLabel: UILabel {
    
    @IBInspectable
    var cornerRadius : CGFloat = 0 {
        didSet {
            setCornerRadius()
        }
    }
    
    private func setCornerRadius() {
        self.layer.cornerRadius = cornerRadius
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
    
    
    
    
}
