//  Created by Cristian Buse on 02/12/2018.
//  Copyright © 2018 Hans Guntersson. All rights reserved.

import Foundation

class DnaSequences: Sequence, IteratorProtocol {
    private var sequencesDict: [String: DnaSequence] = [:]
    
    init() {
        sequencesDict = [:]
    }
    
    // -------------------------------------------------------------------------
    // Mark: - Iteration
    // -------------------------------------------------------------------------
    private var currentIndex: Int = 0
    private var keys: [String] = []
    
    func makeIterator() -> DnaSequences {
        currentIndex = 0
        keys = sequencesDict.keys.sorted()
        return self
    }
    
    func next() -> DnaSequence? {
        if currentIndex < keys.count {
            let key = keys[currentIndex]
            currentIndex += 1
            return sequencesDict[key]
        }
        return nil
    }
    
    // -------------------------------------------------------------------------
    // Mark: - Wrapped functionality
    // -------------------------------------------------------------------------
    func add(sequence: DnaSequence) -> Bool {
        if nameExists(name: sequence.name) || lettersExist(letters: sequence.letters()) {
            return false
        }
        sequencesDict[sequence.name] = sequence
        return true
    }

    func nameExists(name: String) -> Bool {
        return sequencesDict[name] != nil
    }
    
    func lettersExist(letters: String) -> Bool {
        var result: Bool = false
        for (_, sequence) in sequencesDict {
            if sequence.letters() == letters {
                result = true
                break
            }
        }
        return result
    }
    
    func remove(sequenceName: String) {
        sequencesDict.removeValue(forKey: sequenceName)
    }
}
