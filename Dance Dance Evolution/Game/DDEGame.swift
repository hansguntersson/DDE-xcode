//  Created by Cristian Buse on 22/09/2018.
//  Copyright © 2018 Hans Guntersson. All rights reserved.

import Foundation

class DDEGame {
    // The current Game State
    private(set) var state: GameState
    
    // Callback that will run when a mutation occurs
    var onMutation: (() -> Void)?
    
    // -------------------------------------------------------------------------
    // Mark: - Game Speed and Spacing based on Difficulty
    // -------------------------------------------------------------------------
    enum Difficulty: Int, Codable {
        case easy = 0
        case normal = 1
        case hard = 2
        case pro = 3
    }

    enum Speed: Float {
        case slow = 0.9
        case normal = 1.0
        case fast = 1.1
        case veryFast = 1.2
    }
    
    enum Spacing: Float {
        case verySmall = 0.5
        case small = 0.75
        case normal = 1.0
        case large = 1.5
    }
    
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
    
    // -------------------------------------------------------------------------
    // Mark: - Game Init
    // -------------------------------------------------------------------------
    private let arrowsPerGameScreen: Float
    private var arrowsPerFullGameHeight: Float = 0.0
    private(set) var spacedArrowsPerScreen: Float = 0.0
    
    init(dnaSequence: DnaSequence, arrowsPerGameScreen: Float) {
        let difficulty = Settings.difficulty
        self.state = GameState(
            difficulty: difficulty
            , speed: speeds[difficulty]!.rawValue
            , spacing: spacings[difficulty]!.rawValue
            , tolerance: Settings.tolerance
            , fidelity: Settings.fidelityThreshold
            , carryOver: Settings.carryOverThreshold
            , sequence: dnaSequence
        )
        self.arrowsPerGameScreen = arrowsPerGameScreen
        self.computeArrowHeights()
    }
    
    init(gameState: GameState, arrowsPerGameScreen: Float) {
        self.state = gameState
        self.arrowsPerGameScreen = arrowsPerGameScreen
        self.computeArrowHeights()
    }
    
    private func computeArrowHeights() {
        self.arrowsPerFullGameHeight = (state.spacing + 1.0) * Float(state.sequence.count - 1) + arrowsPerGameScreen
        self.spacedArrowsPerScreen = (arrowsPerGameScreen - 1.0) / (state.spacing + 1)
    }
    
    // -------------------------------------------------------------------------
    // Mark: - Game State gets updated from the Game Controller
    // -------------------------------------------------------------------------
    private let secondsSpentOnScreen: TimeInterval = 2.5
    
    func updateState(_ deltaTime: CFTimeInterval, _ minYPercent: Float) {
        let sequence = state.sequence.nucleobaseSequence
        var isFirstHidden: Bool = true
        var isFirstActive: Bool = true

        for i in 0..<sequence.count {
            let nucleobase = sequence[i]
            if nucleobase.isActive {
                // Speed is affected by the display time (seconds on screen) and actual speed multiplier
                nucleobase.percentY -= Float(deltaTime / secondsSpentOnScreen) * state.speed
                if nucleobase.evolutionState == .uncertain {
                    if nucleobase.percentY < minYPercent {
                        nucleobase.mutateToRandom()
                        self.onMutation?()
                    }
                }
                if isFirstActive {
                    isFirstActive = false
                    state.percentCompleted = ((state.spacing + 1.0) * Float(i) + (1.0 - nucleobase.percentY) * arrowsPerGameScreen) / arrowsPerFullGameHeight
                }
            } else {
                if isFirstHidden {
                    if nucleobase.percentY == 1 {
                        isFirstHidden = false
                        if i > 0 {
                            // Spacing
                            let previousPercentY = sequence[i - 1].percentY
                            let deltaY = (state.spacing + 1) / arrowsPerGameScreen
                            if 1 - previousPercentY >= deltaY {
                                nucleobase.activate()
                                nucleobase.percentY = previousPercentY + deltaY
                            }
                        } else {
                            nucleobase.activate()
                        }
                    }
                }
            }
        }
        state.beatsScale += Float(deltaTime) * state.speed
        if state.beatsScale >= 1 {
            state.beatsScale -= 1
        }
    }
    
    // -------------------------------------------------------------------------
    // Mark: - End of Game
    // -------------------------------------------------------------------------
    func hasEnded() -> Bool {
        let sequence = state.sequence.nucleobaseSequence
        return sequence[sequence.count - 1].percentY == 0.0
    }
    
    // -------------------------------------------------------------------------
    // Mark: - Debug for memory leaks
    // -------------------------------------------------------------------------
    deinit {
        print("Game de-initialized")
    }
}

// Saving and retrieving saved game states
extension DDEGame {
    // Used for read/write to System Defaults
    private enum GameKey: String {
        case resumeKey = "DDE_Resume"
        case savedState = "DDE_SavedState"
    }
    
    func saveState() {
        if !self.hasEnded() {
            UserDefaults.standard.set(state.encodeToString(), forKey: GameKey.savedState.rawValue)
            UserDefaults.standard.set(true, forKey: GameKey.resumeKey.rawValue)
        }
    }
    
    static func isGameAvailableForResume() -> Bool {
        return UserDefaults.standard.bool(forKey: GameKey.resumeKey.rawValue)
    }
    
    static func getSavedGameState() -> GameState? {
        var savedGamedState: GameState? = nil
        if DDEGame.isGameAvailableForResume() {
            if let encodedState: String = UserDefaults.standard.string(forKey: GameKey.savedState.rawValue) {
                savedGamedState = GameState.decodeFromString(from: encodedState)
            }
        }
        return savedGamedState
    }
    
    static func clearSavedGame() -> Void {
        UserDefaults.standard.set(false, forKey: GameKey.resumeKey.rawValue)
        UserDefaults.standard.removeObject(forKey: GameKey.savedState.rawValue)
    }
}
