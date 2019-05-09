//  Created by Cristian Buse on 14/11/2018.
//  Copyright © 2018 Hans Guntersson. All rights reserved.

import UIKit

class SequencesViewController: HiddenStatusBarController {
    var sequences: DnaSequences?
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
    }
    
    
    
    
    
    
    @IBAction func goBack(_ sender: UIButton) {
        self.dismiss(animated: false, completion: nil)
    }
    
}

extension SequencesViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sequences?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "sequenceCell") as! CustomSequenceCell
        let sequence = sequences![indexPath.row]
        cell.nameLabel.text = sequence.name
        cell.lengthLabel.text = "(\(sequence.count))"
        cell.lettersLabel.text = sequence.letters()
        
        return cell
    }
}
