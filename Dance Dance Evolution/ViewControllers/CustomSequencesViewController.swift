//  Created by Cristian Buse on 14/11/2018.
//  Copyright © 2018 Hans Guntersson. All rights reserved.

import UIKit

class CustomSequencesViewController: HiddenStatusBarController {

    override func viewDidLoad() {
        super.viewDidLoad()

        
    }
    
    
    
    
    
    
    @IBAction func goBack(_ sender: UIButton) {
        self.dismiss(animated: false, completion: nil)
    }
    
}

extension CustomSequencesViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "sequenceCell") as! CustomSequenceCell
        cell.nameLabel.text = "Name " + String(indexPath.row)
        cell.lengthLabel.text = "Lenght: 5"
        cell.lastSavedLabel.text = "Sometime"
        
        return cell
    }
    
    
    
}
