//  Created by Cristian Buse on 16/09/2018.
//  Copyright © 2018 Hans Guntersson. All rights reserved.

import UIKit

class ArrowView: PaddedImageView {
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
    
    enum ArrowDirection: Int {
        case left = 0
        case right = 1
        case up = 2
        case down = 3
    }
    
    var direction: ArrowDirection = .left {
        didSet {
            switch direction {
            case .left:
                // No need to rotate as default image is already left-oriented
                break
            case .right:
                self.transform = CGAffineTransform(rotationAngle: CGFloat.pi)
            case .up:
                self.transform = CGAffineTransform(rotationAngle: CGFloat.pi / 2)
            case .down:
                self.transform = CGAffineTransform(rotationAngle: CGFloat.pi * 1.5)
            }
        }
    }
    
    override var center: CGPoint {
        didSet {
            let padding = CGFloat(frame.width / 10)
            if let paddingView = setPadding(anySide: padding) {
                paddingView.layer.cornerRadius = paddingView.frame.width / 2
                paddingView.center = center
            }
        }
    }
    
    override var alpha: CGFloat {
        didSet {
            paddingView?.alpha = alpha
        }
    }
    
    override var isHidden: Bool {
        didSet {
            paddingView?.isHidden = isHidden
        }
    }
    
    var fillColor: FillColor = .none {
        didSet {
            if paddingView != nil {
                let newColor = fillColors[fillColor]
                if paddingView!.backgroundColor != newColor {
                    paddingView!.backgroundColor = newColor
                }
            }
        }
    }
    
    // In order to be able to create an instance without passing an actual frame
    convenience init() {
        self.init(frame: CGRect.zero)
    }
    
    // In order to be able to create an instance without passing an actual frame and also to set direction
    convenience init(direction: ArrowDirection) {
        self.init(frame: CGRect.zero)
        defer {
            self.direction = direction
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initArrow()
    }
    
    // Required when overriding init
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initArrow()
    }
    
    private func initArrow() {
        initImage()
        initConstraints()
    }
    
    private func initImage() {
        image = UIImage(named: "LeftArrow")
        frame.size = image?.size ?? CGSize.zero
        contentMode = .scaleAspectFit
    }
    
    private func initConstraints() {
        translatesAutoresizingMaskIntoConstraints = false
        heightAnchor.constraint(equalTo: widthAnchor, multiplier: 1).isActive = true
    }
}

