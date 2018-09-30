//  Created by Cristian Buse on 05/08/2018.
//  Copyright © 2018 Hans Guntersson. All rights reserved.

import UIKit

class MainViewController: HiddenStatusBarController {
    @IBOutlet var resistanceLogo: PaddedImageView!
    @IBOutlet var btnResume: UIButton!
    @IBOutlet var btnStart: UIButton!
    @IBOutlet var btnSetup: UIButton!
    @IBOutlet var btnTest: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addTapGestures()
        addPaddingToLogo()
        addBorderToButtons()
        
        refreshResumeButton()
    }
    
    private func refreshResumeButton() {
        btnResume.isHidden = !DDEGame.isGameAvailableForResume()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        refreshResumeButton()
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
    
    private func addBorderToButtons() {
        addBorderToButton(button: btnResume, borderWidth: 1.0, borderColor: UIColor.white, cornerRadius: 10.0)
        addBorderToButton(button: btnStart, borderWidth: 1.0, borderColor: UIColor.white, cornerRadius: 10.0)
        addBorderToButton(button: btnSetup, borderWidth: 1.0, borderColor: UIColor.white, cornerRadius: 10.0)
        
        addBorderToButton(button: btnTest, borderWidth: 1.0, borderColor: UIColor.carmine(), cornerRadius: 10.0)
    }
    
    private func addBorderToButton(button: UIButton, borderWidth: CGFloat, borderColor: UIColor, cornerRadius: CGFloat) {
        button.layer.borderWidth = borderWidth
        button.layer.borderColor = borderColor.cgColor
        button.layer.cornerRadius = cornerRadius
    }
    
    @objc private func handleLogoTap() {
        dismiss(animated: false, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
            case "goToReadyScreen":
                let ready = segue.destination as! ReadyViewController
                ready.onClose = {[unowned self] in self.goToGameScreen(resumeSavedGame: false)}
            case "goToGameScreen":
                let game = segue.destination as! GameViewController
                game.resumeSavedGame = sender as! Bool
        default:
            break
        }
    }
    
    @IBAction func resumeGame(_ sender: UIButton) {
        goToGameScreen(resumeSavedGame: true)
    }
    
    private func goToGameScreen(resumeSavedGame: Bool) {
        if UIApplication.shared.applicationState == .active {
            performSegue(withIdentifier: "goToGameScreen", sender: resumeSavedGame)
        }
    }
}
