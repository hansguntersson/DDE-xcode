//  Created by Cristian Buse on 16/09/2018.
//  Copyright © 2018 Hans Guntersson. All rights reserved.

import UIKit

class ArrowView: PaddedImageView {
    // -------------------------------------------------------------------------
    // Mark: - Colors
    // -------------------------------------------------------------------------
    enum FillColor: Int {
        case none = 0
        case hit = 1
        case miss = 2
    }
    private var fillColors: Dictionary<FillColor,UIColor> = [
        FillColor.none: UIColor(red: 0, green: 0, blue: 0, alpha: 0)
        , FillColor.hit: UIColor(red: 51 / 255, green: 153 / 255, blue: 102 / 255, alpha: 1)
        , FillColor.miss: UIColor(red: 204 / 255, green: 0 / 255, blue: 102 / 255, alpha: 1)
    ]

    // -------------------------------------------------------------------------
    // Mark: - Direction
    // -------------------------------------------------------------------------
    enum ArrowDirection: Int {
        case left = 0
        case right = 1
        case up = 2
        case down = 3
    }
    var direction: ArrowDirection = .left {
        didSet {
            switch direction {
                case .left:  break // No need to rotate as default image is already left-oriented
                case .right: self.transform = CGAffineTransform(rotationAngle: CGFloat.pi)
                case .up:    self.transform = CGAffineTransform(rotationAngle: CGFloat.pi / 2)
                case .down:  self.transform = CGAffineTransform(rotationAngle: CGFloat.pi * 1.5)
            }
        }
    }

    // -------------------------------------------------------------------------
    // Mark: - Padding
    // -------------------------------------------------------------------------
    var fillColor: FillColor = .none {
        didSet {
            if paddingView == nil {
                updatePadding()
            }
            paddingView?.backgroundColor = fillColors[fillColor]
        }
    }
    func updatePadding() {
        let padding = CGFloat(frame.width / 10)
        if let paddingView = setPadding(anySide: padding) {
            paddingView.layer.cornerRadius = paddingView.frame.width / 2
        }
    }
    
    // -------------------------------------------------------------------------
    // Mark: - Init
    // -------------------------------------------------------------------------
    convenience init() {
        self.init(frame: CGRect.zero)
    }
    convenience init(direction: ArrowDirection) {
        self.init(frame: CGRect.zero)
        defer {
            self.direction = direction
        }
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
        initImage()
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initImage()
    }
    private func initImage() {
        image = UIImage(named: "LeftArrow")
        if frame.size == CGSize.zero {
            frame.size = image?.size ?? CGSize.zero
        }
        contentMode = .scaleAspectFit
    }
}
