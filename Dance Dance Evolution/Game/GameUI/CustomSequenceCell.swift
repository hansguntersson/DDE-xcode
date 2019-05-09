//  Created by Cristian Buse on 28/11/2018.
//  Copyright © 2018 Hans Guntersson. All rights reserved.

import UIKit

class CustomSequenceCell: UITableViewCell {
    @IBOutlet private var nameLabel: UILabel!
    @IBOutlet private var lengthLabel: UILabel!
    @IBOutlet private var lettersLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func setup(sequence: DnaSequence) {
        nameLabel.text = sequence.name
        lengthLabel.text = "(\(sequence.count))"
        lettersLabel.text = sequence.letters()
    }
}
