//  Created by Cristian Buse on 14/08/2018.
//  Copyright © 2018 Hans Guntersson. All rights reserved.

import UIKit

class SetupViewController: HiddenStatusBarController, UITextFieldDelegate {

    @IBOutlet var soundOn: UISwitch!
    @IBOutlet var sequenceLengthInput: NumberTextField!
    @IBOutlet var sequenceLengthSlider: UISlider!
    @IBOutlet var countdownStepper: UIStepper!
    @IBOutlet var countdownLabel: UILabel!
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
        
        sequenceLengthInput.delegate = self
        updateDisplayedSettings()
        prepareSequenceLength()
    }
    
    private func updateDisplayedSettings() {
        soundOn.isOn = Settings.isSoundOn
        sequenceLengthSlider.value = Float(Settings.sequenceLength)
        updateSequenceText()
        countdownStepper.value = Double(Settings.countdownDuration)
        countdownLabel.text = String(Settings.countdownDuration)
        difficulty.selectedSegmentIndex = Settings.difficulty.rawValue
        toleranceStepper.value = Double(Settings.tolerance)
        toleranceLabel.text = String(Settings.tolerance)
        fidelityStepper.value = Settings.fidelityThreshold
        fidelityLabel.text = fidelityStepper.value.toPercentString(decimalPlaces: 0)
        carryOverStepper.value = Settings.carryOverThreshold
        carryOverLabel.text = carryOverStepper.value.toPercentString(decimalPlaces: 0)
        toleranceVisibilityOn.isOn = Settings.isToleranceVisibilityOn
    }
    
    private func updateSequenceText() {
        sequenceLengthInput.text = "\(Settings.sequenceLength)"
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.selectedTextRange = textField.textRange(from: textField.beginningOfDocument, to: textField.endOfDocument)
    }
    
    func prepareSequenceLength() {
        sequenceLengthInput.doneButtonAction = { [unowned self] in
            let newTextValue = self.sequenceLengthInput.text ?? ""
            let newFloatValue =  Float(newTextValue) ?? -1.0

            // Apply the new value
            if newFloatValue >= self.sequenceLengthSlider.minimumValue
                && newFloatValue <= self.sequenceLengthSlider.maximumValue
            {
                self.sequenceLengthSlider.value = newFloatValue
                Settings.sequenceLength = Int(newFloatValue)
            }
            // Sync displayed text with slider value
            self.updateSequenceText()
            // Dismiss Keyboard
            if self.sequenceLengthInput.isFirstResponder {
                self.sequenceLengthInput.resignFirstResponder()
            }
        }
    }
    
    @IBAction func soundToggled(_ sender: UISwitch) {
        Settings.isSoundOn = sender.isOn
    }
    
    @IBAction func sequenceLengthHasChanged(_ sender: UISlider) {
        Settings.sequenceLength = Int(sender.value)
        updateSequenceText()
    }
    
    @IBAction func countdownChanged(_ sender: UIStepper) {
        let newValue = Int(sender.value)
        Settings.countdownDuration = newValue
        countdownLabel.text = String(newValue)
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
