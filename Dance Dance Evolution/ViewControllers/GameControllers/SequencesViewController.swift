//  Created by Cristian Buse on 14/11/2018.
//  Copyright © 2018 Hans Guntersson. All rights reserved.

import UIKit

class SequencesViewController: HiddenStatusBarController {
    var sequences: DnaSequences?
    @IBOutlet var sequencesTable: UITableView!
    
    var onPlay: ((_ sequence: DnaSequence) -> Void)!
    
    private enum Segues: String {
        case goToSequencePopup = "goToSequencePopup"
        
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    // -------------------------------------------------------------------------
    // Navigation
    // -------------------------------------------------------------------------
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case Segues.goToSequencePopup.rawValue:
            let popupController = segue.destination as! SequencePopup
            popupController.onEdit = {[unowned self] in self.editSequence()}
            popupController.onPlay = {[unowned self] in self.startCustomGame()}
        default:
            break
        }
    }
    
    private func startCustomGame() {
        if UIApplication.shared.applicationState == .active {
            let sequence = sequences![sequencesTable.indexPathForSelectedRow!.row]
            self.dismiss(animated: false, completion: {[unowned self] in self.onPlay(sequence)})
        }
    }
    
    private func editSequence() {
        if UIApplication.shared.applicationState == .active {
            let sequence = sequences![sequencesTable.indexPathForSelectedRow!.row]
            print(sequence.name)
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
        performSegue(withIdentifier: Segues.goToSequencePopup.rawValue, sender: nil)
    }
}
