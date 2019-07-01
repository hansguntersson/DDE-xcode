//  Created by Cristian Buse on 05/08/2018.
//  Copyright © 2018 Hans Guntersson. All rights reserved.

import UIKit

class MainViewController: HiddenStatusBarController {
    @IBOutlet var resistanceLogo: PaddedImageView!
    @IBOutlet var btnResume: UIButton!
    
    private enum Segues: String {
        case goToGameScreen = "goToGameScreen"
        case goToReadyScreen = "goToReadyScreen"
        case goToSequences = "goToSequences"
    }
    
    // -------------------------------------------------------------------------
    // Mark: - Lifecycle
    // -------------------------------------------------------------------------
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addTapGestures()
        addPaddingToLogo()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        refreshResumeButton()
    }
    private func refreshResumeButton() {
        btnResume.isHidden = !DDEGame.isGameAvailableForResume()
    }
    
    // -------------------------------------------------------------------------
    // Mark: - Init
    // -------------------------------------------------------------------------
    private func addTapGestures() {
        let logoTapGesture = UITapGestureRecognizer(target: self, action: #selector(handleLogoTap))
        resistanceLogo.addGestureRecognizer(logoTapGesture)
    }
    private func addPaddingToLogo() {
        let padding = CGFloat(7)
        if let paddingView = resistanceLogo.setPadding(anySide: padding) {
            paddingView.backgroundColor = resistanceLogo.backgroundColor
            paddingView.alpha = resistanceLogo.alpha
            paddingView.layer.cornerRadius = 10
        }
    }
    @objc private func handleLogoTap() {
        dismiss(animated: false, completion: nil)
    }
    
    // -------------------------------------------------------------------------
    // Mark: - Game types and Navigation
    // -------------------------------------------------------------------------
    @IBAction func resumeGame(_ sender: UIButton) {
        if let savedGameState = DDEGame.getSavedGameState() {
            performSegue(withIdentifier: Segues.goToGameScreen.rawValue, sender: savedGameState)
        } else {
            DDEGame.clearSavedGame()
        
            let alert = UIAlertController(title: "Notification", message: "Saved game has been corrupted. Please start a new game!", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            
            refreshResumeButton()
        }
    }
    @IBAction func newRandomGame(_ sender: UIButton) {
        let isRandomGame = true
        performSegue(withIdentifier: Segues.goToReadyScreen.rawValue, sender: isRandomGame)
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case Segues.goToReadyScreen.rawValue:
            let readyController = segue.destination as! ReadyViewController
            let isRandom = sender as! Bool
            readyController.onClose = {[unowned self] in (isRandom ? self.startRandomGame() : self.startRandomGame())}
        case Segues.goToGameScreen.rawValue:
            let gameController = segue.destination as! GameViewController
            gameController.gameState = sender as? GameState
            gameController.dnaSequence = sender as? DnaSequence
        case Segues.goToSequences.rawValue:
            let sequencesController = segue.destination as! SequencesViewController
            sequencesController.sequences = DnaStorage.getStoredSequences()
            sequencesController.onPlay = {[unowned self] sequence in self.startCustomGame(sequence)}
        default:
            break
        }
    }
    private func startRandomGame() {
        if UIApplication.shared.applicationState == .active {
            let randomSequence = DnaSequence(length: Settings.sequenceLength)
            performSegue(withIdentifier: Segues.goToGameScreen.rawValue, sender: randomSequence)
        }
    }
    private func startCustomGame(_ sequence: DnaSequence) {
        if UIApplication.shared.applicationState == .active {
            performSegue(withIdentifier: Segues.goToGameScreen.rawValue, sender: sequence)
        }
    }
}
