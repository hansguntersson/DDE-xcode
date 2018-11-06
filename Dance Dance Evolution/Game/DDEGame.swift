//  Created by Cristian Buse on 22/09/2018.
//  Copyright © 2018 Hans Guntersson. All rights reserved.

import Foundation

class DDEGame {
    enum Difficulty: Int, Codable {
        case easy = 0
        case normal = 1
        case hard = 2
        case pro = 3
    }
    
    enum Speed: Double {
        case slow = 0.9
        case normal = 1.0
        case fast = 1.1
        case veryFast = 1.2
    }
    
    enum Spacing: Double {
        case verySmall = 0.5
        case small = 0.75
        case normal = 1.0
        case large = 1.5
    }
    
    // Used for read/write to System Defaults
    private enum GameKey: String {
        case resumeKey = "DDE_Resume"
        case savedState = "DDE_SavedState"
    }
    
    private(set) var currentGameState: GameState!
    
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
        self.currentGameState = newGameState(dnaSequence: dnaSequence)
        DDEGame.clearSavedGame()
    }
    
    init(gameState: GameState) {
        self.currentGameState = gameState
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
    
    func updateState(_ deltaTime: CFTimeInterval, _ arrowsPerGameScreen: Double) {
        let sequence = currentGameState.sequence.nucleobaseSequence
        var isFirstHidden: Bool = true
        let secondsSpentOnScreen: TimeInterval = 3.2

        for i in 0..<sequence.count {
            let nucleobase = sequence[i]
            if nucleobase.isVisible {
                // Speed is affected by the display time (seconds on screen) and actual speed multiplier
                nucleobase.percentY -= Float(deltaTime / secondsSpentOnScreen) * Float(currentGameState.speed)
                if nucleobase.percentY <= 0  {
                    nucleobase.percentY = 0
                    nucleobase.isVisible = false
                }
            } else {
                if isFirstHidden {
                    if nucleobase.percentY == 1 {
                        isFirstHidden = false
                        if i > 0 {
                            // Spacing (1 means exactly oen arrow size)
                            let previousPercentY = sequence[i - 1].percentY
                            if 1 - previousPercentY >= Float((currentGameState.spacing + 1) / arrowsPerGameScreen) {
                                nucleobase.isVisible = true
                                nucleobase.percentY = previousPercentY + Float((currentGameState.spacing + 1) / arrowsPerGameScreen)
                            }
                        } else {
                            nucleobase.isVisible = true
                        }
                    }
                }
            }
        }
    }
    
    func saveState() {
        UserDefaults.standard.set(currentGameState.toString(), forKey: GameKey.savedState.rawValue)
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
