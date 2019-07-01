//  Created by Cristian Buse on 26/06/2019.
//  Copyright © 2019 Hans Guntersson. All rights reserved.

import UIKit

class SequencePopup: HiddenStatusBarController {
    // Callbacks
    var onEdit: (() -> Void)?
    var onPlay: (() -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleAddTap))
        view.addGestureRecognizer(tapGesture)
    }
    
    @objc private func handleAddTap() {
        dismiss(animated: false, completion: nil)
    }
    @IBAction func editWasPressed(_ sender: UIButton) {
        dismiss(animated: false, completion: onEdit)
    }
    @IBAction func playWasPressed(_ sender: UIButton) {
        dismiss(animated: false, completion: onPlay)
    }
}
