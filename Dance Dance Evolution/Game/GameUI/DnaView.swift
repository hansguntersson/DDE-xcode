//  Created by Cristian Buse on 03/01/2019.
//  Copyright © 2019 Hans Guntersson. All rights reserved.

import UIKit

class DnaView: UIView, UIGestureRecognizerDelegate, UIScrollViewDelegate {
    // -------------------------------------------------------------------------
    // Mark: - Init
    // -------------------------------------------------------------------------
    var heightConstraint: NSLayoutConstraint!
    var widthConstraint: NSLayoutConstraint!
    
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
        updateGestures()
    }
    private func initSizeConstraints() {
        heightConstraint = self.heightAnchor.constraint(equalToConstant: 0)
        widthConstraint = self.widthAnchor.constraint(equalToConstant: 0)
    }

    // -------------------------------------------------------------------------
    // Mark: - Nucleobase type sequence
    // -------------------------------------------------------------------------
    var baseTypes: [DnaSequence.NucleobaseType] = [] {
        didSet {
            updateDimensions()
        }
    }
    
    // -------------------------------------------------------------------------
    // Mark: - Exposed Variables
    // -------------------------------------------------------------------------
    enum Orientation {
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
        }
    }
    var lineWidth: CGFloat = 2.0 {
        didSet {
            lineWidth = lineWidth.clamped(to: 0.0...5.0)
            setNeedsDisplay()
        }
    }
    var orientation: Orientation = .horizontal {
        didSet {
            updateDimensions()
        }
    }
    var scale: CGFloat = 0.75 {
        didSet {
            scale = scale.clamped(to: 0.4...1)
            updateDimensions()
        }
    }
    var rotation3D: CGFloat = 0.0 {
        didSet {
            setNeedsDisplay()
        }
    }
    var torsion: CGFloat = 0.4 {
        didSet {
            torsion = torsion.clamped(to: 0.0...0.6)
            setNeedsDisplay()
        }
    }
    override var isUserInteractionEnabled: Bool {
        didSet {
            updateGestures()
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
    // Size Update
    private func updateDimensions() {
        // Width and height refer to the internal representation of the dnaView
        // based on the orientation property
        let width: CGFloat
        let height: CGFloat
        
        if orientation == .horizontal {
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
        if orientation == .horizontal {
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
        
        if height == oldHeight {
            setNeedsDisplay()
        } else {
            // Must avoid infinite loop. See var bounds (overriden)
            wereDimensionsJustUpdated = true
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
        // The segment rotation angle. Line is rotated around X axis in vertical orientation
        // and around Y axis in horizontal orientation
        let rotation: CGFloat = (baseType == nil ? 0 : CGFloat(index) * self.torsion + self.rotation3D)
        
        // Compute x and dY as if orientation is horizontal
        let x: CGFloat = (CGFloat(index) + 0.5) * distanceBetweenSegments
        let dY: CGFloat = cos(rotation) * segmentLength / 2
        
        // Do not generate segments if outside of the drawing rectangle
        if orientation == .horizontal {
            if (x < drawRect.minX - distanceBetweenSegments) || (x > drawRect.maxX + distanceBetweenSegments) {
                return nil
            }
        } else {
            if (x < drawRect.minY - distanceBetweenSegments) || (x > drawRect.maxY + distanceBetweenSegments) {
                return nil
            }
        }
        
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
        let pairCharacter: String? = (baseType == nil ? "-" : nil)
        
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
        if orientation == .horizontal {
            let midY = self.bounds.origin.y + self.bounds.height / 2
            mainCenter = CGPoint(x: x, y: midY + dY)
            mainStart = CGPoint(x: x, y: midY)
            mainEnd = CGPoint(x: x, y: mainCenter.y - mainRadius * correctionSign)
            pairCenter = CGPoint(x: x, y: midY - dY)
            pairStart = mainStart
            pairEnd = CGPoint(x: x, y: pairCenter.y + pairRadius * correctionSign)
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
        let pairCircle = DnaCircle(center: pairCenter, radius: pairRadius)
        let pairLine = DnaLine(start: pairStart, end: pairEnd)
        let pairSegment = DnaSegment(circle: pairCircle, line: pairLine, color: pairColor, alpha: pairAlpha, character: pairCharacter)
        
        return DnaSegmentPair(mainSegment: mainSegment, pairSegment: pairSegment, isMainOnTop: isMainOnTop)
    }
    
    // -------------------------------------------------------------------------
    // Mark: - Layout Changes
    // -------------------------------------------------------------------------
    // 1. If the bounds are changed externally (ex .phone rotated) then the
    //    updateDimensions must be called
    // 2. updateDimenssion could be called from the class API (ex. the sequence
    //    is longer) or from 1. and so it needs to call setNeedsLayout which in
    //    turn sets the bounds
    // 1. and 2. above create an infinite loop and a control boolean is used to
    //    overcome this problem - wereDimensionsJustUpdated - which must be set
    //    to true from inside the updateDimensions function
    private var wereDimensionsJustUpdated: Bool = false
    override var bounds: CGRect {
        didSet {
            if wereDimensionsJustUpdated {
                wereDimensionsJustUpdated = false
                setNeedsDisplay()
            } else {
                updateDimensions()
            }
        }
    }
    
    // -------------------------------------------------------------------------
    // Mark: - Draw Elements
    // -------------------------------------------------------------------------
    private var drawRect: CGRect!
    override func draw(_ rect: CGRect) {
        drawRect = convert(self.superview!.bounds, to: self)
        drawElements()
    }
    private func drawElements() {
        let segmentPairs = generateSegments()
        
        // Define Text Appearance
        let paragraph = NSMutableParagraphStyle()
        paragraph.alignment = .center
        let font = UIFont(name: "Arial", size: 18)?.bold() ?? UIFont.boldSystemFont(ofSize: 18)
        var mainTextAttributes: [NSAttributedString.Key: Any] = [
            .strokeColor: UIColor.white,
            .strokeWidth: -2.0,
            .foregroundColor: UIColor.white,
            .font: font,
            .paragraphStyle: paragraph
        ]
        //let dummyText = "M" as NSString
        //let textSize: CGSize = dummyText.size(withAttributes: mainTextAttributes)
        
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
            //let pairRect = segmentPair.pairSegment.circle.circumscribedRect()
            
            // Main Letter / Character
            let mainCharacter = segmentPair.mainSegment.character! as NSString
            let newFontSize = getFontSizeForTextInRect(text: mainCharacter, rect: mainRect, withAttributes: mainTextAttributes)
            mainTextAttributes[.font] = font.withSize(newFontSize)
            
            // Stroke and fill from the back towards the front
            let blendMode: CGBlendMode = .normal
            if segmentPair.isMainOnTop {
                segmentPair.pairSegment.color.set()
                pairLinePath.stroke(with: blendMode, alpha: segmentPair.pairSegment.alpha)
                pairCirclePath.fill(with: blendMode, alpha: segmentPair.pairSegment.alpha)
                
                segmentPair.mainSegment.color.set()
                mainLinePath.stroke(with: blendMode, alpha: segmentPair.pairSegment.alpha) // Pair Alpha used
                mainCirclePath.fill(with: blendMode, alpha: segmentPair.mainSegment.alpha)
                mainCharacter.draw(in: mainRect, withAttributes: mainTextAttributes)
            } else {
                segmentPair.mainSegment.color.set()
                mainLinePath.stroke(with: blendMode, alpha: segmentPair.mainSegment.alpha)
                mainCirclePath.fill(with: blendMode, alpha: segmentPair.mainSegment.alpha)
                mainCharacter.draw(in: mainRect, withAttributes: mainTextAttributes)
                
                segmentPair.pairSegment.color.set()
                pairLinePath.stroke(with: blendMode, alpha: segmentPair.mainSegment.alpha) // Main Alpha used
                pairCirclePath.fill(with: blendMode, alpha: segmentPair.pairSegment.alpha)
            }
        }
    }

    private func getFontSizeForTextInRect(text: NSString, rect: CGRect, withAttributes: [NSAttributedString.Key: Any]) -> CGFloat {
        let textSize: CGSize = text.size(withAttributes: withAttributes)
        let textAspectRatio: CGFloat = textSize.width / textSize.height
        let fitHorizontally: Bool = (rect.width >= rect.height * textAspectRatio)
        let textFont: UIFont = withAttributes[.font] as? UIFont ?? UIFont.systemFont(ofSize: UIFont.systemFontSize)
        
        if fitHorizontally {
            return rect.height *  textFont.pointSize / textSize.height
        } else {
            return rect.width *  textFont.pointSize / textSize.width
        }
    }
    
    // -------------------------------------------------------------------------
    // Mark: - Gestures
    // -------------------------------------------------------------------------
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        if gestureRecognizer.type() == .pinch || otherGestureRecognizer.type() == .pinch {
            return false
        }
        return true
    }
    
    private var areGesturesInitialized: Bool = false
    
    private func updateGestures() {
        if isUserInteractionEnabled && !areGesturesInitialized {
            let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture))
            panGesture.delegate = self
            self.addGestureRecognizer(panGesture)
            
            let pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(handlePinchGesture))
            pinchGesture.delegate = self
            self.addGestureRecognizer(pinchGesture)
            
            areGesturesInitialized = true
        }
    }
    
    private var originalRotation: CGFloat = 0.0
    @objc func handlePanGesture(pan: UIPanGestureRecognizer) {
        if pan.state == .began {
            originalRotation = self.rotation3D
        } else if pan.state == .changed {
            let translation = pan.translation(in: self)
            self.rotation3D = originalRotation + translation.x / self.bounds.width * CGFloat.pi * 2
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
            let pinchDirection: Orientation
            if abs(azimuth) < quarterPI || abs(azimuth) > 3 * quarterPI {
                pinchDirection = .vertical
            } else {
                pinchDirection = .horizontal
            }
            if pinchDirection == self.orientation {
                self.torsion = startTorsion + 0.4 * (pinch.scale - 1)
            } else {
                self.scale = startScale + 0.3 * (pinch.scale - 1)
            }
        }
    }
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        setNeedsDisplay()
    }
}
