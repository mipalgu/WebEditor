//
//  Stretchable+DefaultImplementation.swift
//  
//
//  Created by Morgan McColl on 22/11/20.
//

#if canImport(TokamakShim)
import TokamakShim
#else
import SwiftUI
#endif

protocol _BoundedStretchable: class {
    
    var _width: CGFloat { get set }
    
    var _height: CGFloat { get set }
    
}

protocol BoundedStretchable: Stretchable, Positionable {
    
    var minWidth: CGFloat { get }
    
    var maxWidth: CGFloat { get }
    
    var minHeight: CGFloat { get }
    
    var maxHeight: CGFloat { get }
}

extension BoundedStretchable where Self: _BoundedStretchable {
    
    var width: CGFloat {
        get {
            min(max(self._width, self.minWidth), self.maxWidth)
        }
        set {
            self._width = min(max(self.minWidth, newValue), self.maxWidth)
        }
    }

    var height: CGFloat {
        get {
            min(max(self._height, self.minHeight), self.maxHeight)
        }
        set {
            self._height = min(max(self.minHeight, newValue), self.maxHeight)
        }
    }
    
    func onTopEdge(point: CGPoint) -> Bool {
        let topEdge = self.location.y - height / 2.0
        let topEdgeAbove = topEdge - horizontalEdgeTolerance
        let topEdgeBelow = topEdge + horizontalEdgeTolerance
        let y = point.y
        return y >= topEdgeAbove && y <= topEdgeBelow
    }
    
    func onBottomEdge(point: CGPoint) -> Bool {
        let bottomEdge = self.location.y + height / 2.0
        let bottomEdgeAbove = bottomEdge - horizontalEdgeTolerance
        let bottomEdgeBelow = bottomEdge + horizontalEdgeTolerance
        let y = point.y
        return y >= bottomEdgeAbove && y <= bottomEdgeBelow
    }
    
    func onLeftEdge(point: CGPoint) -> Bool {
        let leftEdge = self.location.x - width / 2.0
        let leftBoundLower = leftEdge - verticalEdgeTolerance
        let leftBoundUpper = leftEdge + verticalEdgeTolerance
        let x = point.x
        return x >= leftBoundLower && x <= leftBoundUpper
    }
    
    func onRightEdge(point: CGPoint) -> Bool {
        let rightEdge = self.location.x + width / 2.0
        let rightBoundLower = rightEdge - verticalEdgeTolerance
        let rightBoundUpper = rightEdge + verticalEdgeTolerance
        let x = point.x
        return x >= rightBoundLower && x <= rightBoundUpper
    }
    
    func onTopRightCorner(point: CGPoint) -> Bool {
        return onTopEdge(point: point) && onRightEdge(point: point)
    }
    
    func onBottomRightCorner(point: CGPoint) -> Bool {
        return onBottomEdge(point: point) && onRightEdge(point: point)
    }
    
    func onBottomLeftCorner(point: CGPoint) -> Bool {
        return onBottomEdge(point: point) && onLeftEdge(point: point)
    }
    
    func onTopLeftCorner(point: CGPoint) -> Bool {
        return onTopEdge(point: point) && onLeftEdge(point: point)
    }
    
    func stretchWidth(gesture: DragGesture.Value) -> CGFloat {
        (gesture.location.x - location.x) * 2.0
    }
    
    func stretchHeight(gesture: DragGesture.Value) -> CGFloat {
        (gesture.location.y - location.y) * 2.0
    }
    
    func stretchCorner(gesture: DragGesture.Value) {
        let point = gesture.location
        if onTopRightCorner(point: point) {
            self.width = stretchWidth(gesture: gesture)
            self.height = -stretchHeight(gesture: gesture)
            return
        }
        if onBottomRightCorner(point: point) {
            self.width = stretchWidth(gesture: gesture)
            self.height = stretchHeight(gesture: gesture)
            return
        }
        if onBottomLeftCorner(point: point) {
            self.width = -stretchWidth(gesture: gesture)
            self.height = stretchHeight(gesture: gesture)
            return
        }
        self.width = -stretchWidth(gesture: gesture)
        self.height = -stretchHeight(gesture: gesture)
    }
    
    func stretchHorizontal(gesture: DragGesture.Value) {
        if onRightEdge(point: gesture.location) {
            self.width = stretchWidth(gesture: gesture)
            return
        }
        self.width = -stretchWidth(gesture: gesture)
    }
    
    func stretchVertical(gesture: DragGesture.Value) {
        if onBottomEdge(point: gesture.location) {
            self.height = stretchHeight(gesture: gesture)
            return
        }
        self.height = -stretchHeight(gesture: gesture)
    }
    
}
