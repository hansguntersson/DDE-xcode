//  Created by Cristian Buse on 05/08/2018.
//  Copyright © 2018 Hans Guntersson. All rights reserved.

import Foundation

class Settings{
    
    enum GameDifficulty: Int {
        case easy = 0
        case normal = 1
        case hard = 2
        case pro = 3
    }
    
    private struct Defaults {
        static let isSoundOn: Bool = true
        static let countdownDuration: Int = 5
        static let sequenceLength: Int = 30
        static let difficulty: GameDifficulty = .normal
        static let tolerance: Int = 5
    }
    
    // Used for read/write to System Defaults
    private enum SettingKey: String {
        case isSoundOn = "DDE_Sound"
        case areYouReadyCountdownDuration = "DDE_Countdown"
        case sequenceLength = "DDE_SequenceLength"
        case difficulty = "DDE_Difficulty"
        case tolerance = "DDE_Tolerance"
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

    static var difficulty: GameDifficulty {
        get {
            if let rawValue = getSavedSetting(settingKey: .difficulty) {
                return GameDifficulty(rawValue: rawValue as! Int)!
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
    
    
}
