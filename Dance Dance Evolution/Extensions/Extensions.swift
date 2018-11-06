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

extension UIColor {
    // DNA Nucleobase Colo(u)rs
    static func azure() -> UIColor {return UIColor(red: 76 / 255, green: 86 / 255, blue: 246 / 255, alpha: 1)}
    static func tweetyBird() -> UIColor {return UIColor(red: 231 / 255, green: 229 / 255, blue: 75 / 255, alpha: 1)}
    static func grassGreen() -> UIColor {return UIColor(red: 86 / 255, green: 188 / 255, blue: 55 / 255, alpha: 1)}
    static func carmine() -> UIColor {return UIColor(red: 206 / 255, green: 43 / 255, blue: 30 / 255, alpha: 1)}
    static func fadeGrey() -> UIColor {return UIColor(red: 170 / 255, green: 170 / 255, blue: 170 / 255, alpha: 0.75)}
}

extension UIFont {
    private func withTraits(traits: UIFontDescriptor.SymbolicTraits) -> UIFont {
        let descriptor = fontDescriptor.withSymbolicTraits(traits)
        return UIFont(descriptor: descriptor!, size: 0)
    }
    
    func bold() -> UIFont {
        return withTraits(traits: .traitBold)
    }
    
    func italic() -> UIFont {
        return withTraits(traits: .traitItalic)
    }
}

extension CALayer {
    func addBorder(edge: UIRectEdge, color: UIColor, thickness: CGFloat) {
        let border = CALayer()
        switch edge {
            case .left:
                border.frame = CGRect(x: 0, y: 0, width: thickness, height: frame.height)
            case .right:
                border.frame = CGRect(x: frame.width - thickness, y: 0, width: thickness, height: frame.height)
            case .bottom:
                border.frame = CGRect(x: 0, y: frame.height - thickness, width: frame.width, height: thickness)
            case .top:
                border.frame = CGRect(x: 0, y: 0, width: frame.width, height: thickness)
            default:
                return
        }
        border.backgroundColor = color.cgColor;
        addSublayer(border)
    }
}
