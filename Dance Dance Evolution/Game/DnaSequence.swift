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
    
    enum HitState: Int, Codable {
        case none = 0
        case hit = 1
        case miss = 2
    }
    
    private static var nucleobaseLetters: Dictionary<NucleobaseType,String> = [
        NucleobaseType.cytosine: "C"
        , NucleobaseType.adenine: "A"
        , NucleobaseType.thymine: "T"
        , NucleobaseType.guanine: "G"
    ]
    
    class Nucleobase: Codable {
        let type: NucleobaseType
        let letter: String
        var isVisible: Bool = false
        var percentY: Float = 1.0
        var hitState: HitState = .none

        // Init with random value
        convenience init() {
            self.init(baseType: NucleobaseType(rawValue: Int.random(in: 0...3))!)
        }
 
        init(baseType type: NucleobaseType) {
            self.type = type
            self.letter = nucleobaseLetters[type]!
        }
    }
    
    var length: Int {
        get {
            return nucleobaseSequence.count
        }
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

