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
    private var arrows: Array<ArrowView?> = []
    
    // Screen Rendering Height - the space arrows will cover during movement
    private var gameHeight: CGFloat = 0.0
    
    // How many arrows sizes would fit the game height
    private var arrowsPerGameScreen: Float = 0.0
    
    // The initial center Y for goal card
    private var goalCardOriginalCenterY: CGFloat = 0.0
    
    // The Arrow Size is comptued by AutoLayout
    @IBOutlet var maxArrowWidth: NSLayoutConstraint!
    
    // Constraint constant is adjusted based on tolerance
    @IBOutlet var goalCardHeightConstraint: NSLayoutConstraint!
    
    private var arrowSize: CGFloat = 0.0 {
        didSet {
            if arrowSize > maxArrowWidth.constant {
                arrowSize = maxArrowWidth.constant
            } else {
                maxArrowWidth.constant = arrowSize
            }
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
    
    // Percentage Progress
    @IBOutlet var progressLabel: UILabel!
    
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
        
        goalCardOriginalCenterY = goalCard.center.y
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
        initDimensions()
        if gameState != nil {
            game = DDEGame(gameState: gameState!, arrowsPerGameScreen: arrowsPerGameScreen)
        } else if dnaSequence != nil {
            game = DDEGame(dnaSequence: dnaSequence!, arrowsPerGameScreen: arrowsPerGameScreen)
        } else {
            dismiss(animated: false, completion: nil)
            return
        }
        DDEGame.clearSavedGame()
        // Init custom display timer
        displayUpdateInformer = DisplayUpdateInformer(
            onDisplayUpdate: {[unowned self] deltaTime in self.gameLoop(deltaTime)}
        )
        // Set muation callback
        game.onMutation = {[unowned self] in self.mutation()}
        // Mutation label is fully visible only when a mutation occurs
        mutationLabel.alpha = 0.0
        // Create space in the array for each arrowView
        arrows = Array(repeating: nil, count: game.state.sequence.nucleobaseSequence.count)

        initTolerance()
        initDnaView()
        initMusic()
        
        // Pause mode rendering (dnaView)
        isPaused = true
        displayUpdateInformer.resume()
    }
    private func initMusic() {
        if game.state.difficulty == .pro {
            gameMusic = DDESound(sound: .vShort200bpm)
        } else {
            gameMusic = DDESound(sound: .vShort150bpm)
        }
    }
    private func initDimensions() {
        /*
            The game height is the maximum view.frame size plus one extra arrow size
            The extra arrow size is used to start the arrow below the bottom screen edge and
                end it above the top screen edge (as arrows are positioned by center).
            The extra arrow can be viewed as two arrow halfs (1/2 at bottom and top of the screen)
         */
        arrowSize = leftGoalArrow.frame.width.rounded(.down)
        gameHeight = max(view.frame.width, view.frame.height) + arrowSize
        arrowsPerGameScreen = Float(gameHeight / arrowSize)
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
    private func initDnaView() {
        // The DnaView at the top of the screen
        let dnaView = dnaScrollView.dnaView!
        dnaView.isDrawingEnabled = false
        dnaView.baseTypes = game.state.sequence.nucleobaseTypesSequence()
        dnaView.startOffsetSegments = CGFloat(game.spacedArrowsPerScreen)
        dnaView.areMainLettersEnabled = true
        dnaView.helixOrientation = .horizontal
        dnaView.isDrawingEnabled = true
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
    private func hideArrows() {
        for arrow in arrows {
            arrow?.isHidden = true
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
            game.updateState(deltaTime, minYPercent())
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
                if let arrow = arrows[i] {
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
        }
        userInput = .none
    }

    private func renderScreen() {
        renderBeats()
        renderArrows()
        renderDnaView()
        progressLabel.text = game.state.percentCompleted.toPercentString(decimalPlaces: 0)
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
                var arrow: ArrowView! = arrows[i]
                if arrow == nil {
                    arrow = ArrowView(frame: CGRect(x: 0.0, y: 0.0, width: arrowSize, height: arrowSize))
                    arrow.direction = nucleobaseTypeToDirection[nucleobase.type]!
                    view.addSubview(arrow)
                    arrow.isUserInteractionEnabled = false
                    arrows.append(arrow)
                    arrows[i] = arrow
                }
                arrow.isHidden = false
                let goalArrow = goalArrows[arrow.direction]!
                
                let x = goalArrow.superview!.convert(goalArrow.center, to: view).x
                let goalCardAdjust = goalCardOriginalCenterY - goalCard.center.y // in case AutoLayout moved goalCard up/down
                let y = CGFloat(nucleobase.percentY) * gameHeight - arrowSize / 2 - goalCardAdjust
                
                arrow.center = CGPoint(x: x, y: y)
                
                arrow.fillColor = ArrowView.FillColor(rawValue: nucleobase.evolutionState.rawValue)!
                arrow.alpha = 1 - CGFloat(nucleobase.percentY)
            } else {
                if let arrow = arrows[i] {
                    arrow.removePadding()
                    arrow.removeFromSuperview()
                    arrows[i] = nil
                }
            }
        }
    }
    
    private func renderDnaView() {
        let dnaView = dnaScrollView.dnaView!
        
        // Make sure enough dummy trailing segments are available so that the dnaView highlight is always at left
        let requiredEndOffsetSegments = max(dnaScrollView.frame.width, dnaScrollView.frame.height) / dnaView.distanceBetweenSegments
        if dnaView.endOffsetSegments < requiredEndOffsetSegments {
            dnaView.endOffsetSegments = ceil(requiredEndOffsetSegments)
        }
        
        // Establish all segment counts
        let baseSegments: CGFloat = CGFloat(dnaView.baseTypes.count)
        let totalSegments: CGFloat = baseSegments + dnaView.startOffsetSegments + dnaView.endOffsetSegments
        let spacedArrowsPerScreen: CGFloat = CGFloat(game.spacedArrowsPerScreen)
        
        // Computer relative percentages
        let startPercent: CGFloat = CGFloat(game.state.percentCompleted) * (baseSegments + spacedArrowsPerScreen) / totalSegments
        let endAdjust: CGFloat = view.frame.height / max(view.frame.width, view.frame.height)
        let endPercent: CGFloat = startPercent + spacedArrowsPerScreen / totalSegments * endAdjust
        
        // Apply highlight and rotation
        dnaScrollView.scrollToBottom()
        dnaView.highlight(startPercent: startPercent, endPercent: endPercent)
        dnaView.rotation3D -= 0.025 * CGFloat(game.state.speed)
    }
    
    // -------------------------------------------------------------------------
    // Mark: - Mutation Animation and Sound
    // -------------------------------------------------------------------------
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
    }
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}
