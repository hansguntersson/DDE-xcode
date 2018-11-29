//  Created by Cristian Buse on 17/09/2018.
//  Copyright © 2018 Hans Guntersson. All rights reserved.

class DnaSequence: Codable {
    private(set) var nucleobaseSequence: [Nucleobase]
    
    enum NucleobaseType: Int, Codable {
        case cytosine = 0
        case adenine = 1
        case thymine = 2
        case guanine = 3
        
        func toLetter() -> String {
            switch self {
                case .cytosine:
                    return "C"
                case .adenine:
                    return "A"
                case .thymine:
                    return "T"
                case .guanine:
                    return "G"
            }
        }
        
        static func random() -> NucleobaseType {
            return NucleobaseType(rawValue: Int.random(in: 0...3))!
        }
    }
    
    enum EvolutionState: Int, Codable {
        case uncertain = 0
        case preserved = 1
        case mutated = 2
    }
    
    class Nucleobase: Codable {
        let type: NucleobaseType
        private(set) var isActive: Bool = false
        private(set) var evolutionState: EvolutionState = .uncertain
        var percentY: Float = 1.0 {
            didSet {
                if percentY < 0.0 {
                    percentY = 0.0
                    isActive = false
                } else if percentY > 1.0 {
                    percentY = 1.0
                    isActive = false
                }
            }
        }
        private(set) var mutatedType: NucleobaseType?

        // Init with random value
        convenience init() {
            self.init(baseType: NucleobaseType.random())
        }
 
        required init(baseType type: NucleobaseType) {
            self.type = type
        }
        
        func mutate(to newtype: NucleobaseType) {
            mutatedType = newtype
            evolutionState = .mutated
        }
        
        func mutateToRandom() {
            repeat {
                mutatedType = NucleobaseType.random()
            } while mutatedType == type
            evolutionState = .mutated
        }
        
        func preserve() {
            evolutionState = .preserved
        }
        
        func activate() {
            isActive = true
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
    
    func evolutionPercentage(of state: EvolutionState) -> Float {
        var counter: Int = 0
        for nucleobase in nucleobaseSequence {
            if nucleobase.evolutionState == state {
                counter += 1
            }
        }
        return Float(counter) / Float(nucleobaseSequence.count)
    }
    
    func mutatedSequence() -> DnaSequence? {
        if evolutionPercentage(of: .mutated) > 0 {
            var mutatedNucleobaseSequence: [NucleobaseType] = []
            for nucleobase in nucleobaseSequence {
                mutatedNucleobaseSequence.append(nucleobase.mutatedType ?? nucleobase.type)
            }
            return DnaSequence(from: mutatedNucleobaseSequence)
        } else {
            return nil
        }
    }
    
    func letters() -> String {
        var result: String = ""
        for nucleobase in nucleobaseSequence {
            result += nucleobase.type.toLetter()
        }
        return result
    }
}
