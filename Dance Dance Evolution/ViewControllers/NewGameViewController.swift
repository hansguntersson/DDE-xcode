//  Created by Cristian Buse on 07/10/2018.
//  Copyright © 2018 Hans Guntersson. All rights reserved.

import UIKit

class NewGameViewController: HiddenStatusBarController {
    @IBOutlet var sequenceLengthSlider: UISlider!
    @IBOutlet var sequenceLengthInput: NumberTextField!
    
    private enum Segues: String {
        case goToGameScreen = "goToGameScreen"
        case goToReadyScreen = "goToReadyScreen"
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        prepareSequenceLength()
    }
    
    func prepareSequenceLength() {
        sequenceLengthSlider.value = Float(Settings.sequenceLength)
        updateSequenceText()
        
        // Set closure
        sequenceLengthInput.doneButtonAction = { [unowned self] in
            // Ignore if value is not number
            guard let newTextValue = self.sequenceLengthInput.text
                , let newFloatValue =  Float(newTextValue)
            else {
                return
            }
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
    
    @IBAction func goBack(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case Segues.goToReadyScreen.rawValue:
            let readyController = segue.destination as! ReadyViewController
            let isRandom = sender as! Bool
            readyController.onClose = {[unowned self] in (isRandom ? self.startRandomGame() : self.startCustomGame())}
        case Segues.goToGameScreen.rawValue:
            let gameController = segue.destination as! GameViewController
            gameController.dnaSequence = sender as? DnaSequence
        default:
            break
        }
    }
    
    @IBAction func randomGame(_ sender: UIButton) {
        performSegue(withIdentifier: Segues.goToReadyScreen.rawValue, sender: true)
    }
    
    @IBAction func customGame(_ sender: UIButton) {
        let alert = UIAlertController(title: "Notification", message: "Feature under development!", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    private func startRandomGame() {
        if UIApplication.shared.applicationState == .active {
            startGame(sequence: DnaSequence(length: Settings.sequenceLength))
        }
    }
    
    private func startCustomGame() {
        if UIApplication.shared.applicationState == .active {
            // custom game
        }
    }
    
    private func startGame(sequence: DnaSequence) {
        performSegue(withIdentifier: Segues.goToGameScreen.rawValue, sender: sequence)
    }
    
    @IBAction func sequenceLengthHasChanged(_ sender: UISlider) {
        Settings.sequenceLength = Int(sender.value)
        updateSequenceText()
    }
    
    private func updateSequenceText() {
        sequenceLengthInput.text = "\(Settings.sequenceLength)"
    }
}
