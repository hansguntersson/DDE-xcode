//  Created by Cristian Buse on 20/08/2019.
//  Copyright © 2019 Hans Guntersson. All rights reserved.

import UIKit

class ScoreViewController: HiddenStatusBarController {
    var dnaSequence: DnaSequence? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print(dnaSequence?.letters() ?? "Missing sequence")
        addTapGestures()
    }
    private func addTapGestures() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        self.view.addGestureRecognizer(tapGesture)
    }
    
    @objc private func handleTap() {
        dismiss(animated: false, completion: nil)
    }
}
