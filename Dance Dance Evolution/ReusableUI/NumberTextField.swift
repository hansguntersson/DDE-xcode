//  Created by Cristian Buse on 12/10/2018.
//  Copyright © 2018 Hans Guntersson. All rights reserved.s

import UIKit

class NumberTextField: UITextField {
    // Closure called when the Done button is tapped
    var doneButtonAction: (() -> Void)?

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        let toolbar = UIToolbar()
        let leadingFlexButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let trailingFlexButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let doneButton = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(doneWasTapped(_:)))
        
        toolbar.items = [leadingFlexButton, doneButton, trailingFlexButton]
        toolbar.sizeToFit()
        
        self.inputAccessoryView = toolbar
        self.keyboardType = .numberPad
    }
    
    @objc func doneWasTapped(_ sender: UIBarButtonItem) {
        doneButtonAction?()
    }
}
