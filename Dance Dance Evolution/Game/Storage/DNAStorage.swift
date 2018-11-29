//  Created by Cristian Buse on 29/11/2018.
//  Copyright © 2018 Hans Guntersson. All rights reserved.

import Foundation

class DNAStorage {
    private static let documentsFolder = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    private static let sequencesURL = documentsFolder.appendingPathComponent("CustomDNASequences") //.appendPathExtension("txt")
    
    // The below need to retrieve/store an array of sequences but for now only do one !!!
    
    
    static func getStoredSequences() -> DnaSequence? {
        do {
            let jsonData: Data = try Data(contentsOf: sequencesURL)
            let sequences: DnaSequence = try JSONDecoder().decode(DnaSequence.self, from: jsonData)
            return sequences
        } catch {
            return nil
        }
    }
    
    static func storeSequences(sequences: DnaSequence) {
        do {
            let jsonByteData: Data = try JSONEncoder().encode(sequences)
            try jsonByteData.write(to: sequencesURL)
            print("stored sequences")
        } catch {
            print("could not store sequence")
            return
        }
    }
}
