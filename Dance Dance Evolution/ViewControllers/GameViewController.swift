//  Created by Daniel Harlos on 19/07/2018.
//  Copyright © 2018 Hans Guntersson. All rights reserved.

import UIKit

class GameViewController: HiddenStatusBarController {
    // -------------------------------------------------------------------------
    // Mark: - Variables and Outlets
    // -------------------------------------------------------------------------
    private enum Segues: String {
        case goToReadyScreen = "goToReadyScreen"
    }
    
    /*
        In order to start a game, the gameState object (for resumed games) or
        the DNASequence object (for new games) must be set. One way this could
        be done is in the PrepareForSegue function of the caller controller.
    */
    var gameState: GameState? = nil
    var dnaSequence: DnaSequence? = nil
    private var isNewGame: Bool = false
    private var isFirstTimeViewAppears: Bool = true
    
    /*
        The readyViewController will be displayed whenever a game is resumed
        to help the player remember where the game was left.
    */
    var readyViewController: ReadyViewController? = nil
    
    // The 2 sounds that can be played during the game
    private var gameMusic: DDESound!
    private lazy var mutationSound = DDESound(sound: .mutation)
    
    // Object informing how much time is available until next frame is drawn
    private var displayUpdateInformer: DisplayUpdateInformer!
    
    // The game "model" responsible for creating, updating or saving game states
    private var game: DDEGame!
    
    /*
        Goal Arrows - Static Arrows at the Top
        The goal arrows are using AutoLayout for positioning
        Game arrows are syncing with the corresponding goal arrow's center X
     */
    @IBOutlet var leftGoalArrow: UIImageView!
    @IBOutlet var downGoalArrow: UIImageView!
    @IBOutlet var upGoalArrow: UIImageView!
    @IBOutlet var rightGoalArrow: UIImageView!
    // Dictionary to easily retrieve certain goal arrow
    private lazy var goalArrows: Dictionary<ArrowView.ArrowDirection,UIView> = [
        .left: self.leftGoalArrow
        , .right: self.rightGoalArrow
        , .up: self.upGoalArrow
        , .down: self.downGoalArrow
    ]
    
    // The 2 beats left and right of the goal arrows
    @IBOutlet var leftBeat: UILabel!
    @IBOutlet var rightBeat: UILabel!
    // Tracks the beat scale at any given time
    private var beatScale: CGFloat = 1
    
    // Tracking the last User Input (arrow direction)
    private var userInput: DDEGame.UserInput = .none
    
    // Array of game Arrows
    private var arrows: Array<ArrowView> = []
    
    // Paused State
    private var isPaused: Bool = false
    
