//  Created by Cristian Buse on 04/09/2018.
//  Copyright © 2018 Hans Guntersson. All rights reserved.

extension Double {
    func toPercentString(decimalPlaces decimals:Int) -> String {
        return String(format: "%.\(decimals < 0 ? 0 : decimals)f%%", self * 100)
    }
}
