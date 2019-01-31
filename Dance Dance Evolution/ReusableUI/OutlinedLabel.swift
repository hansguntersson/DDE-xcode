//  Created by Cristian Buse on 06/11/2018.
//  Copyright © 2018 Hans Guntersson. All rights reserved.

import UIKit

@IBDesignable
class OutlinedLabel: UILabel {
    @IBInspectable
    var outlineColor: UIColor = .clear {
        didSet {
            updateAttributedText()
        }
    }
    
    @IBInspectable
    var outlineWidth: CGFloat = 0.0 {
        didSet {
            updateAttributedText()
        }
    }

    private func updateAttributedText() {
        if text != nil {
            let strokeTextAttributes: [NSAttributedString.Key : Any] = [
                NSAttributedString.Key.strokeColor : outlineColor,
                NSAttributedString.Key.strokeWidth : outlineWidth,
            ]
            self.attributedText = NSMutableAttributedString(string: self.text!, attributes: strokeTextAttributes)
        }
    }
}
