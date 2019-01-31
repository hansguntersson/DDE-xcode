//  Created by Cristian Buse on 29/11/2018.
//  Copyright © 2018 Hans Guntersson. All rights reserved.

import Foundation

class DnaStorage {
    private static let documentsFolder = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    static let sequencesURL = documentsFolder.appendingPathComponent("CustomDNASequences.txt")
    
    static func getStoredSequences() -> DnaSequences {
        let sequences = DnaSequences()
        do {
            let jsonData: Data = try Data(contentsOf: sequencesURL)
            let encodedSequences: [String] = try JSONDecoder().decode([String].self, from: jsonData)
            for encodedSequence in encodedSequences {
                if let dna = DnaSequence.decodeFromMinimalString(from: encodedSequence) {
                    sequences.add(sequence: dna)
                }
            }
        } catch {
            print(error.localizedDescription)
        }
        return sequences
    }
    
    static func storeSequences(sequences: DnaSequences) {
        var encodedSequences: [String] = []
        for dna in sequences {
            if let encodedSequence = dna.encodeToMinimalString() {
                encodedSequences.append(encodedSequence)
            }
        }
        do {
            let jsonByteData: Data = try JSONEncoder().encode(encodedSequences)
            try jsonByteData.write(to: sequencesURL)
        } catch {
            return
        }
    }
}
