//  Created by Cristian Buse on 03/01/2019.
//  Copyright © 2019 Hans Guntersson. All rights reserved.

import UIKit

class DnaView: UIView, UIGestureRecognizerDelegate, UIScrollViewDelegate {
    // -------------------------------------------------------------------------
    // Mark: - Init
    // -------------------------------------------------------------------------
    private var heightConstraint: NSLayoutConstraint!
    private var widthConstraint: NSLayoutConstraint!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        internalInit()
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        internalInit()
    }
    private func internalInit() {
        contentMode = .scaleAspectFit
        clearsContextBeforeDrawing = false
        initSizeConstraints()
        initGestures()
        initTextAppearance()
    }
    private func initSizeConstraints() {
        heightConstraint = self.heightAnchor.constraint(equalToConstant: 0)
        widthConstraint = self.widthAnchor.constraint(equalToConstant: 0)
    }

    // -------------------------------------------------------------------------
    // Mark: - Nucleobase type sequence
    // -------------------------------------------------------------------------
    private var itemWasAddedInEditMode: Bool = false
    var baseTypes: [DnaSequence.NucleobaseType] = [] {
        didSet {
            defer {syncMapView?.baseTypes = baseTypes}
            updateDimensions()
        }
    }
    
    // -------------------------------------------------------------------------
    // Mark: - Exposed Variables
    // -------------------------------------------------------------------------
    enum HelixOrientation {
        case vertical
        case horizontal
    }
    var depthAlpha: CGFloat = 0.3 {
        didSet {
            depthAlpha = depthAlpha.clamped(to: 0.1...1.0)
            setNeedsDisplay()
        }
    }
    var depthScale: CGFloat = 0.3 {
        didSet {
            depthScale = depthScale.clamped(to: 0.1...1.0)
            setNeedsDisplay()
        }
    }
    var editMode: Bool = false {
        didSet {
            updateDimensions()
            animateEditMode()
        }
    }
    var lineWidth: CGFloat = 2.0 {
        didSet {
            lineWidth = lineWidth.clamped(to: 0.0...5.0)
            setNeedsDisplay()
        }
    }
    var helixOrientation: HelixOrientation = .horizontal {
        didSet {
            updateDimensions()
        }
    }
    var isAutoOriented: Bool = true
    var scale: CGFloat = 0.8 {
        didSet {
            scale = scale.clamped(to: 0.5...1)
            updateDimensions()
        }
    }
    var rotation3D: CGFloat = 0.0 {
        didSet {
            defer {syncMapView?.rotation3D = rotation3D}
            setNeedsDisplay()
        }
    }
    var areMainLettersEnabled: Bool = false {
        didSet {
            setNeedsDisplay()
        }
    }
    var arePairLettersEnabled: Bool = false {
        didSet {
            setNeedsDisplay()
        }
    }
    var torsion: CGFloat = 0.4 {
        didSet {
            torsion = torsion.clamped(to: 0.0...0.6)
            defer {syncMapView?.torsion = torsion}
            setNeedsDisplay()
        }
    }
    var syncMapView: DnaView? {
        didSet {
            syncMapView?.isUserInteractionEnabled = false
            syncMapView?.helixOrientation = helixOrientation
            syncMapView?.baseTypes = baseTypes
            syncMapView?.rotation3D = rotation3D
            syncMapView?.torsion = torsion
            setMapHighlight()
        }
    }
    var isDrawingEnabled: Bool = false {
        didSet {
            setNeedsDisplay()
        }
    }
    
    // -------------------------------------------------------------------------
    // Mark: - Spatial Dimensions
    // -------------------------------------------------------------------------
    // Constants
    private let segmentDistancePercentOfSize: CGFloat = 0.25
    private let radiusPercentOfSpacing :CGFloat = 0.8
    // Variables
    private var segmentLength: CGFloat = 0.0
    private var distanceBetweenSegments: CGFloat = 0.0
    private var circleRadius: CGFloat = 0.0
    
    private(set) var height: CGFloat = 0.0
    private(set) var width: CGFloat = 0.0
    
    // Size Update
    private func updateDimensions() {
        // Width and height refer to the internal representation of the dnaView
        // based on the orientation property
        if helixOrientation == .horizontal {
            width = self.bounds.height
        } else {
            width = self.bounds.width
        }
        
        // The class dimensions used to generate all the drawable elements data
        segmentLength = width * self.scale / (1 + segmentDistancePercentOfSize)
        distanceBetweenSegments = segmentLength  * self.segmentDistancePercentOfSize
        circleRadius = distanceBetweenSegments / 2 * radiusPercentOfSpacing
        
        // Extra Segment for Edit Mode
        height = distanceBetweenSegments * CGFloat(baseTypes.count + (editMode ? 1 : 0))
        let oldHeight: CGFloat
        
        // Adjust size constraints
        if helixOrientation == .horizontal {
            widthConstraint.isActive = true
            oldHeight = widthConstraint.constant
            widthConstraint.constant = height
            heightConstraint.isActive = false
        } else {
            widthConstraint.isActive = false
            heightConstraint.isActive = true
            oldHeight = heightConstraint.constant
            heightConstraint.constant = height
        }
        
        // Check if helix height has changed (within a precision of 1 pixel)
        if abs(height - oldHeight) < 1 {
            if previousStartPercent != nil {
                if let scrollView = self.superview as? UIScrollView {
                    let rect: CGRect
                    if helixOrientation == .horizontal {
                        rect = CGRect(x: previousStartPercent! * height, y: 0, width: scrollView.bounds.width, height: 1)
                    } else {
                        rect = CGRect(x: 0, y: previousStartPercent! * height, width: 1, height: scrollView.bounds.height)
                    }
                    scrollView.scrollRectToVisible(rect, animated: false)
                }
                previousStartPercent = nil
            }
            if itemWasAddedInEditMode {
                itemWasAddedInEditMode = false
                if let scrollView = self.superview! as? UIScrollView {
                    if helixOrientation == .horizontal {
                        scrollView.scrollRectToVisible(CGRect(x: self.height-1, y: 0, width: 1, height: 1), animated: false)
                    } else {
                        scrollView.scrollRectToVisible(CGRect(x: 0, y: self.height-1, width: 1, height: 1), animated: false)
                    }
                }
            }
            setMapHighlight()
            setNeedsDisplay()
        } else {
            setNeedsLayout()
        }
    }
    
    // -------------------------------------------------------------------------
    // Mark: - Spatial Elements (data)
    // -------------------------------------------------------------------------
    private struct DnaCircle {
        let center: CGPoint
        let radius: CGFloat
        var diameter: CGFloat {
            return radius * 2
        }
        func circumscribedRect() -> CGRect {
            return CGRect(x: center.x - radius, y: center.y - radius, width: diameter, height: diameter)
        }
        func path() -> UIBezierPath {
            return UIBezierPath(arcCenter: center, radius: radius, startAngle: 0, endAngle: CGFloat.pi * 2, clockwise: true)
        }
    }
    private struct DnaLine {
        let start: CGPoint
        let end: CGPoint
        
        func path() -> UIBezierPath {
            let bPath = UIBezierPath()
            bPath.move(to: start)
            bPath.addLine(to: end)
            return bPath
        }
    }
    private struct DnaSegment {
        let circle: DnaCircle
        let line: DnaLine
        
        let color: UIColor
        let alpha: CGFloat
        
        let character: String?
    }
    private struct DnaSegmentPair {
        let index: Int
        let mainSegment: DnaSegment
        let pairSegment: DnaSegment
        let isMainOnTop: Bool
    }
    
    private func generateSegments() -> [DnaSegmentPair] {
        var segments: [DnaSegmentPair] = []
        
        for i in 0..<baseTypes.count {
            if let segmentPair = generateSegmentPair(index: i, baseType: baseTypes[i]) {
                segments.append(segmentPair)
            }
        }
        if self.editMode {
            // An extra segment (for add/remove)
            if let segmentPair = generateSegmentPair(index: baseTypes.count, baseType: nil) {
                segments.append(segmentPair)
            }
        }
        return segments
    }
    
    private func generateSegmentPair(index: Int, baseType: DnaSequence.NucleobaseType?) -> DnaSegmentPair? {
        // Compute x as if orientation is horizontal
        let x: CGFloat = (CGFloat(index) + 0.5) * distanceBetweenSegments
        
        // Do not generate segments if outside of the drawing rectangle
        if helixOrientation == .horizontal {
            if (x < drawRect.minX - distanceBetweenSegments) || (x > drawRect.maxX + distanceBetweenSegments) {
                return nil
            }
        } else {
            if (x < drawRect.minY - distanceBetweenSegments) || (x > drawRect.maxY + distanceBetweenSegments) {
                return nil
            }
        }
        
        // The segment rotation angle. Line is rotated around X axis in vertical orientation
        // and around Y axis in horizontal orientation
        let rotation: CGFloat = CGFloat(index) * self.torsion + self.rotation3D //.truncatingRemainder(dividingBy: 2 * CGFloat.pi)
        
        // Compute dY as if orientation is horizontal
        let dY: CGFloat = cos(rotation) * segmentLength / 2
        
        // Depth will be represented in 2D by transparency and circle size
        let depth: CGFloat = sin(rotation) // values from -1 to 1
        let mainAlpha: CGFloat = COGO.scale(value: depth, domain: -1...1, range: self.depthAlpha...1)!
        let pairAlpha: CGFloat = COGO.scale(value: -depth, domain: -1...1, range: self.depthAlpha...1)!
        let mainRadius: CGFloat = circleRadius * COGO.scale(value: depth, domain: -1...1, range: self.depthScale...1)!
        let pairRadius: CGFloat = circleRadius * COGO.scale(value: -depth, domain: -1...1, range: self.depthScale...1)!
        let isMainOnTop: Bool = (depth > 0)
        
        // Colors and Letters
        let mainColor: UIColor = baseType?.color ?? UIColor.gray
        let pairColor: UIColor = baseType?.pair.color ?? UIColor.gray
        let mainCharacter: String = baseType?.rawValue ?? "+"
        let pairCharacter: String? = baseType?.pair.rawValue ?? "\u{2212}" //(baseType == nil ? "-" : nil)
        
        // Define necessary points
        let mainCenter: CGPoint
        let mainStart: CGPoint
        let mainEnd: CGPoint
        let pairCenter: CGPoint
        let pairStart: CGPoint
        let pairEnd: CGPoint
        
        // Compute points based on orientation
        // Apply correction to end points so that they are on the egde of the circle
        // instead of the center
        let correctionSign: CGFloat = (dY > 0 ? 1 : -1)
        if helixOrientation == .horizontal {
            let midY = self.bounds.origin.y + self.bounds.height / 2
            mainCenter = CGPoint(x: x, y: midY - dY)
            mainStart = CGPoint(x: x, y: midY)
            mainEnd = CGPoint(x: x, y: mainCenter.y + mainRadius * correctionSign)
            pairCenter = CGPoint(x: x, y: midY + dY)
            pairStart = mainStart
            pairEnd = CGPoint(x: x, y: pairCenter.y - pairRadius * correctionSign)
        } else {
            // Vertical orientation. Reverse x and dY because now y is fixed and dX is relative
            let dX = dY
            let y = x
            // Compute Points
            let midX = self.bounds.origin.x + self.bounds.width / 2
            mainCenter =  CGPoint(x: midX + dX, y: y)
            mainStart = CGPoint(x: midX, y: y)
            mainEnd = CGPoint(x: mainCenter.x - mainRadius * correctionSign, y: y)
            pairCenter =  CGPoint(x: midX - dX, y: y)
            pairStart = mainStart
            pairEnd = CGPoint(x: pairCenter.x + pairRadius * correctionSign, y: y)
        }
        
        // Create elements
        let mainCircle = DnaCircle(center: mainCenter, radius: mainRadius)
        let mainLine = DnaLine(start: mainStart, end: mainEnd)
        let mainSegment = DnaSegment(circle: mainCircle, line: mainLine, color: mainColor, alpha: mainAlpha, character: mainCharacter)
        let pairCircle = DnaCircle(center: pairCenter, radius: baseType == nil ? mainRadius : pairRadius)
        let pairLine = DnaLine(start: pairStart, end: pairEnd)
        let pairSegment = DnaSegment(circle: pairCircle, line: pairLine, color: pairColor, alpha: pairAlpha, character: pairCharacter)
        
        return DnaSegmentPair(index: index, mainSegment: mainSegment, pairSegment: pairSegment, isMainOnTop: isMainOnTop)
    }
    
    // -------------------------------------------------------------------------
    // Mark: - Layout Changes
    // -------------------------------------------------------------------------
    // Store previous visible position if orientation has changed
    private var previousStartPercent: CGFloat?
    override var bounds: CGRect {
        didSet {
            if isAutoOriented {
                let newHelixOrientation: HelixOrientation = UIDevice.current.orientation.isLandscape ? .horizontal : .vertical
                if helixOrientation != newHelixOrientation {
                    previousStartPercent = visibleHelixBounds().startPercent
                    helixOrientation = newHelixOrientation
                    return
                }
            }
            updateDimensions()
        }
    }
    
    // -------------------------------------------------------------------------
    // Mark: - Draw Elements
    // -------------------------------------------------------------------------
    private var drawRect: CGRect!
    private var highlightRect: CGRect?
    override func draw(_ rect: CGRect) {
        drawRect = convert(self.superview!.bounds, to: self)
        drawElements()
    }
    private func drawElements() {
        let segmentPairs = generateSegments()
        
        for segmentPair in segmentPairs {
            // Circles (at the end of each segment)
            let mainCirclePath = segmentPair.mainSegment.circle.path()
            let pairCirclePath = segmentPair.pairSegment.circle.path()

            // Lines (the 2 segments in a bond - pair)
            let mainLinePath = segmentPair.mainSegment.line.path()
            mainLinePath.lineWidth = self.lineWidth
            let pairLinePath = segmentPair.pairSegment.line.path()
            pairLinePath.lineWidth = self.lineWidth
            
            // Rectangles (the circles are inscribed); Text will go inside
            let mainRect = segmentPair.mainSegment.circle.circumscribedRect()
            let pairRect = segmentPair.pairSegment.circle.circumscribedRect()
            
            // Letters / Characters
            let mainCharacter = segmentPair.mainSegment.character!
            let mainDrawableChar = getFittedAttributedText(textToFit: mainCharacter, fitRect: mainRect, attributes: mainTextAttributes)
            let pairCharacter = segmentPair.pairSegment.character!
            let pairDrawableChar = getFittedAttributedText(textToFit: pairCharacter, fitRect: pairRect, attributes: pairTextAttributes)
            
            // Stroke and fill from the back towards the front
            let mainBlendMode: CGBlendMode = .normal
            let pairBlendMode: CGBlendMode = .luminosity
            if segmentPair.isMainOnTop {
                segmentPair.pairSegment.color.set()
                pairLinePath.stroke(with: pairBlendMode, alpha: segmentPair.pairSegment.alpha)
                pairCirclePath.fill(with: pairBlendMode, alpha: segmentPair.pairSegment.alpha)
                if arePairLettersEnabled {
                    pairDrawableChar.draw(in: pairRect)
                }
                
                segmentPair.mainSegment.color.set()
                mainLinePath.stroke(with: mainBlendMode, alpha: segmentPair.pairSegment.alpha) // Pair Alpha used
                mainCirclePath.fill(with: mainBlendMode, alpha: segmentPair.mainSegment.alpha)
                if areMainLettersEnabled {
                    mainDrawableChar.draw(in: mainRect)
                }
            } else {
                segmentPair.mainSegment.color.set()
                mainLinePath.stroke(with: mainBlendMode, alpha: segmentPair.mainSegment.alpha)
                mainCirclePath.fill(with: mainBlendMode, alpha: segmentPair.mainSegment.alpha)
                if areMainLettersEnabled {
                    mainDrawableChar.draw(in: mainRect)
                }
                
                segmentPair.pairSegment.color.set()
                pairLinePath.stroke(with: pairBlendMode, alpha: segmentPair.mainSegment.alpha) // Main Alpha used
                pairCirclePath.fill(with: pairBlendMode, alpha: segmentPair.pairSegment.alpha)
                if arePairLettersEnabled {
                    pairDrawableChar.draw(in: pairRect)
                }
            }
            if highlightRect != nil {
                let highlightPath = UIBezierPath(rect: highlightRect!)
                UIColor.red.set()
                highlightPath.fill(with: .normal, alpha: 0.005)
            }
        }
    }
    
    func highlight(startPercent: CGFloat, endPercent: CGFloat) {
        if helixOrientation == .horizontal {
            highlightRect = CGRect(x: startPercent * widthConstraint.constant, y: 0, width: (endPercent - startPercent) * widthConstraint.constant, height: bounds.height)
        } else {
            highlightRect = CGRect(x: 0, y: startPercent * heightConstraint.constant, width: bounds.width, height: (endPercent - startPercent) * heightConstraint.constant)
        }
        if let scrollView = self.superview as? UIScrollView {
            scrollView.scrollRectToVisible(highlightRect!, animated: false)
        }
    }

    // -------------------------------------------------------------------------
    // Mark: - Fitting Text in Rectangles
    // -------------------------------------------------------------------------
    var paragraph: NSMutableParagraphStyle = NSMutableParagraphStyle()
    let defaultFont: UIFont = UIFont(name: "Arial", size: 18)?.bold() ?? UIFont.boldSystemFont(ofSize: 18)
    var mainTextAttributes: [NSAttributedString.Key: Any]!
    var pairTextAttributes: [NSAttributedString.Key: Any]!
    
    // Store Fonts in a dictionary for fast retrieval. The key is the actual pointSize
    // This approach is several times faster than creating new fonts by using:
    //    defaultFont.withSize(newFontSize)
    var fontDict: Dictionary<CGFloat,UIFont> = [:]
    
    // Init reusable variables for getDnaFittedString
    private func initTextAppearance() {
        paragraph.alignment = .center
        mainTextAttributes = [
            .strokeColor: UIColor.black,
            .strokeWidth: -2.0,
            .foregroundColor: UIColor.white,
            .font: defaultFont,
            .paragraphStyle: paragraph
        ]
        pairTextAttributes = [
            .strokeColor: UIColor.black,
            .strokeWidth: -2,
            .foregroundColor: UIColor.lightGray,
            .font: defaultFont,
            .paragraphStyle: paragraph
        ]
    }

    // Fits a String into a Rect and returns a drawable NSMutableAttributedString
    private func getFittedAttributedText(textToFit: String, fitRect: CGRect, attributes: [NSAttributedString.Key: Any]?) -> NSMutableAttributedString {
        let newFontSize: CGFloat = floor(getFontSizeForTextInRect(text: textToFit, rect: fitRect, withAttributes: attributes) * 5) / 5
        var newAttributes = attributes
        if fontDict[newFontSize] != nil  {
            newAttributes?[.font] = fontDict[newFontSize]
        } else {
            let newFont = defaultFont.withSize(newFontSize)
            fontDict[newFontSize] = newFont
            newAttributes?[.font] = newFont
        }
        return NSMutableAttributedString(string: textToFit, attributes: newAttributes)
    }
    
    // Fits a String into a Rect and returns the new Font Size
    private func getFontSizeForTextInRect(text: String, rect: CGRect, withAttributes: [NSAttributedString.Key: Any]?) -> CGFloat {
        let textSize: CGSize = text.size(withAttributes: withAttributes)
        let textAspectRatio: CGFloat = textSize.width / textSize.height
        let fitHorizontally: Bool = (rect.width >= rect.height * textAspectRatio)
        let textFont: UIFont = withAttributes?[.font] as? UIFont ?? UIFont.systemFont(ofSize: UIFont.systemFontSize)
        
        if fitHorizontally {
            return rect.height *  textFont.pointSize / textSize.height
        } else {
            return rect.width *  textFont.pointSize / textSize.width
        }
    }
    
    // -------------------------------------------------------------------------
    // Mark: - Animate
    // -------------------------------------------------------------------------
    private var dnaAnimation: DnaAnimation!
    private var isSuperUserInteractionOn: Bool = false
    
    private func animateEditMode() {
        isSuperUserInteractionOn = self.superview!.isUserInteractionEnabled
        self.superview!.isUserInteractionEnabled = false
        dnaAnimation = DnaAnimation(
            withDuration: 2.0
            , dnaView: self
            , targetTorsion: editMode ? 0.0 : 0.4
            , targetRotation: editMode ? 1.3 : 0.0
            , onFinished: {[unowned self] in self.animationFinished()}
        )
    }
    private func animationFinished() {
        dnaAnimation = nil
        self.superview!.isUserInteractionEnabled = isSuperUserInteractionOn
    }
    
    // -------------------------------------------------------------------------
    // Mark: - Map
    // -------------------------------------------------------------------------
    private func visibleHelixBounds() -> (startPercent: CGFloat, endPercent: CGFloat) {
        let visibleRect = convert(self.superview!.bounds, to: self)
        if helixOrientation == .horizontal {
            return (visibleRect.minX / self.bounds.width, visibleRect.maxX / self.bounds.width)
        } else {
            return (visibleRect.minY / self.bounds.height, visibleRect.maxY / self.bounds.height)
        }
    }
    
    private func setMapHighlight() {
        let visibleBounds = visibleHelixBounds()
        syncMapView?.highlight(startPercent: visibleBounds.startPercent , endPercent: visibleBounds.endPercent)
    }
    
    // -------------------------------------------------------------------------
    // Mark: - Gestures
    // -------------------------------------------------------------------------
    private let panGesture: UIPanGestureRecognizer! = nil
    private let pinchGesture: UIPinchGestureRecognizer! = nil
    private let tapGesture: UITapGestureRecognizer! = nil
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        if gestureRecognizer === pinchGesture || otherGestureRecognizer === pinchGesture {
            return false
        }
        return true
    }
    
    func initGestures() {
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture))
        panGesture.delegate = self
        self.addGestureRecognizer(panGesture)
        
        let pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(handlePinchGesture))
        pinchGesture.delegate = self
        self.addGestureRecognizer(pinchGesture)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTapGesture))
        tapGesture.delegate = self
        self.addGestureRecognizer(tapGesture)
    }
    
    private var originalRotation: CGFloat = 0.0
    @objc func handlePanGesture(pan: UIPanGestureRecognizer) {
        if pan.state == .began {
            originalRotation = self.rotation3D
        } else if pan.state == .changed {
            if !editMode {
                let translation = pan.translation(in: self)
                if helixOrientation == .horizontal {
                    self.rotation3D = originalRotation + translation.y / self.bounds.height * CGFloat.pi * 2
                } else {
                    self.rotation3D = originalRotation + translation.x / self.bounds.width * CGFloat.pi * 2
                }
            }
        }
    }
    
    private var startTorsion: CGFloat = 0
    private var startScale: CGFloat = 0
    @objc func handlePinchGesture(pinch: UIPinchGestureRecognizer) {
        // Avoid errors
        if pinch.numberOfTouches < 2 {
            return
        }
        
        if pinch.state == .began {
            startTorsion = self.torsion
            startScale = self.scale
        } else if pinch.state == .changed {
            let p1: CGPoint = pinch.location(ofTouch: 0, in: self)
            let p2: CGPoint = pinch.location(ofTouch: 1, in: self)
            
            let azimuth: CGFloat = COGO.azimuth(x1: p1.x, y1: p1.y, x2: p2.x, y2: p2.y)!
            let quarterPI = CGFloat.pi / 4
            let pinchDirection: HelixOrientation
            if abs(azimuth) < quarterPI || abs(azimuth) > 3 * quarterPI {
                pinchDirection = .vertical
            } else {
                pinchDirection = .horizontal
            }
            if pinchDirection == self.helixOrientation {
                if !editMode {
                    self.torsion = startTorsion + 0.4 * (pinch.scale - 1)
                }
            } else {
                self.scale = startScale + 0.3 * (pinch.scale - 1)
            }
        }
    }
    @objc func handleTapGesture(tap: UITapGestureRecognizer) {
        if editMode {
            let segmentPairs = generateSegments()
            for segmentPair in segmentPairs {
                let mainRect = segmentPair.mainSegment.circle.circumscribedRect()
                if mainRect.contains(tap.location(in: self)) {
                    if segmentPair.index < baseTypes.count {
                        baseTypes[segmentPair.index] = baseTypes[segmentPair.index].next
                        self.setNeedsDisplay()
                    } else {
                        itemWasAddedInEditMode = true
                        baseTypes.append(DnaSequence.NucleobaseType(rawValue: DnaSequence.NucleobaseType.cytosine.rawValue)!)
                    }
                }
            }
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        setMapHighlight()
        syncMapView?.setNeedsDisplay()
        setNeedsDisplay()
    }
    
    deinit {
        print("DnaView terminated")
    }
}
