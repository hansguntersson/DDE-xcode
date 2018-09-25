//  Created by Cristian Buse on 15/09/2018.
//  Copyright © 2018 Hans Guntersson. All rights reserved.

import UIKit

struct GameState: Codable {
    let speed: CGFloat
    let spacing: CGFloat
    let tolerance: Int
    let fidelity: Double
    let carryOver: Double
    
    private var sequence: DnaSequence
    
    init(
        speed: CGFloat
        , spacing: CGFloat
        , tolerance: Int
        , fidelity: Double
        , carryOver: Double
        , sequenceLength: Int
    ) {
        self.speed = speed
        self.spacing = spacing
        self.tolerance = tolerance
        self.fidelity = fidelity
        self.carryOver = carryOver
        
        sequence = DnaSequence(length: sequenceLength)
    }
    
    func toString() -> String? {
        do {
            let jsonByteData: Data = try JSONEncoder().encode(self)
            return String(bytes: jsonByteData, encoding: .utf8)
        } catch {
            return nil
        }
    }
    
    static func initFromString(from jsonString: String) -> GameState? {
        if let jsonData: Data = jsonString.data(using: .utf8) {
            do {
                let gameState = try JSONDecoder().decode(GameState.self, from: jsonData)
                return gameState
            } catch {
                return nil
            }
        } else {
            return nil
        }
    }
}
