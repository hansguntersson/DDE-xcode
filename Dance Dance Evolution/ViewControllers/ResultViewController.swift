//  Created by Cristian Buse on 08/08/2018.
//  Copyright © 2018 Hans Guntersson. All rights reserved.

import UIKit

class ResultViewController: CustomViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        print("ResultScreen was loaded")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        
    }

    deinit {
        print("ResultScreen was de-initialized")
    }
}
