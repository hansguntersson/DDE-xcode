//  Created by Cristian Buse on 22/09/2018.
//  Copyright © 2018 Hans Guntersson. All rights reserved.

import Foundation
import UIKit

class DDEGame {
    enum Difficulty: Int {
        case easy = 0
        case normal = 1
        case hard = 2
        case pro = 3
    }
    
    enum Speed: CGFloat {
        case slow = 0.75
        case normal = 1.0
        case fast = 1.5
        case veryFast = 2.0
    }
    
    enum Spacing: CGFloat {
        case small = 2.0
        case normal = 1.0
        case large = 0.75
        case veryLarge = 0.5
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
    
    static func isGameAvailableForResume() -> Bool {
        return UserDefaults.standard.bool(forKey: GameKey.resumeKey.rawValue)
    }
    
    private(set) var gameState: GameState!
    
    private var speeds: Dictionary<Difficulty,Speed> = [
        Difficulty.easy: Speed.slow
        , Difficulty.normal: Speed.normal
        , Difficulty.hard: Speed.fast
        , Difficulty.pro: Speed.veryFast
    ]
    
    private var spacings: Dictionary<Difficulty,Spacing> = [
        Difficulty.easy: Spacing.small
        , Difficulty.normal: Spacing.normal
        , Difficulty.hard: Spacing.large
        , Difficulty.pro: Spacing.veryLarge
    ]
    
    required init(resumeSavedState resumeSaved: Bool) {
        var savedGamedState: GameState? = nil
        
        if resumeSaved && DDEGame.isGameAvailableForResume() {
            if let encodedState: String = UserDefaults.standard.string(forKey: GameKey.savedState.rawValue) {
                savedGamedState = GameState.initFromString(from: encodedState)
            }
        }
        self.gameState = savedGamedState ?? newGameState()
    }
    
    private func newGameState() -> GameState {
        let difficulty = Settings.difficulty
        let newState = GameState(
            speed: speeds[difficulty]?.rawValue ?? Speed.normal.rawValue
            , spacing: spacings[difficulty]?.rawValue ?? Spacing.normal.rawValue
            , tolerance: Settings.tolerance
            , fidelity: Settings.fidelityThreshold
            , carryOver: Settings.carryOverThreshold
            , sequenceLength: Settings.sequenceLength
        )
        clearSavedGame()
        return newState
    }
    
    func updateState(_ deltaTime: CFTimeInterval) {
        
    }
    
    func saveState() {
        UserDefaults.standard.set(gameState.toString(), forKey: GameKey.savedState.rawValue)
        UserDefaults.standard.set(true, forKey: GameKey.resumeKey.rawValue)
    }
    
    func clearSavedGame() -> Void {
        UserDefaults.standard.set(false, forKey: GameKey.resumeKey.rawValue)
        UserDefaults.standard.removeObject(forKey: GameKey.savedState.rawValue)
    }
    
    deinit {
        print("Game de-initialized")
    }
}
