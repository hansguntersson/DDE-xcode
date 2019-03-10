//  Created by Cristian Buse on 17/09/2018.
//  Copyright © 2018 Hans Guntersson. All rights reserved.

import Foundation
import UIKit

class DnaSequence: Codable, CustomStringConvertible {
    // -------------------------------------------------------------------------
    // Mark: - Primary Class Members
    // -------------------------------------------------------------------------
    var description: String {
        return encodeToMinimalString() ?? name + ": " + letters() + "description: "
    }
    
    private(set) var name: String
    var sequenceDescription: String = ""
    private(set) var nucleobaseSequence: [Nucleobase]
    
    // -------------------------------------------------------------------------
    // Mark: - Nucleobase Type and Evolution State enumerations
    // -------------------------------------------------------------------------
    enum NucleobaseType: String, Codable {
        case cytosine = "C"
        case adenine = "A"
        case thymine = "T"
        case guanine = "G"
        
        static func random() -> NucleobaseType {
            return NucleobaseType(rawValue: ["C", "A", "T", "G"][Int.random(in: 0...3)])!
        }
        var pair: NucleobaseType {
            switch self {
            case .cytosine:
                return .guanine
            case .adenine:
                return .thymine
            case .thymine:
                return .adenine
            case .guanine:
                return .cytosine
            }
        }
        var next: NucleobaseType {
            switch self {
            case .cytosine:
                return .adenine
            case .adenine:
                return .thymine
            case .thymine:
                return .guanine
            case .guanine:
                return .cytosine
            }
        }
        var color: UIColor {
            switch self {
            case .cytosine:
                return UIColor.carmine()
            case .adenine:
                return UIColor.azure()
            case .thymine:
                return UIColor.tweetyBird()
            case .guanine:
                return UIColor.grassGreen()
            }
        }
    }
    
    enum EvolutionState: Int, Codable {
        case uncertain = 0
        case preserved = 1
        case mutated = 2
    }
    
    // -------------------------------------------------------------------------
    // Mark: - Nucleobase
    // -------------------------------------------------------------------------
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
    
    // -------------------------------------------------------------------------
    // Mark: - Sequence Initializers
    // -------------------------------------------------------------------------
    convenience init(length: Int) {
        self.init(length: length, name: "RandomSequence")
    }
    
    init(length: Int, name: String) {
        nucleobaseSequence = []
        for _ in 0..<length {
            nucleobaseSequence.append(Nucleobase())
        }
        self.name = name
        self.sequenceDescription = ""
    }
    
    init(from letters: String, name: String, description: String) {
        nucleobaseSequence = []
        for letter in letters {
            nucleobaseSequence.append(Nucleobase(baseType: NucleobaseType(rawValue: String(letter))!))
        }
        self.name = name
        self.sequenceDescription = description
    }
    
    init(from baseTypes: [NucleobaseType], name: String, description: String) {
        nucleobaseSequence = []
        for i in 0..<baseTypes.count {
            nucleobaseSequence.append(Nucleobase(baseType: baseTypes[i]))
        }
        self.name = name
        self.sequenceDescription = description
    }
    
    // -------------------------------------------------------------------------
    // Mark: - Sequence Evolution
    // -------------------------------------------------------------------------
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
            let newName = name + "_Mutated_" + Date().toString(format: "yyyy-MM-dd_HH:mm:ss")
            let newDescription = "Mutated from: " + self.description
            return DnaSequence(from: mutatedNucleobaseSequence, name: newName , description: newDescription)
        } else {
            return nil
        }
    }
    
    // -------------------------------------------------------------------------
    // Mark: - Utils
    // -------------------------------------------------------------------------
    func letters() -> String {
        var result: String = ""
        for nucleobase in nucleobaseSequence {
            result += nucleobase.type.rawValue
        }
        return result
    }
    func nucleobaseTypesSequence() -> [NucleobaseType] {
        var types: [NucleobaseType] = []
        for nucleobase in nucleobaseSequence {
            types.append(nucleobase.type)
        }
        return types
    }
    
    // -------------------------------------------------------------------------
    // Mark: - Encode / Decode to / from JSON String
    // -------------------------------------------------------------------------
    func encodeToMinimalString() -> String? {
        do {
            let dict: [String : String] = ["name": name, "lettersSequence": letters(), "description": sequenceDescription]
            let jsonByteData: Data = try JSONEncoder().encode(dict)
            return String(bytes: jsonByteData, encoding: .utf8)
        } catch {
            return nil
        }
    }
    static func decodeFromMinimalString(from jsonString: String) -> DnaSequence? {
        if let jsonData: Data = jsonString.data(using: .utf8) {
            do {
                let dict = try JSONDecoder().decode([String: String].self, from: jsonData)
                guard let decodedName = dict["name"], let decodedLetters = dict["lettersSequence"], let decodedDescription = dict["description"] else {
                    return nil
                }
                return DnaSequence(from: decodedLetters, name: decodedName, description: decodedDescription)
            } catch {
                return nil
            }
        } else {
            return nil
        }
    }
}
