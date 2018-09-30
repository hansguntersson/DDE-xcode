//  Created by Cristian Buse on 29/09/2018.
//  Copyright © 2018 Hans Guntersson. All rights reserved.

import UIKit
    
class DNASegmentedControl: UISegmentedControl {
    
    convenience init() {
        self.init(frame: CGRect.zero)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initControl()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initControl()
    }
    
    private func initControl() {
        initSegments()
        setFont()
        
        translatesAutoresizingMaskIntoConstraints = false
        heightAnchor.constraint(equalToConstant: 35).isActive = true
        
        layer.cornerRadius = 5
        backgroundColor = UIColor.fadeGrey()
    }
    
    private func initSegments() {
        insertSegment(withTitle: "C", at: 0, animated: false)
        insertSegment(withTitle: "A", at: 1, animated: false)
        insertSegment(withTitle: "T", at: 2, animated: false)
        insertSegment(withTitle: "G", at: 3, animated: false)
        
        let cytosine = subviews[0] as UIView
        let adenine = subviews[1] as UIView
        let thymine = subviews[2] as UIView
        let guanine = subviews[3] as UIView
        
        cytosine.tintColor = UIColor.carmine()
        adenine.tintColor = UIColor.azure()
        thymine.tintColor = UIColor.tweetyBird()
        guanine.tintColor = UIColor.grassGreen()
    }
    
    private func setFont() {
        let fontSize: CGFloat = 18
        let font = (UIFont(name: "Helvetica", size: fontSize) ?? UIFont.systemFont(ofSize: fontSize))
        setTitleTextAttributes([NSAttributedString.Key.font: font], for: .normal)
    }
}
