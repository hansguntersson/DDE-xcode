//  Created by Cristian Buse on 19/08/2018.
//  Copyright © 2018 Hans Guntersson. All rights reserved.

import UIKit

@IBDesignable
class ResizableSwitch: UISwitch {
    
    @IBInspectable
    var scale : CGFloat = 1 {
        didSet {
            transformScale()
        }
    }
    
    private func transformScale() {
        /*
            After simply scaling (as in CGAffineTransform(scaleX: scale, y: scale) ), the Frame
                changes but the Bounds does not and the content gets centered
            In case we want the content to get aligned in a certain way we also apply a translation
                based on the horizontal and vertical alignment of the control's content at the same
                time with the scaling. The way to do that is by using an affine transformation matrix
        */
        let xOffset = horizontalOffset()
        let yOffset = verticalOffset()
        
        self.transform = CGAffineTransform(a: scale, b: 0, c: 0, d: scale, tx: xOffset, ty: yOffset)
    }
    
    private func horizontalOffset() -> CGFloat {
        let horizontalSign: CGFloat
        
        switch self.contentHorizontalAlignment {
        case .center, .fill:
            horizontalSign = 0
        case .leading, .left:
            horizontalSign = -1
        case .trailing, .right:
            horizontalSign = 1
        }
        
        return frame.width * (1 - scale) / 2 * horizontalSign
    }
    
    private func verticalOffset() -> CGFloat {
        let verticalSign: CGFloat
        
        switch self.contentVerticalAlignment {
        case .center, .fill:
            verticalSign = 0
        case .top:
            verticalSign = -1
        case .bottom:
            verticalSign = 1
        }
        
        return frame.height * (1 - scale) / 2 * verticalSign
    }
}
