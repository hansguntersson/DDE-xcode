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
        be done is in the PrepareForSegue function of the presenting controller
    */
    var gameState: GameState? = nil
    var dnaSequence: DnaSequence? = nil
    
    /*
        The readyViewController will be displayed whenever a game is resumed
        to help the player remember where the game was left and also for a new
        or resumed game
    */
    var readyViewController: ReadyViewController? = nil
    
    // The sounds that can be played during the game
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
    // Dictionary to easily retrieve certain goal arrow by direction
    private lazy var goalArrows: Dictionary<ArrowView.ArrowDirection,UIView> = [
        .left: self.leftGoalArrow
        , .right: self.rightGoalArrow
        , .up: self.upGoalArrow
        , .down: self.downGoalArrow
    ]
    
    // The 2 beats left and right of the goal arrows
    @IBOutlet var leftBeat: UILabel!
    @IBOutlet var rightBeat: UILabel!
    
    // Tracking the last User Input (arrow direction)
    private var userInput: ArrowView.ArrowDirection? = nil
    
    // Game Arrows
    private var arrows: Array<ArrowView> = []
    
    // Screen Rendering Height - the space arrows will cover during movement
    private var gameHeight: CGFloat = 0
    
    // How many arrows sizes would fit the game height
    private var arrowsPerGameScreen: Float = 0
    
    /*
        The goal arrows might be smaller in Portrait due to AutoLayout
        The below outlets (constraints and stack view) are used to calculate
            a "fixed-max" arrow size so that, even if the screen is rotated,
            AutoLayout produces the same outcome in any Orientation
    */
    @IBOutlet var maxArrowWidth: NSLayoutConstraint!
    @IBOutlet var beatHeightMultiplier: NSLayoutConstraint!
    @IBOutlet var goalMaxLeadingWidth: NSLayoutConstraint!
    @IBOutlet var goalMaxTrailingWidth: NSLayoutConstraint!
    @IBOutlet var goalStackEqualSpacing: UIStackView!
    @IBOutlet var goalCardHeightConstraint: NSLayoutConstraint!
    
    private var arrowSize: CGFloat = 0 {
        didSet {
            maxArrowWidth.constant = arrowSize
        }
    }
    
    @IBOutlet var mutationLabel: UILabel!
    
    // Mapping
    private var nucleobaseTypeToDirection: Dictionary<DnaSequence.NucleobaseType,ArrowView.ArrowDirection>
        = [.cytosine: .left, .adenine: .down, .thymine: .up, .guanine: .right]
    private var directionToNucleobaseType: Dictionary<ArrowView.ArrowDirection,DnaSequence.NucleobaseType>
        = [.left: .cytosine, .down: .adenine, .up: .thymine, .right: .guanine]
    
    // DnaScrollView
    @IBOutlet var dnaScrollView: DnaScrollView!
    
    // Paused flag
    private var isPaused: Bool = true
    
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
        
        renderScreen()
        performSegue(withIdentifier: Segues.goToReadyScreen.rawValue, sender: self)
    }
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        pausePlay()
    }

    // -------------------------------------------------------------------------
    // Mark: - Game Init
    // -------------------------------------------------------------------------
    private func initGame() {
        if gameState != nil {
            game = DDEGame(gameState: gameState!)
        } else if dnaSequence != nil {
            game = DDEGame(dnaSequence: dnaSequence!)
        } else {
            dismiss(animated: false, completion: nil)
            return
        }
        
        displayUpdateInformer = DisplayUpdateInformer(
            onDisplayUpdate: {[unowned self] deltaTime in self.gameLoop(deltaTime)}
        )
        
        game.onMutation = {[unowned self] in self.mutation()}
        mutationLabel.alpha = 0.0
        
        initMusic()
        
        createArrows()
        limitArrowSize()
        
        /*
            The game height is the maximum view.frame size plus one extra arrow size
            The extra arrow size is used to start the arrow below the bottom screen edge and
                end it above the top screen edge (as arrows are position by center).
            Basically the extra arrow is made of two arrow halfs (1/2 at bottom and 1/2 at top)
        */
        gameHeight = max(view.frame.width, view.frame.height) + arrowSize
        arrowsPerGameScreen = Float(gameHeight / arrowSize)
        
        // The DnaView at the top of the screen
        let dnaView = dnaScrollView.dnaView!
        dnaView.isDrawingEnabled = false
        dnaView.baseTypes = game.state.sequence.nucleobaseTypesSequence()
        dnaView.helixOrientation = .horizontal
        dnaView.startOffsetSegments = CGFloat(arrowsPerGameScreen)
        dnaView.isDrawingEnabled = true
        
        initTolerance()
    }
    private func initMusic() {
        if game.state.difficulty == .pro {
            gameMusic = DDESound(sound: .vShort200bpm)
        } else {
            gameMusic = DDESound(sound: .vShort150bpm)
        }
    }
    private func createArrows() {
        let sequence = game.state.sequence.nucleobaseSequence
        for i in 0..<sequence.count {
            let arrowDirection = nucleobaseTypeToDirection[sequence[i].type]!
            let arrow = ArrowView(direction: arrowDirection)
            view.addSubview(arrow)
            arrow.widthAnchor.constraint(equalTo: leftGoalArrow.widthAnchor, multiplier: 1).isActive = true
            arrow.isHidden = true
            arrow.isUserInteractionEnabled = false
            arrows.append(arrow)
        }
    }
    private func limitArrowSize() {
        let minSize = min(view.frame.width, view.frame.height)
        let arrowsAndBeatsWidth = minSize - goalMaxLeadingWidth.constant - goalMaxTrailingWidth.constant - 5 * goalStackEqualSpacing.spacing
        let maxArrowSize = arrowsAndBeatsWidth / (2 * beatHeightMultiplier.multiplier + 4)
        arrowSize = min(maxArrowSize.rounded(.down), maxArrowWidth.constant)
    }
    private func initTolerance() {
        goalCardHeightConstraint.constant = CGFloat(game.state.tolerance) * (arrowSize / 15).rounded()
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
        displayUpdateInformer?.resume()
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
            case .left:  userInput = .left
            case .down:  userInput = .down
            case .up:    userInput = .up
            case .right: userInput = .right
            default: return
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
            isPaused = false
            displayUpdateInformer?.resume()
            gameMusic?.play()
            readyViewController = nil
        }
    }
    private func pausePlay() {
        isPaused = true
        displayUpdateInformer?.pause()
        gameMusic?.pause()
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
    
    // -------------------------------------------------------------------------
    // Mark: - Transitions
    // -------------------------------------------------------------------------
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        displayUpdateInformer.pause()
        hideArrows()
        coordinator.animate(alongsideTransition: nil, completion: { [unowned self] _ in
            self.displayUpdateInformer.resume()
        })
    }
    
    // -------------------------------------------------------------------------
    // Mark: - Game Loop and Rendering
    // -------------------------------------------------------------------------
    private func gameLoop(_ deltaTime: CFTimeInterval) {
        if !isPaused {
            processUserInput()
            game.updateState(deltaTime, arrowsPerGameScreen, minYPercent())
        }
        renderScreen()
        if game.hasEnded() && !mutationSound.isPlaying() {
            endGame()
        }
    }
    
    /*
        To calculate the center of the arrow we use nucleobase.percentY * gameHeight - arrowSize / 2
        and then we compare that center.Y with goalCard.frame.minY to see if the arrow has past beyond the threshold
        Since the game has no idea of what goalCard, gameHeight and arrowSize are, we directly pass the percentage
        needed to compare with nucleobase.percentY as minYPercent - See gameLoop above
    */
    private func minYPercent() -> Float {
        return Float((goalCard.frame.minY + arrowSize / 2) / gameHeight)
    }
    
    private func processUserInput() {
        if userInput == nil {
            return
        }
        let sequence = game.state.sequence.nucleobaseSequence
        for i in 0..<sequence.count {
            let nucleobase = sequence[i]
            if nucleobase.isActive && nucleobase.evolutionState == .uncertain && nucleobase.percentY < 0.5 {
                let arrow = arrows[i]
                if arrow.direction != userInput {
                    let mutatedType = directionToNucleobaseType[userInput!]!
                    nucleobase.mutate(to: mutatedType)
                    mutation()
                } else {
                    if arrow.center.y >= goalCard.frame.minY && arrow.center.y <= goalCard.frame.maxY {
                        nucleobase.preserve()
                    } else {
                        nucleobase.mutateToRandom()
                        mutation()
                    }
                }
                break
            }
        }
        userInput = .none
    }

    private func renderScreen() {
        renderBeats()
        renderArrows()
    }

    private func renderBeats() {
        scaleBeat(leftBeat, CGFloat(game.state.beatsScale))
        scaleBeat(rightBeat, CGFloat(game.state.beatsScale))
    }
    private func scaleBeat(_ beat: UILabel, _ scale: CGFloat) {
        beat.transform = .identity
        beat.layer.cornerRadius = beat.frame.width / 2
        beat.transform = CGAffineTransform(scaleX: scale, y: scale)
    }
    
    private func renderArrows() {
        let sequence = game.state.sequence.nucleobaseSequence
        for i in 0..<sequence.count {
            let nucleobase = sequence[i]
            if nucleobase.isActive {
                let arrow = arrows[i]
                arrow.isHidden = false
                let goalArrow = goalArrows[arrow.direction]!
                
                let x = goalArrow.absoluteCenter().x
                let y = CGFloat(nucleobase.percentY) * gameHeight - arrowSize / 2
                arrow.center = CGPoint(x: x, y: y)
                
                arrow.fillColor = ArrowView.FillColor(rawValue: nucleobase.evolutionState.rawValue)!
                arrow.alpha = 1 - CGFloat(nucleobase.percentY)
            } else {
                arrows[i].isHidden = true
            }
        }
    }
    
    private func renderDnaView() {
        let dnaView = dnaScrollView.dnaView!
        
        print(dnaView)
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
    // Mark: - End Game & Cleaning
    // -------------------------------------------------------------------------
    private func endGame() {
        clean()
        dismiss(animated: false, completion: nil)
    }
    @IBAction func goBack(_ sender: UIButton) {
        endGame()
    }
    private func clean() {
        displayUpdateInformer.close()
        displayUpdateInformer = nil
        arrows = []
    }
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}
