//  Created by Cristian Buse on 30/09/2018.
//  Copyright © 2018 Hans Guntersson. All rights reserved.

import UIKit

class TestViewController: HiddenStatusBarController {
    @IBOutlet var scroll: DNASequenceScrollView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        scroll.setSequence(dnaSequence: DnaSequence(length: 60))
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        let sequenceCount: Int = 10
        let dnas = DnaSequences()
        
        for i in 0..<sequenceCount {
            let dna = DnaSequence(length: i * 5 + 30)
            _ = dnas.add(sequence: dna)
        }
        DnaStorage.storeSequences(sequences: dnas)
        
        let dnas2 = DnaStorage.getStoredSequences()
        for dna in dnas2 {
            print(dna)
            if dna.name == "RandomSequence2" {break}
            
        }
        print("second time")
        let dna = DnaSequence(length: 5 * 5 + 30, name: "RandomSequence5")
        _ = dnas2.add(sequence: dna)
        for dna in dnas2 {
            print(dna)
        }
        
        let ac = UIActivityViewController(activityItems: [DnaStorage.sequencesURL], applicationActivities: nil)
        present(ac, animated: true)

        
    }
    
    
    @IBAction func goBack(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
}
