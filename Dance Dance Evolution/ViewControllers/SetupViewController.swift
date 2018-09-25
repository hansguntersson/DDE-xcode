//  Created by Cristian Buse on 14/08/2018.
//  Copyright © 2018 Hans Guntersson. All rights reserved.

import UIKit

class SetupViewController: HiddenStatusBarController {

    @IBOutlet var soundOn: UISwitch!
    @IBOutlet var countdownStepper: UIStepper!
    @IBOutlet var countdownLabel: UILabel!
    @IBOutlet var sequenceLength: UISegmentedControl!
    @IBOutlet var difficulty: UISegmentedControl!
    @IBOutlet var toleranceStepper: UIStepper!
    @IBOutlet var toleranceLabel: UILabel!
    @IBOutlet var fidelityStepper: UIStepper!
    @IBOutlet var fidelityLabel: UILabel!
    @IBOutlet var carryOverStepper: UIStepper!
    @IBOutlet var carryOverLabel: UILabel!
    @IBOutlet var toleranceVisibilityOn: UISwitch!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        updateDisplayedSettings()
    }
    
    private func updateDisplayedSettings() {
        soundOn.isOn = Settings.isSoundOn
        countdownStepper.value = Double(Settings.countdownDuration)
        countdownLabel.text = String(Settings.countdownDuration)
        sequenceLength.selectedSegmentIndex = Settings.sequenceLength / 15 - 1
        difficulty.selectedSegmentIndex = Settings.difficulty.rawValue
        toleranceStepper.value = Double(Settings.tolerance)
        toleranceLabel.text = String(Settings.tolerance)
        fidelityStepper.value = Settings.fidelityThreshold
        fidelityLabel.text = fidelityStepper.value.toPercentString(decimalPlaces: 0)
        carryOverStepper.value = Settings.carryOverThreshold
        carryOverLabel.text = carryOverStepper.value.toPercentString(decimalPlaces: 0)
        toleranceVisibilityOn.isOn = Settings.isToleranceVisibilityOn
    }
    
    @IBAction func soundToggled(_ sender: UISwitch) {
        Settings.isSoundOn = sender.isOn
    }
    
    @IBAction func countdownChanged(_ sender: UIStepper) {
        let newValue = Int(sender.value)
        Settings.countdownDuration = newValue
        countdownLabel.text = String(newValue)
    }
    
    @IBAction func sequenceChanged(_ sender: UISegmentedControl) {
        Settings.sequenceLength = (sender.selectedSegmentIndex + 1) * 15
    }
    
    @IBAction func difficultyChanged(_ sender: UISegmentedControl) {
        if let difficultyEnum = DDEGame.Difficulty(rawValue: sender.selectedSegmentIndex) {
            Settings.difficulty = difficultyEnum
        }
    }
    
    @IBAction func toleranceChanged(_ sender: UIStepper) {
        let newValue = Int(sender.value)
        Settings.tolerance = newValue
        toleranceLabel.text = String(newValue)
    }
    
    @IBAction func fidelityChanged(_ sender: UIStepper) {
        let newValue = sender.value
        Settings.fidelityThreshold = newValue
        fidelityLabel.text = newValue.toPercentString(decimalPlaces: 0)
    }
    
    @IBAction func carryOverChanged(_ sender: UIStepper) {
        let newValue = sender.value
        Settings.carryOverThreshold = newValue
        carryOverLabel.text = newValue.toPercentString(decimalPlaces: 0)
    }
    
    @IBAction func toleranceVisibilityToggled(_ sender: UISwitch) {
        Settings.isToleranceVisibilityOn = sender.isOn
    }
    
    @IBAction func resetToDefault(_ sender: UIButton) {
        Settings.resetToDefaults()
        updateDisplayedSettings()
    }
    
    @IBAction func goBack(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
}
