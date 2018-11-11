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
    @IBOutlet var goalCard: UIView!
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
    private var beatScale: Double = 0
    
    // Tracking the last User Input (arrow direction)
    private var userInput: ArrowView.ArrowDirection? = nil
    
    private var arrows: Array<ArrowView> = []
    private var isPaused: Bool = false
    
    // Screen Rendering Height - the space arrows will cover during movement
    private var gameHeight: CGFloat = 0
    
    // How many arrows sizes would fit the game height
    private var arrowsPerGameScreen: Double = 0
    
    /*
        The goal arrows might be smaller in Portrait due to AutoLayout
        The below outlets (constraints and stack view) are used to calculate
            a "fixed-max" arrow size so that, even if the screen is rotated,
            AutoLayout produces the same outcome in Landscape also
    */
    @IBOutlet var maxArrowWidth: NSLayoutConstraint!
    @IBOutlet var beatHeightMultiplier: NSLayoutConstraint!
    @IBOutlet var goalMaxLeadingWidth: NSLayoutConstraint!
    @IBOutlet var goalMaxTrailingWidth: NSLayoutConstraint!
    @IBOutlet var goalStackEqualSpacing: UIStackView!
    @IBOutlet var goalCardHeightConstraint: NSLayoutConstraint!
    
    private var screenOrientation: UIInterfaceOrientationMask = .all
    private var arrowSize: CGFloat = 0 {
        didSet {
            maxArrowWidth.constant = arrowSize
        }
    }
    
    @IBOutlet var mutationLabel: UILabel!
    
    // -------------------------------------------------------------------------
    // Mark: - Lifecycle
    // -------------------------------------------------------------------------
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initGame()
        addAppObservers()
        initSwipes()
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
    
    // -------------------------------------------------------------------------
    // Mark: - Device Rotation
    // -------------------------------------------------------------------------
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
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return self.screenOrientation
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
        mutationLabel.alpha = 0.0
        initMusic()
        createArrows()
        
        limitArrowSize()
        gameHeight = max(view.frame.width, view.frame.height) + arrowSize // (1/2 at bottom and top)
        arrowsPerGameScreen = Double(gameHeight / arrowSize)
        
        initTolerance()
    }
    private func initMusic() {
        if game.currentGameState.difficulty == .pro {
            gameMusic = DDESound(sound: .vShort200bpm)
        } else {
            gameMusic = DDESound(sound: .vShort150bpm)
        }
    }
    private func createArrows() {
        let sequence = game.currentGameState.sequence.nucleobaseSequence
        for i in 0..<sequence.count {
            let arrowDirection = nucleobaseTypeToDirection(type: sequence[i].type)
            let arrow = ArrowView(direction: arrowDirection)
            view.addSubview(arrow)
            arrow.widthAnchor.constraint(equalTo: leftGoalArrow.widthAnchor, multiplier: 1).isActive = true
            arrow.isHidden = true
            arrows.append(arrow)
        }
    }
    private func limitArrowSize() {
        let minSize = min(view.frame.width, view.frame.height)
        let arrowsAndBeatsWidth = minSize - goalMaxLeadingWidth.constant - goalMaxTrailingWidth.constant - 5 * goalStackEqualSpacing.spacing
        let maxArrowSize = arrowsAndBeatsWidth / (2 * beatHeightMultiplier.multiplier + 4)
        arrowSize = min(maxArrowSize.rounded(.down), maxArrowWidth.constant)
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
    private func initTolerance() {
        goalCardHeightConstraint.constant = CGFloat(game.currentGameState.tolerance) * (arrowSize / 15).rounded()
        goalCard.layoutIfNeeded()
        if Settings.isToleranceVisibilityOn {
            let thickness: CGFloat = 1
            goalCard.layer.addBorder(edge: .top, color: .white, thickness: thickness)
            goalCard.layer.addBorder(edge: .bottom, color: .white, thickness: thickness)
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
    // Mark: - Swipes
    // -------------------------------------------------------------------------
    private func initSwipes() {
        if Settings.areGameSwipesOn {
            let directions: Array<UISwipeGestureRecognizer.Direction>
            directions = [.left, .down, .up, .right]
            for direction in directions {
                let swipe = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipeGesture))
                swipe.direction = direction
                swipe.delaysTouchesEnded = false
                view.addGestureRecognizer(swipe)
            }
        }
    }
    @objc func handleSwipeGesture(_ sender: UISwipeGestureRecognizer) {
        switch sender.direction {
        case .left:
            userInput = .left
        case .down:
            userInput = .down
        case .up:
            userInput = .up
        case .right:
            userInput = .right
        default:
            return
        }
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
        game.updateState(deltaTime, arrowsPerGameScreen)
        renderScreen(deltaTime)
    }
    
    private func processUserInput() {
        if userInput == nil {
            return
        }
        let sequence = game.currentGameState.sequence.nucleobaseSequence
        for i in 0..<sequence.count {
            let nucleobase = sequence[i]
            if nucleobase.isVisible && nucleobase.hitState == .none && nucleobase.percentY < 0.5 {
                let arrow = arrows[i]
                if arrow.direction != userInput {
                    nucleobase.hitState = .miss
                    mutation()
                } else {
                    if arrow.center.y >= goalCard.frame.minY && arrow.center.y <= goalCard.frame.maxY {
                        nucleobase.hitState = .hit
                    } else {
                        nucleobase.hitState = .miss
                        mutation()
                    }
                }
                break
            }
        }
        userInput = .none
    }

    private func renderScreen(_ deltaTime: CFTimeInterval) {
        renderBeats(deltaTime)
        renderArrows()
    }

    private func renderBeats(_ deltaTime: CFTimeInterval) {
        beatScale += Double(deltaTime) * game.currentGameState.speed
        if beatScale >= 1 {
            beatScale -= 1
        }
        scaleBeat(leftBeat, CGFloat(beatScale))
        scaleBeat(rightBeat, CGFloat(beatScale))
    }
    private func scaleBeat(_ beat: UILabel, _ scale: CGFloat) {
        beat.transform = .identity
        beat.layer.cornerRadius = beat.frame.width / 2
        beat.transform = CGAffineTransform(scaleX: scale, y: scale)
    }
    
    private func renderArrows() {
        let sequence = game.currentGameState.sequence.nucleobaseSequence
        let minY = goalCard.frame.minY
        for i in 0..<sequence.count {
            let nucleobase = sequence[i]
            if nucleobase.isVisible {
                let arrow = arrows[i]
                arrow.isHidden = false
                let goalArrow = goalArrows[arrow.direction]!
                
                let x = goalArrow.absoluteCenter().x
                let y = CGFloat(nucleobase.percentY) * gameHeight - arrowSize / 2
                arrow.center = CGPoint(x: x, y: y)
                
                if nucleobase.hitState == .none {
                    if arrow.center.y < minY {
                        nucleobase.hitState = .miss
                        mutation()
                    }
                }
                
                arrow.fillColor = ArrowView.FillColor(rawValue: nucleobase.hitState.rawValue)!
                arrow.alpha = 1 - CGFloat(nucleobase.percentY)
            } else {
                arrows[i].isHidden = true
            }
        }
    }
    
    private func mutation() {
        mutationSound.play()
        mutationLabel.alpha = 1.0
        UIView.animate(withDuration: 2.0
            , animations: {
                self.mutationLabel.alpha = 0.0
            }
        )
    }
    
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
