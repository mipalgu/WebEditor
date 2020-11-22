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

protocol BoundedStretchable: Stretchable, EdgeableAction {
    
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
