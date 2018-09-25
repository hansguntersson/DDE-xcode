//  Created by Cristian Buse on 15/08/2018.
//  Copyright © 2018 Hans Guntersson. All rights reserved.

import UIKit

class ReadyViewController: HiddenStatusBarController {
    private var areYouReadySound = DDESound(sound: .areYouReady)
    
    @IBOutlet var countLabel: UILabel!
    
    // Callback that will run on Controller's completion of dismissal
    var onClose: (() -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addTapGestures()
        prepareCountLabel()
    }
    
    private func addTapGestures() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        self.view.addGestureRecognizer(tapGesture)
    }
    
    @objc private func handleTap() {
        close()
    }
    
    private func prepareCountLabel() {
        countLabel.text = String(Settings.countdownDuration)
        countLabel.layer.cornerRadius = countLabel.frame.width / 2
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        areYouReadySound.play(stopIfAlreadyPlaying: false)
        animateCountdown(downFrom: Settings.countdownDuration)
    }
    
    private func animateCountdown(downFrom start: Int) {
        self.countLabel.text = "\(start)"
        
        UIView.animate(withDuration: 1.0, delay: 0.0, options: []
            , animations: {
                self.countLabel.transform = CGAffineTransform(scaleX: 2.5, y: 2.5)
                self.view.layoutIfNeeded()
            }
            , completion: { (finished: Bool) in
                self.countLabel.transform = .identity
                if start > 1 {
                    self.animateCountdown(downFrom: start - 1)
                } else {
                    self.close()
                }
            }
        )
    }
    
    private func close() {
        dismiss(animated: false, completion: onClose)
    }
}
