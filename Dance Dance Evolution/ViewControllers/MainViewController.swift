//  Created by Cristian Buse on 05/08/2018.
//  Copyright © 2018 Hans Guntersson. All rights reserved.

import UIKit

class MainViewController: HiddenStatusBarController {
    @IBOutlet var resistanceLogo: PaddedImageView!
    @IBOutlet var btnResume: UIButton!
    
    private enum Segues: String {
        case goToGameScreen = "goToGameScreen"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addTapGestures()
        addPaddingToLogo()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        refreshResumeButton()
    }
    
    private func refreshResumeButton() {
        btnResume.isHidden = !DDEGame.isGameAvailableForResume()
    }
    
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
            case Segues.goToGameScreen.rawValue:
                let gameController = segue.destination as! GameViewController
                gameController.gameState = sender as? GameState
                gameController.dnaSequence = sender as? DnaSequence
            default:
                break
        }
    }
    
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
}
