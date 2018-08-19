//  Created by Cristian Buse on 05/08/2018.
//  Copyright © 2018 Hans Guntersson. All rights reserved.

import Foundation

class Settings{
    enum SettingKey: String {
        case soundIsOn = "DDE_Sound"
        case countdowsDuration = "DDE_Countdown"
        
        
    }
    
    // Default Settings
    private static func getDefaultSetting(settingKey: SettingKey) -> Any {
        switch settingKey {
        case .soundIsOn:
            return true
        case .countdowsDuration:
            return 5
        }
    }
    
    
    
    static func getEntryViewDuration() -> Double {
        return 2.5
    }
    static func getCountdownDurationInSeconds() -> Int {
        return getDefaultSetting(settingKey: .countdowsDuration) as! Int
    }
    static func isSoundOn() -> Bool {
        if let result = getDDESetting(settingKey: .soundIsOn) as? Bool {
            return result
        } else {
            return getDefaultSetting(settingKey: .soundIsOn) as! Bool
        }
    }
    
    
    
    
    
    
    
    
    static func setSoundOn(isOn: Bool) {
        saveDDESetting(settingKey: .soundIsOn, settingValue: isOn)
    }
    
    // Write to the system defaults
    private static func saveDDESetting(settingKey: SettingKey, settingValue: Any) {
        UserDefaults.standard.set(settingValue, forKey: settingKey.rawValue)
    }
    
    // Read from system defaults
    private static func getDDESetting(settingKey: SettingKey) -> Any? {
        return UserDefaults.standard.object(forKey: settingKey.rawValue)
    }
    

    

}
