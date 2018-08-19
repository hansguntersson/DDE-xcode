//  Created by Cristian Buse on 19/08/2018.
//  Copyright © 2018 Hans Guntersson. All rights reserved.

import UIKit

@IBDesignable
class CustomSwitch: UISwitch {
    
    @IBInspectable
    var scale : CGFloat = 1 {
        didSet {
            transformScale()
        }
    }
    
    private func transformScale() {
        self.transform = CGAffineTransform(scaleX: scale, y: scale)
    }
}
