//  Created by Cristian Buse on 15/09/2018.
//  Copyright © 2018 Hans Guntersson. All rights reserved.

import Foundation

struct GameState: Codable {
    let difficulty: DDEGame.Difficulty
    let speed: Double
    let spacing: Double
    let tolerance: Int
    let fidelity: Double
    let carryOver: Double
    
    private(set) var sequence: DnaSequence!
    
    init(
        difficulty: DDEGame.Difficulty
        , speed: Double
        , spacing: Double
        , tolerance: Int
        , fidelity: Double
        , carryOver: Double
        , sequence: DnaSequence
    ) {
        self.difficulty = difficulty
        self.speed = speed
        self.spacing = spacing
        self.tolerance = tolerance
        self.fidelity = fidelity
        self.carryOver = carryOver
        self.sequence = sequence
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
