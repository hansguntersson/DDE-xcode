//  Created by Cristian Buse on 04/09/2018.
//  Copyright © 2018 Hans Guntersson. All rights reserved.

import UIKit

extension Double {
    func toPercentString(decimalPlaces decimals:Int) -> String {
        return String(format: "%.\(decimals < 0 ? 0 : decimals)f%%", self * 100)
    }
}

extension UIView {
    
    func absoluteCenter() -> CGPoint {
        let origin = absoluteOrigin(view: self)
        return CGPoint(
            x: center.x - self.frame.origin.x + origin.x
            , y: center.y - self.frame.origin.y + origin.y
        )
    }
    
    private func absoluteOrigin(view: UIView) -> CGPoint {
        if let parentView = view.superview {
            let origin = absoluteOrigin(view: parentView)
            return CGPoint(
                x: view.frame.origin.x + origin.x
                , y: view.frame.origin.y + origin.y
            )
        } else {
            return view.frame.origin
        }
    }
}
