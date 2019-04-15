//  Created by Cristian Buse on 03/03/2019.
//  Copyright © 2019 Hans Guntersson. All rights reserved.

import UIKit

class DnaAnimation {
    // Animation requires a DnaView to operate on
    unowned let viewToAnimate: DnaView
    
    // Calls the Animation Loop every frame
    private var displayUpdateInformer: DisplayUpdateInformer!
    
    // Time
    let totalAnimationTime: CFTimeInterval
    private(set) var timeLeft: CFTimeInterval
    
    // DnaView Torsion
    let startTorsion: CGFloat
    let targetTorsion: CGFloat
    
    // DnaView Rotation
    let startRotation: CGFloat
    let targetRotation: CGFloat
    
    // Indicates whether the animation is still running or not
    private(set) var isFinished: Bool = false
    
    // Callback when finished
    private var onFinished: (() -> ())? = nil
    
    // -------------------------------------------------------------------------
    // Mark: - Init
    // -------------------------------------------------------------------------
    init(withDuration: TimeInterval, dnaView: DnaView, targetTorsion: CGFloat, targetRotation: CGFloat, onFinished: (() -> ())?) {
        self.viewToAnimate = dnaView

        // Time
        self.totalAnimationTime = withDuration
        self.timeLeft = totalAnimationTime

        // Torsion
        self.startTorsion = viewToAnimate.torsion
        self.targetTorsion = targetTorsion

        // Angle
        self.targetRotation = targetRotation.truncatingRemainder(dividingBy: 2 * CGFloat.pi)
        var tempStart = viewToAnimate.rotation3D.truncatingRemainder(dividingBy: 2 * CGFloat.pi)
        if dnaView.editMode {
            if tempStart > self.targetRotation {
                tempStart -= 2 * CGFloat.pi
            }
            if self.targetRotation - tempStart < CGFloat.pi {
                tempStart -= 2 * CGFloat.pi
            }
        }
        self.startRotation = tempStart
        
        // Callback
        self.onFinished = onFinished
    
        defer {
            initInformer()
        }
    }
    
    // -------------------------------------------------------------------------
    // Mark: - Animation
    // -------------------------------------------------------------------------
    private func initInformer() {
        displayUpdateInformer = DisplayUpdateInformer(
            onDisplayUpdate: {[unowned self] deltaTime in self.animationLoop(deltaTime)}
        )
        displayUpdateInformer.resume()
    }
    private func animationLoop(_ deltaTime: CFTimeInterval) {
        timeLeft -= deltaTime
        if timeLeft < 0 {
            timeLeft = 0.0
        }
        if !isFinished {
            viewToAnimate.isDrawingEnabled = false
            viewToAnimate.torsion = COGO.interpolate2D(x: CGFloat(timeLeft), x1: CGFloat(totalAnimationTime), y1: startTorsion, x2: 0, y2: targetTorsion) ?? targetTorsion
            viewToAnimate.rotation3D = COGO.interpolate2D(x: CGFloat(timeLeft), x1: CGFloat(totalAnimationTime), y1: startRotation, x2: 0, y2: targetRotation) ?? targetRotation
            viewToAnimate.isDrawingEnabled = true
        }
        if timeLeft == 0 {
            finished()
        }
    }
    private func finished() {
        isFinished = true
        displayUpdateInformer.pause()
        onFinished?()
    }
    
    // -------------------------------------------------------------------------
    // Mark: - Cleanup
    // -------------------------------------------------------------------------
    deinit {
        displayUpdateInformer.close()
        displayUpdateInformer = nil
    }
}
