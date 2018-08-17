//
//  ReadyViewController.swift
//  Dance Dance Evolution
//
//  Created by Cristian Buse on 15/08/2018.
//  Copyright © 2018 Hans Guntersson. All rights reserved.
//

import UIKit

class ReadyViewController: CustomViewController {
    private var isGameScreenAlreadyPresented: Bool = false
    private var areYouReadySound: DDESound?
    
    @IBOutlet weak var countLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Add tap gesture to allow user to skip the animation
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        self.view.addGestureRecognizer(tapGesture)
        
        // Prepare countLabel
        countLabel.text = String(Settings.getCountdownDurationInSeconds())
        countLabel.layer.cornerRadius = countLabel.frame.width / 2
        
        // Prepare Sound
        areYouReadySound = DDESound(sound: .areYouReady)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        areYouReadySound?.playSound(stopIfAlreadyPlaying: false)
        animateCountdown(downFrom: Settings.getCountdownDurationInSeconds())
    }
    
    func animateCountdown(downFrom start: Int) {
        self.countLabel.text = "\(start)"
        
        UIView.animate(withDuration: 1.0, delay: 0.0, options: []
            , animations: {
                self.countLabel.transform = CGAffineTransform(scaleX: 2.5, y: 2.5)
                self.view.layoutIfNeeded()
            }
            , completion: { (finished: Bool) in
                self.countLabel.transform = CGAffineTransform(scaleX: 1, y: 1)
                if start > 1 {
                    self.countLabel.layer.removeAllAnimations()
                    self.animateCountdown(downFrom: start - 1)
                } else {
                    if !self.isGameScreenAlreadyPresented {
                        self.goToGameScreen()
                    }
                }
            }
        )
    }
    
    @objc func handleTap() {
        isGameScreenAlreadyPresented = true
        goToGameScreen()
    }
    
    func goToGameScreen() {
        areYouReadySound = nil
        performSegue(withIdentifier: "goToGameScreen", sender: self)
    }
}