    // -------------------------------------------------------------------------
    // Mark: - Lifecycle
    // -------------------------------------------------------------------------
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initGame()
        addAppObservers()
        
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if isFirstTimeViewAppears {
            isFirstTimeViewAppears = false
            if isNewGame {
                resumePlay()
            } else {
                isPaused = true
                renderScreen(0)
                performSegue(withIdentifier: Segues.goToReadyScreen.rawValue, sender: self)
            }
        } else {
            resumePlay()
        }
    }
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        pausePlay()
    }
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        if self.isPaused {
            hideArrows()
            // Make sure arrows still look good while rotating device when game is paused
            coordinator.animate(alongsideTransition: nil, completion: { [unowned self] _ in
                self.showArrows()
                self.renderBeats(0)
            })
        }
    }

    // -------------------------------------------------------------------------
    // Mark: - Game Init
    // -------------------------------------------------------------------------
    private func initGame() {
        if gameState != nil {
            game = DDEGame(gameState: gameState!)
            isNewGame = false
        } else if dnaSequence != nil {
            game = DDEGame(dnaSequence: dnaSequence!)
            isNewGame = true
        } else {
            dismiss(animated: false, completion: nil)
            return
        }
        
        displayUpdateInformer = DisplayUpdateInformer(
            onDisplayUpdate: {[unowned self] deltaTime in self.gameLoop(deltaTime)}
        )
        initMusic()
        createArrows()
    }
    private func initMusic() {
        if game.gameState.difficulty == .pro {
            gameMusic = DDESound(sound: .vShort200bpm)
        } else {
            gameMusic = DDESound(sound: .vShort150bpm)
        }
    }

    // -------------------------------------------------------------------------
    // Mark: - Application Observers
    // -------------------------------------------------------------------------
    private func addAppObservers() {
        NotificationCenter.default.addObserver(self
            , selector: #selector(appWillResignActive)
            , name: UIApplication.willResignActiveNotification
            , object: nil)
        NotificationCenter.default.addObserver(self
            , selector: #selector(appDidEnterBackground)
            , name: UIApplication.didEnterBackgroundNotification
            , object: nil)
        NotificationCenter.default.addObserver(self
            , selector: #selector(appWillEnterForeground)
            , name: UIApplication.willEnterForegroundNotification
            , object: nil)
        NotificationCenter.default.addObserver(self
            , selector: #selector(appDidBecomeActive)
            , name: UIApplication.didBecomeActiveNotification
            , object: nil)
    }
    @objc func appWillResignActive() {
        pausePlay()
        hideArrows()
        readyViewController?.dismiss(animated: false, completion: nil)
    }
    @objc func appDidEnterBackground() {
        game.saveState()
    }
    @objc func appWillEnterForeground() {
        DDEGame.clearSavedGame()
    }
    @objc func appDidBecomeActive() {
        showArrows()
        performSegue(withIdentifier: Segues.goToReadyScreen.rawValue, sender: self)
    }
    
    // -------------------------------------------------------------------------
    // Mark: - Navigation
    // -------------------------------------------------------------------------
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case Segues.goToReadyScreen.rawValue:
            readyViewController = (segue.destination as! ReadyViewController)
            readyViewController!.onClose = {[unowned self] in self.resumePlay()}
        default:
            break
        }
    }
    
    // -------------------------------------------------------------------------
    // Mark: - Resume/Pause Gameplay
    // -------------------------------------------------------------------------
    private func resumePlay() {
        if UIApplication.shared.applicationState == .active {
            displayUpdateInformer?.resume()
            gameMusic?.play()
            isPaused = false
        }
    }
    private func pausePlay() {
        displayUpdateInformer?.pause()
        gameMusic?.pause()
        isPaused = true
    }
    
    // -------------------------------------------------------------------------
    // Mark: - Prevent cheating
    // -------------------------------------------------------------------------
    /*
        While on the "View Recently Used Apps" screen the user would see all
        arrows as "freezed" and could basically memorize their order
        (phones before iPhoneX - double-tap on Home)
    */
    private func hideArrows() {
        for arrow in arrows {
            arrow.isHidden = true
        }
    }
    private func showArrows() {
        renderArrows()
    }
    
    // -------------------------------------------------------------------------
    // Mark: - Game Loop and Rendering
    // -------------------------------------------------------------------------
    private func gameLoop(_ deltaTime: CFTimeInterval) {
        processUserInput()
        game.updateState(deltaTime)
        renderScreen(deltaTime)
    }
    
    private func processUserInput() {
        //print(userInput)
    }
    
    private func renderScreen(_ deltaTime: CFTimeInterval) {
        renderBeats(deltaTime)
        renderArrows()
    }

    private func renderBeats(_ deltaTime: CFTimeInterval) {
        beatScale = beatScale - CGFloat(deltaTime) * game.gameState.speed
        if beatScale <= 0 {
            beatScale += 1
        }
        scaleBeat(leftBeat, beatScale)
        scaleBeat(rightBeat, beatScale)
    }
    private func scaleBeat(_ beat: UILabel, _ scale: CGFloat) {
        beat.transform = .identity
        beat.layer.cornerRadius = beat.frame.width / 2
        beat.transform = CGAffineTransform(scaleX: scale, y: scale)
    }
    
    
    
    
    
    
    
    
    
    private func nucleobaseTypeToDirection(type: DnaSequence.NucleobaseType) -> ArrowView.ArrowDirection {
        switch type {
        case .adenine:
            return .down
        case .cytosine:
            return .left
        case .guanine:
            return .right
        case .thymine:
            return .up
        }
    }
    
    // TODO - Move this up to INIT!!!!!!!!!!!!!!!!!!!!!!!!
    private func createArrows() {
        let sequence = game.gameState.sequence.nucleobaseSequence
        for i in 0..<sequence.count {
            let arrow = ArrowView(direction: nucleobaseTypeToDirection(type: sequence[i].type))
            view.addSubview(arrow)
            arrow.widthAnchor.constraint(equalTo: leftGoalArrow.widthAnchor, multiplier: 1).isActive = true
            arrow.isHidden = true
            arrows.append(arrow)
        }
    }
    
    private func renderArrows() {
        let sequence = game.gameState.sequence.nucleobaseSequence
        for i in 0..<sequence.count {
            let nucleobase = sequence[i]
            if nucleobase.isVisible {
                let arrow = arrows[i]
                arrow.isHidden = false
                let goalArrow = goalArrows[arrow.direction]!
                
                let x = goalArrow.absoluteCenter().x
                let y = CGFloat(nucleobase.percentY) * self.view.frame.height
                
                arrow.center = CGPoint(x: x, y: y)
                arrow.fillColor = ArrowView.FillColor(rawValue: nucleobase.hitState.rawValue)!
                arrow.alpha = 1 - CGFloat(nucleobase.percentY)
            } else {
                arrows[i].isHidden = true
            }
        }
    }
    
//    private func setTempArrow(targetArrow: ArrowView, goalArrow: UIView) {
//        let x = goalArrow.absoluteCenter().x
//        var y = targetArrow.center.y - 5 * game.gameState.speed
//        if y < 0 {
//            y = view.frame.maxY
//        }
//        targetArrow.center = CGPoint(x: x, y: y)
//        targetArrow.alpha = 1 - y / view.frame.maxY
//
//        if targetArrow.center.y > view.center.y {
//            targetArrow.fillColor = .none
//        } else if targetArrow.center.y > view.frame.height / 4 {
//            targetArrow.fillColor = .hit
//        } else {
//            targetArrow.fillColor = .miss
//        }
//    }
//
    
    
    // -------------------------------------------------------------------------
    // Mark: - Cleaning
    // -------------------------------------------------------------------------
    @IBAction func goToMainMenu(_ sender: UIButton) {
        clean()
        dismiss(animated: false, completion: nil)
    }
    private func clean() {
        displayUpdateInformer.close()
        displayUpdateInformer = nil
    }
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}
