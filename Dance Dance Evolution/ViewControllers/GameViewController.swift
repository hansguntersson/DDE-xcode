//  Created by Daniel Harlos on 19/07/2018.
//  Copyright © 2018 Hans Guntersson. All rights reserved.

import UIKit

class GameViewController: HiddenStatusBarController {
    var resumeSavedGame: Bool = false
    var appActive: Bool = true
    var readyViewController: ReadyViewController? = nil
    
    private var gameMusic: DDESound!
    private lazy var mutationSound = DDESound(sound: .mutation)
    
    private var displayUpdateInformer: DisplayUpdateInformer!
    private var game: DDEGame!
    
    // Goal Arrows - Static Arrow at the Top
    @IBOutlet var leftGoalArrow: UIImageView!
    @IBOutlet var downGoalArrow: UIImageView!
    @IBOutlet var upGoalArrow: UIImageView!
    @IBOutlet var rightGoalArrow: UIImageView!
    // The 2 beats left and right of the goal arrows
    @IBOutlet var leftBeat: UILabel!
    @IBOutlet var rightBeat: UILabel!
    
    private var beatSizePercent: CGFloat = 1
    
    private var userInput: DDEGame.UserInput = .none
    
    // MARK: View Controller Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initGame()
        addAppObservers()
        test()
    }
    
    private func initGame() {
        game = DDEGame(resumeSavedState: resumeSavedGame)

        displayUpdateInformer = DisplayUpdateInformer(
            onDisplayUpdate: {[unowned self] deltaTime in self.gameLoop(deltaTime)}
        )
        initMusic()
    }
    
    private func initMusic() {
        if Settings.difficulty == .pro {
            gameMusic = DDESound(sound: .vShort200bpm)
        } else {
            gameMusic = DDESound(sound: .vShort150bpm)
        }
        gameMusic.play(stopIfAlreadyPlaying: false)
    }
    
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
        displayUpdateInformer?.pause()
        gameMusic.pause()
        hideArrows()
        readyViewController?.dismiss(animated: false, completion: nil)
    }

    @objc func appDidEnterBackground() {
        game.saveState()
    }
    
    @objc func appWillEnterForeground() {
        game.clearSavedGame()
    }
    
    @objc func appDidBecomeActive() {
        showArrows()
        performSegue(withIdentifier: "goToReadyScreen", sender: self)
    }
    
    private func continuePlay() {
        if UIApplication.shared.applicationState == .active {
            displayUpdateInformer.resume()
            gameMusic.play()
        }
    }
    
    // Prevent cheating - on the View Recently Used Apps (phones before iphoneX - double-tap on Home)
    private func hideArrows() {
        
    }
    
    private func showArrows() {

    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case "goToReadyScreen":
            readyViewController = (segue.destination as! ReadyViewController)
            readyViewController!.onClose = {[unowned self] in self.continuePlay()}
        default:
            break
        }
    }
    
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        displayUpdateInformer.resume()
    }
    
    private func countdownGameIfNeeded() {
        
        
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        displayUpdateInformer?.pause()
    }
    
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
        renderArrows(deltaTime)
    }

    private func renderBeats(_ deltaTime: CFTimeInterval) {
        beatSizePercent = beatSizePercent - CGFloat(deltaTime) * game.gameState.speed
        if beatSizePercent <= 0 {
            beatSizePercent += 1
        }
        leftBeat.transform = .identity
        leftBeat.layer.cornerRadius = leftBeat.frame.width / 2
        leftBeat.transform = CGAffineTransform(scaleX: beatSizePercent, y: beatSizePercent)
        
        rightBeat.transform = .identity
        rightBeat.layer.cornerRadius = rightBeat.frame.width / 2
        rightBeat.transform = CGAffineTransform(scaleX: beatSizePercent, y: beatSizePercent)
    }
    
    var testLArrow = ArrowView(direction: .left)
    var testRArrow = ArrowView(direction: .right)
    var testUArrow = ArrowView(direction: .up)
    var testDArrow = ArrowView(direction: .down)
    
    private func test() {
        view.addSubview(testLArrow)
        view.addSubview(testRArrow)
        view.addSubview(testUArrow)
        view.addSubview(testDArrow)
        
        testLArrow.widthAnchor.constraint(equalTo: leftGoalArrow.widthAnchor, multiplier: 1).isActive = true
        testRArrow.widthAnchor.constraint(equalTo: rightGoalArrow.widthAnchor, multiplier: 1).isActive = true
        testUArrow.widthAnchor.constraint(equalTo: upGoalArrow.widthAnchor, multiplier: 1).isActive = true
        testDArrow.widthAnchor.constraint(equalTo: downGoalArrow.widthAnchor, multiplier: 1).isActive = true
    }
    
    var firstPass: Bool = true
    
    private func renderArrows(_ deltaTime: CFTimeInterval) {
        // Ignoring deltaTime for this test
        
        if firstPass {
            testLArrow.center = CGPoint(x: 0, y: view.frame.height * 0.25)
            testRArrow.center = CGPoint(x: 0, y: view.frame.height * 0.5)
            testUArrow.center = CGPoint(x: 0, y: view.frame.height * 0.75)
            testDArrow.center = CGPoint(x: 0, y: view.frame.height)
            firstPass = false
        }
        
        setTempArrow(targetArrow: testLArrow, goalArrow: leftGoalArrow)
        setTempArrow(targetArrow: testRArrow, goalArrow: rightGoalArrow)
        setTempArrow(targetArrow: testUArrow, goalArrow: upGoalArrow)
        setTempArrow(targetArrow: testDArrow, goalArrow: downGoalArrow)
    }
    
    private func setTempArrow(targetArrow: ArrowView, goalArrow: UIView) {
        let x = goalArrow.absoluteCenter().x
        var y = targetArrow.center.y - 5 * game.gameState.speed
        if y < 0 {
            y = view.frame.maxY
        }
        targetArrow.center = CGPoint(x: x, y: y)
        targetArrow.alpha = 1 - y / view.frame.maxY
        
        if targetArrow.center.y > view.center.y {
            targetArrow.fillColor = .none
        } else if targetArrow.center.y > view.frame.height / 4 {
            targetArrow.fillColor = .hit
        } else {
            targetArrow.fillColor = .miss
        }
    }
    
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
