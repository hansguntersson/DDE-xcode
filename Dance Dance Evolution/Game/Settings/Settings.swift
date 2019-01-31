//  Created by Cristian Buse on 05/08/2018.
//  Copyright © 2018 Hans Guntersson. All rights reserved.

import Foundation

class Settings{    
    private struct Defaults {
        static let isSoundOn: Bool = true
        static let countdownDuration: Int = 5
        static let sequenceLength: Int = 30
        static let difficulty: DDEGame.Difficulty = .normal
        static let tolerance: Int = 5
        static let fidelityThreshold: Double = 0.75
        static let carryOverThreshold: Double = 0.5
        static let isToleranceVisibilityOn: Bool = false
        static let areGameSwipesOn: Bool = true
    }
    
    // Used for read/write to System Defaults
    private enum SettingKey: String {
        case isSoundOn = "DDE_Sound"
        case areYouReadyCountdownDuration = "DDE_Countdown"
        case sequenceLength = "DDE_SequenceLength"
        case difficulty = "DDE_Difficulty"
        case tolerance = "DDE_Tolerance"
        case fidelityThreshold = "DDE_FidelityThreshold"
        case carryOverThreshold = "DDE_CarryOverThreshold"
        case isToleranceVisibilityOn = "DDE_ToleranceVisibility"
        case areGameSwipesOn = "DDE_GameSwipes"
    }

    // Write to the system defaults
    private static func saveSetting(settingKey: SettingKey, settingValue: Any) {
        UserDefaults.standard.set(settingValue, forKey: settingKey.rawValue)
    }
    
    // Read from system defaults
    private static func getSavedSetting(settingKey: SettingKey) -> Any? {
        return UserDefaults.standard.object(forKey: settingKey.rawValue)
    }
    
    // Delete from system defaults
    private static func removeDefaultByKey(_ key: SettingKey) {
        UserDefaults.standard.removeObject(forKey: key.rawValue)
    }
    
    // Erase stored settings from System
    static func resetToDefaults() {
        removeDefaultByKey(.isSoundOn)
        removeDefaultByKey(.areYouReadyCountdownDuration)
        removeDefaultByKey(.sequenceLength)
        removeDefaultByKey(.difficulty)
        removeDefaultByKey(.tolerance)
        removeDefaultByKey(.fidelityThreshold)
        removeDefaultByKey(.carryOverThreshold)
        removeDefaultByKey(.isToleranceVisibilityOn)
        removeDefaultByKey(.areGameSwipesOn)
    }
    
    static func getEntryViewDuration() -> Double {
        return 3
    }
    
    static var isSoundOn: Bool {
        get {
            if let result = getSavedSetting(settingKey: .isSoundOn) {
                return result as! Bool
            } else {
                return Defaults.isSoundOn
            }
        }
        set {
            saveSetting(settingKey: .isSoundOn, settingValue: newValue)
        }
    }
    
    static var countdownDuration: Int {
        get {
            if let result = getSavedSetting(settingKey: .areYouReadyCountdownDuration) {
                return result as! Int
            } else {
                return Defaults.countdownDuration
            }
        }
        set {
            saveSetting(settingKey: .areYouReadyCountdownDuration, settingValue: newValue)
        }
    }
    
    static var sequenceLength: Int {
        get {
            if let result = getSavedSetting(settingKey: .sequenceLength) {
                return result as! Int
            } else {
                return Defaults.sequenceLength
            }
        }
        set {
            saveSetting(settingKey: .sequenceLength, settingValue: newValue)
        }
    }

    static var difficulty: DDEGame.Difficulty {
        get {
            if let rawValue = getSavedSetting(settingKey: .difficulty) {
                return DDEGame.Difficulty(rawValue: rawValue as! Int)!
            } else {
                return Defaults.difficulty
            }
        }
        set {
            saveSetting(settingKey: .difficulty, settingValue: newValue.rawValue)
        }
    }
    
    static var tolerance: Int {
        get {
            if let result = getSavedSetting(settingKey: .tolerance) {
                return result as! Int
            } else {
                return Defaults.tolerance
            }
        }
        set {
            saveSetting(settingKey: .tolerance, settingValue: newValue)
        }
    }
    
    static var fidelityThreshold: Double {
        get {
            if let result = getSavedSetting(settingKey: .fidelityThreshold) {
                return result as! Double
            } else {
                return Defaults.fidelityThreshold
            }
        }
        set {
            saveSetting(settingKey: .fidelityThreshold, settingValue: newValue)
        }
    }
    
    static var carryOverThreshold: Double {
        get {
            if let result = getSavedSetting(settingKey: .carryOverThreshold) {
                return result as! Double
            } else {
                return Defaults.carryOverThreshold
            }
        }
        set {
            saveSetting(settingKey: .carryOverThreshold, settingValue: newValue)
        }
    }
    
    static var isToleranceVisibilityOn: Bool {
        get {
            if let result = getSavedSetting(settingKey: .isToleranceVisibilityOn) {
                return result as! Bool
            } else {
                return Defaults.isToleranceVisibilityOn
            }
        }
        set {
            saveSetting(settingKey: .isToleranceVisibilityOn, settingValue: newValue)
        }
    }

    static var areGameSwipesOn: Bool {
        get {
            if let result = getSavedSetting(settingKey: .areGameSwipesOn) {
                return result as! Bool
            } else {
                return Defaults.areGameSwipesOn
            }
        }
        set {
            saveSetting(settingKey: .areGameSwipesOn, settingValue: newValue)
        }
    }
}
