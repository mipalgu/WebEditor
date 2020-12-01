//
//  File.swift
//  
//
//  Created by Morgan McColl on 22/11/20.
//

#if canImport(TokamakShim)
import TokamakShim
#else
import SwiftUI
#endif

public protocol MoveAndStretchFromDrag: Dragable, Moveable, Stretchable {}

public protocol MoveFromDrag: Dragable, _Moveable, Moveable {}

public protocol StretchFromDrag: Dragable, Stretchable {}

public extension Dragable where Self: MoveAndStretchFromDrag {
    
    func handleDrag(gesture: DragGesture.Value, frameWidth: CGFloat, frameHeight: CGFloat) {
        if isDragging {
            updateLocationWithOffset(frameWidth: frameWidth, frameHeight: frameHeight, newLocation: gesture.location)
            return
        }
        if isStretchingX && isStretchingY {
            stretchCorner(gesture: gesture)
            return
        }
        if isStretchingX {
            stretchHorizontal(gesture: gesture)
            return
        }
        if isStretchingY {
            stretchVertical(gesture: gesture)
            return
        }
        if onCorner(point: gesture.startLocation) {
            isStretchingX = true
            isStretchingY = true
            return
        }
        if onVerticalEdge(point: gesture.startLocation) {
            isStretchingX = true
            return
        }
        if onHorizontalEdge(point: gesture.startLocation) {
            isStretchingY = true
            return
        }
        offset = CGPoint(x: gesture.startLocation.x - location.x, y: gesture.startLocation.y - location.y)
        isDragging = true
    }
    
    func finishDrag(gesture: DragGesture.Value, frameWidth: CGFloat, frameHeight: CGFloat) {
        self.handleDrag(gesture: gesture, frameWidth: frameWidth, frameHeight: frameHeight)
        self.isDragging = false
        self.isStretchingY = false
        self.isStretchingX = false
    }
    
}

public extension Dragable where Self: MoveFromDrag {
    
    func handleDrag(gesture: DragGesture.Value, frameWidth: CGFloat, frameHeight: CGFloat) {
        if isDragging {
            updateLocationWithOffset(frameWidth: frameWidth, frameHeight: frameHeight, newLocation: gesture.location)
            return
        }
        offset = CGPoint(x: gesture.startLocation.x - location.x, y: gesture.startLocation.y - location.y)
        isDragging = true
    }
    
    func finishDrag(gesture: DragGesture.Value, frameWidth: CGFloat, frameHeight: CGFloat) {
        self.handleDrag(gesture: gesture, frameWidth: frameWidth, frameHeight: frameHeight)
        self.isDragging = false
    }
    
}

public extension Dragable where Self: StretchFromDrag {
    func handleDrag(gesture: DragGesture.Value, frameWidth: CGFloat, frameHeight: CGFloat) {
        if isStretchingX && isStretchingY {
            stretchCorner(gesture: gesture)
            return
        }
        if isStretchingX {
            stretchHorizontal(gesture: gesture)
            return
        }
        if isStretchingY {
            stretchVertical(gesture: gesture)
            return
        }
        if onCorner(point: gesture.startLocation) {
            isStretchingX = true
            isStretchingY = true
            return
        }
        if onVerticalEdge(point: gesture.startLocation) {
            isStretchingX = true
            return
        }
        if onHorizontalEdge(point: gesture.startLocation) {
            isStretchingY = true
            return
        }
    }
    
    func finishDrag(gesture: DragGesture.Value, frameWidth: CGFloat, frameHeight: CGFloat) {
        self.handleDrag(gesture: gesture, frameWidth: frameWidth, frameHeight: frameHeight)
        self.isStretchingY = false
        self.isStretchingX = false
    }
}
