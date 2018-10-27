//  Created by Cristian Buse on 22/09/2018.
//  Copyright © 2018 Hans Guntersson. All rights reserved.

import Foundation
import UIKit

class DDEGame {
    enum Difficulty: Int, Codable {
        case easy = 0
        case normal = 1
        case hard = 2
        case pro = 3
    }
    
    enum Speed: CGFloat {
        case slow = 0.75
        case normal = 1.0
        case fast = 1.25
        case veryFast = 1.5
    }
    
    enum Spacing: CGFloat {
        case verySmall = 0.5
        case small = 0.75
        case normal = 1.0
        case large = 2.0
    }
    
    enum UserInput: Int {
        case none = -1
        case left = 0
        case right = 1
        case up = 2
        case down = 3
    }
    
    // Used for read/write to System Defaults
    private enum GameKey: String {
        case resumeKey = "DDE_Resume"
        case savedState = "DDE_SavedState"
    }
    
    private(set) var gameState: GameState!
    
    private var speeds: Dictionary<Difficulty,Speed> = [
        Difficulty.easy: Speed.slow
        , Difficulty.normal: Speed.normal
        , Difficulty.hard: Speed.fast
        , Difficulty.pro: Speed.veryFast
    ]
    
    private var spacings: Dictionary<Difficulty,Spacing> = [
        Difficulty.easy: Spacing.large
        , Difficulty.normal: Spacing.normal
        , Difficulty.hard: Spacing.small
        , Difficulty.pro: Spacing.verySmall
    ]
    
    init(dnaSequence: DnaSequence) {
        self.gameState = newGameState(dnaSequence: dnaSequence)
        DDEGame.clearSavedGame()
    }
    
    init(gameState: GameState) {
        self.gameState = gameState
        DDEGame.clearSavedGame()
    }
    
    private func newGameState(dnaSequence: DnaSequence) -> GameState {
        let difficulty = Settings.difficulty
        let newState = GameState(
            difficulty: difficulty
            , speed: speeds[difficulty]!.rawValue
            , spacing: spacings[difficulty]!.rawValue
            , tolerance: Settings.tolerance
            , fidelity: Settings.fidelityThreshold
            , carryOver: Settings.carryOverThreshold
            , sequence: dnaSequence
        )
        return newState
    }
    
    private var cumulatedDelta: TimeInterval = 0.0
    
    func updateState(_ deltaTime: CFTimeInterval) {
        let sequence = gameState.sequence.nucleobaseSequence
        var isFirstHidden: Bool = true
        cumulatedDelta += deltaTime

        for i in 0..<sequence.count {
            let nucleobase = sequence[i]
            if nucleobase.isVisible {
                nucleobase.percentY = nucleobase.percentY - Float(deltaTime) * Float(gameState.speed) / 2
                if nucleobase.percentY < -0.2 {
                    nucleobase.isVisible = false
                }
            } else {
                if isFirstHidden {
                    if nucleobase.percentY == 1 {
                        isFirstHidden = false
                        if Float(cumulatedDelta) * Float(gameState.speed) > 0.3 {
                            nucleobase.isVisible = true
                            cumulatedDelta -= 0.3 / TimeInterval(gameState.speed)
                        }
                    }
                }
            }
        }
    }
    
    func saveState() {
        UserDefaults.standard.set(gameState.toString(), forKey: GameKey.savedState.rawValue)
        UserDefaults.standard.set(true, forKey: GameKey.resumeKey.rawValue)
    }
    
    deinit {
        print("Game de-initialized")
    }
}

extension DDEGame {
    static func isGameAvailableForResume() -> Bool {
        return UserDefaults.standard.bool(forKey: GameKey.resumeKey.rawValue)
    }
    
    static func getSavedGameState() -> GameState? {
        var savedGamedState: GameState? = nil
        if DDEGame.isGameAvailableForResume() {
            if let encodedState: String = UserDefaults.standard.string(forKey: GameKey.savedState.rawValue) {
                savedGamedState = GameState.initFromString(from: encodedState)
            }
        }
        return savedGamedState
    }
    
    static func clearSavedGame() -> Void {
        UserDefaults.standard.set(false, forKey: GameKey.resumeKey.rawValue)
        UserDefaults.standard.removeObject(forKey: GameKey.savedState.rawValue)
    }
}
