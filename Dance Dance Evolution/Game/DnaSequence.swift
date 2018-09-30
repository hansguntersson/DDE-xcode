//  Created by Cristian Buse on 17/09/2018.
//  Copyright © 2018 Hans Guntersson. All rights reserved.

class DnaSequence: Codable {
    private(set) var nucleobaseSequence: [Nucleobase]
    
    enum NucleobaseType: Int, Codable {
        case cytosine = 0
        case adenine = 1
        case thymine = 2
        case guanine = 3
    }
    
    class Nucleobase: Codable {
        private(set) var type: NucleobaseType
        
        // Init with random value
        convenience init() {
            self.init(baseType: NucleobaseType(rawValue: Int.random(in: 0...3))!)
        }
 
        init(baseType type: NucleobaseType) {
            self.type = type
        }
    }
    
    var length: Int {
        get {
            return nucleobaseSequence.count
        }
    }
    
    convenience init() {
        self.init(length: 0)
    }
    
    init(length: Int) {
        nucleobaseSequence = []
        for _ in 0..<length {
            nucleobaseSequence.append(Nucleobase())
        }
    }
    
    init(from baseTypes: [NucleobaseType]) {
        nucleobaseSequence = []
        for i in 0..<baseTypes.count {
            nucleobaseSequence.append(Nucleobase(baseType: baseTypes[i]))
        }
    }
}

