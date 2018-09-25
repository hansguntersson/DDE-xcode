//  Created by Cristian Buse on 08/09/2018.
//  Copyright © 2018 Hans Guntersson. All rights reserved.

import UIKit

class DisplayUpdateInformer {
    private var displayTimer: CADisplayLink!
    private var onDisplayUpdate: ((_ deltaTime: CFTimeInterval) -> ())!
    
    var preferredFPS: Int = 0 {
        didSet {
            displayTimer.preferredFramesPerSecond = preferredFPS
        }
    }
    
    private(set) var realFPS: Double = 0.0
    private(set) var lastFrameTimeStamp: CFTimeInterval = 0.0
    private(set) var nextFrameTimeStamp: CFTimeInterval = 0.0
    
    required init(onDisplayUpdate: @escaping (_ deltaTime: CFTimeInterval) -> ()) {
        self.onDisplayUpdate = onDisplayUpdate
        
        prepareTimer()
    }
    
    private func prepareTimer() {
        displayTimer = CADisplayLink(target: self, selector: #selector(handleTimerUpdate))
        displayTimer.preferredFramesPerSecond = preferredFPS
        displayTimer.isPaused = true
        displayTimer.add(to: .main, forMode: .common)
    }
    
    @objc func handleTimerUpdate(displayLink: CADisplayLink) {
        var deltaTime: CFTimeInterval = displayLink.targetTimestamp - displayLink.timestamp
        realFPS = 1 / deltaTime
        
        if nextFrameTimeStamp > 0 {
            // Adjust the current delta so that it takes into account
            //  the time forecasted last frame and the actual time the frame was drawn
            deltaTime += displayLink.timestamp - nextFrameTimeStamp
        }
        
        lastFrameTimeStamp = displayLink.timestamp
        nextFrameTimeStamp = displayLink.targetTimestamp
        
        self.onDisplayUpdate(deltaTime)
    }
    
    func pause() {
        displayTimer.isPaused = true
    }
    
    func resume() {
        lastFrameTimeStamp = 0.0
        nextFrameTimeStamp = 0.0
        displayTimer.isPaused = false
    }

    func close() {
        removeTimer()
    }
    
    private func removeTimer() {
        displayTimer.invalidate()
        displayTimer = nil
    }
    
    deinit {
        print("Display Update Informer was de-initialized")
    }
}
