//  Created by Cristian Buse on 29/09/2018.
//  Copyright © 2018 Hans Guntersson. All rights reserved.

import UIKit

class DNASequenceScrollView: UIScrollView {
    
    // Vertical stack view to hold a stack of DNASegmentedControls
    private var stackContainer: UIStackView!
    
    convenience init(sequence: DnaSequence) {
        self.init(frame: CGRect.zero)
        setSequence(dnaSequence: sequence)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        prepareView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        prepareView()
    }
    
    private func prepareView() {
        layer.cornerRadius = 10
        initStackContainer()
    }
    
    private func initStackContainer() {
        stackContainer = UIStackView(frame: CGRect.zero)
        stackContainer.axis = .vertical
        stackContainer.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(stackContainer)
        
        // AutoLayout Constraints
        stackContainer.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 10).isActive = true
        stackContainer.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -10).isActive = true
        stackContainer.topAnchor.constraint(equalTo: self.topAnchor, constant: 10).isActive = true
        stackContainer.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -10).isActive = true
        stackContainer.widthAnchor.constraint(equalTo: self.widthAnchor, constant: -20).isActive = true
        stackContainer.heightAnchor.constraint(greaterThanOrEqualTo: self.heightAnchor, constant: -20).isActive = true
        
        // Content
        stackContainer.spacing = 10
        stackContainer.alignment = .fill
        stackContainer.distribution = .equalSpacing
        stackContainer.contentMode = .scaleToFill
    }
    
    func setSequence(dnaSequence: DnaSequence) {
        // In case the sequence is replaced
        clearStackSubviews()
        
        for nucleobase in dnaSequence.nucleobaseSequence {
            let segment = DNASegmentedControl()
            stackContainer.addArrangedSubview(segment)
            segment.selectedSegmentIndex = nucleobase.type.rawValue
        }
    }
    
    private func clearStackSubviews() {
        for view in stackContainer.subviews {
            view.removeFromSuperview()
        }
    }
}
