//  Created by Cristian Buse on 02/12/2018.
//  Copyright © 2018 Hans Guntersson. All rights reserved.

import Foundation

class DnaSequences: Sequence, IteratorProtocol, Collection {

    
    private var sequencesDict: [String: DnaSequence] = [:]
    
    init() {
        sequencesDict = [:]
    }
    
    var count: Int {
        get {
            return sequencesDict.count
        }
    }
    
    // -------------------------------------------------------------------------
    // Mark: - IteratorProtocol
    // -------------------------------------------------------------------------
    private var currentIndex: Int = 0
    private var keys: [String] {
        get {
            return sequencesDict.keys.sorted()
        }
    }
    
    func makeIterator() -> DnaSequences {
        currentIndex = 0
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
    // Mark: - Collection
    // -------------------------------------------------------------------------
    subscript(position: Int) -> DnaSequence {
        return sequencesDict[self.keys[position]]!
    }
    func index(after i: Int) -> Int {
        return i + 1
    }
    var startIndex: Int {
        get {
            return 0
        }
    }
    var endIndex: Int {
        get {
            return sequencesDict.count - 1
        }
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
