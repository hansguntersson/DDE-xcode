//  Created by Cristian Buse on 28/11/2018.
//  Copyright © 2018 Hans Guntersson. All rights reserved.

import UIKit

class CustomSequenceCell: UITableViewCell {

    
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var lengthLabel: UILabel!
    @IBOutlet var lastSavedLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    
    
    
    
}
