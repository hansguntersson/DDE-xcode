//  Created by Cristian Buse on 14/11/2018.
//  Copyright © 2018 Hans Guntersson. All rights reserved.

import UIKit

class SequencesViewController: HiddenStatusBarController {
    var sequences: DnaSequences?
    
    private enum Segues: String {
        case goToSequencePopup = "goToSequencePopup"
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
  
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case Segues.goToSequencePopup.rawValue:
            break
        default:
            break
        }
    }
    
    
    
    
    
    
    
    @IBAction func goBack(_ sender: UIButton) {
        self.dismiss(animated: false, completion: nil)
    }
    
    
    
    
    
    
    
}






// -------------------------------------------------------------------------
// Table View
// -------------------------------------------------------------------------
extension SequencesViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sequences?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "sequenceCell") as! CustomSequenceCell
        cell.setup(sequence: sequences![indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 110
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // need a pop-up view controller
        performSegue(withIdentifier: Segues.goToSequencePopup.rawValue, sender: nil)
        
//        let alert = UIAlertController(title: "Sequence", message: "...", preferredStyle: .alert)
//        alert.addAction(UIAlertAction(title: "Play", style: .default, handler: nil))
//        alert.addAction(UIAlertAction(title: "Edit", style: .default, handler: nil))
//        self.present(alert, animated: true, completion: nil)
    }
}
