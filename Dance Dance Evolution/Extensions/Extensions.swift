//  Created by Cristian Buse on 04/09/2018.
//  Copyright © 2018 Hans Guntersson. All rights reserved.

import UIKit

extension Double {
    func toPercentString(decimalPlaces decimals:Int) -> String {
        return String(format: "%.\(decimals < 0 ? 0 : decimals)f%%", self * 100)
    }
}

extension Float {
    func toPercentString(decimalPlaces decimals:Int) -> String {
        return String(format: "%.\(decimals < 0 ? 0 : decimals)f%%", self * 100)
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

extension Date {
    func toString(format: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        return dateFormatter.string(from: self)
    }
}

extension Comparable {
    func clamped(to limits: ClosedRange<Self>) -> Self {
        return min(max(self, limits.lowerBound), limits.upperBound)
    }
}

extension UIGestureRecognizer {
    enum GestureType {
        case tap
        case pinch
        case rotation
        case swipe
        case pan
        case screenEdgePan
        case longPress
        case other
    }
    
    func type() -> GestureType {
        switch self {
            case is UITapGestureRecognizer:
                return .tap
            case is UIPinchGestureRecognizer:
                return .pinch
            case is UIRotationGestureRecognizer:
                return .rotation
            case is UISwipeGestureRecognizer:
                return .swipe
            case is UIPanGestureRecognizer:
                return .pan
            case is UIScreenEdgePanGestureRecognizer:
                return .screenEdgePan
            case is UILongPressGestureRecognizer:
                return .longPress
            default:
                return .other
        }
    }
}
