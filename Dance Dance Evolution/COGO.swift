//  Created by Cristian Buse on 13/01/2019.
//  Copyright © 2019 Hans Guntersson. All rights reserved.

import UIKit

class COGO {
    public static func interpolate2D(x: CGFloat, x1: CGFloat, y1: CGFloat, x2: CGFloat, y2: CGFloat) -> CGFloat? {
        if x1 != x2 {
            return (x - x1) / (x2 - x1) * (y2 - y1) + y1
        } else {
            return nil
        }
    }
    
    public static func scale(value: CGFloat, domain: ClosedRange<CGFloat>, range: ClosedRange<CGFloat>) -> CGFloat? {
        return COGO.interpolate2D(x: value, x1: domain.lowerBound, y1: range.lowerBound, x2: domain.upperBound, y2: range.upperBound)
    }
    
    public static func azimuth(x1: CGFloat, y1: CGFloat, x2: CGFloat, y2: CGFloat) -> CGFloat? {
        if x1 == x2 && y1 == y2 {
            // The 2 points are identical and do not describe a line
            return nil
        }
        let dX = x2 - x1
        let dY = y2 - y1
        if dY > 0 {
            return atan(dX / dY)
        } else if dY < 0 {
            return atan(dX / dY) + CGFloat.pi * sign(value: dX, zeroAsOne: true)
        } else {
            return CGFloat.pi / 2 * sign(value: dX, zeroAsOne: false)
        }
    }

    public static func sign(value: CGFloat, zeroAsOne: Bool) -> CGFloat {
        switch value.sign {
            case .minus:
                return -1
            case .plus:
                if zeroAsOne && value == 0 {
                    return 0
                } else {
                    return 1
                }
        }
    }
}

