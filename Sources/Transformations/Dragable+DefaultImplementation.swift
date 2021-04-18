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

public protocol MoveFromDrag: Dragable, _Moveable, Moveable {}

public protocol StretchFromDrag: Dragable, Stretchable {}

public protocol MoveAndStretchFromDrag: MoveFromDrag, StretchFromDrag {}

public extension Dragable where Self: MoveFromDrag {
    
    mutating func moveFromDrag(gesture: DragGesture.Value, frameWidth: CGFloat, frameHeight: CGFloat) {
        if isDragging {
            updateLocationWithOffset(frameWidth: frameWidth, frameHeight: frameHeight, newLocation: gesture.location)
            return
        }
        offset = CGPoint(x: gesture.startLocation.x - location.x, y: gesture.startLocation.y - location.y)
        isDragging = true
    }
    
    mutating func handleDrag(gesture: DragGesture.Value, frameWidth: CGFloat, frameHeight: CGFloat) {
        moveFromDrag(gesture: gesture, frameWidth: frameWidth, frameHeight: frameHeight)
    }
    
    mutating func finishDrag(gesture: DragGesture.Value, frameWidth: CGFloat, frameHeight: CGFloat) {
        self.handleDrag(gesture: gesture, frameWidth: frameWidth, frameHeight: frameHeight)
        self.isDragging = false
    }
    
}

public extension Dragable where Self: StretchFromDrag {
    
    mutating func stretchFromDrag(gesture: DragGesture.Value, frameWidth: CGFloat, frameHeight: CGFloat) {
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
    
    mutating func handleDrag(gesture: DragGesture.Value, frameWidth: CGFloat, frameHeight: CGFloat) {
        stretchFromDrag(gesture: gesture, frameWidth: frameWidth, frameHeight: frameHeight)
    }
    
    mutating func finishDrag(gesture: DragGesture.Value, frameWidth: CGFloat, frameHeight: CGFloat) {
        self.handleDrag(gesture: gesture, frameWidth: frameWidth, frameHeight: frameHeight)
        self.isStretchingY = false
        self.isStretchingX = false
    }
}

public extension Dragable where Self: MoveAndStretchFromDrag {
    
    mutating func handleDrag(gesture: DragGesture.Value, frameWidth: CGFloat, frameHeight: CGFloat) {
        if isStretchingY || isStretchingX {
            stretchFromDrag(gesture: gesture, frameWidth: frameWidth, frameHeight: frameHeight)
            return
        }
        if isDragging {
            moveFromDrag(gesture: gesture, frameWidth: frameWidth, frameHeight: frameHeight)
            return
        }
        if onEdge(point: gesture.startLocation) {
            stretchFromDrag(gesture: gesture, frameWidth: frameWidth, frameHeight: frameHeight)
            return
        }
        moveFromDrag(gesture: gesture, frameWidth: frameWidth, frameHeight: frameHeight)
    }
    
    mutating func finishDrag(gesture: DragGesture.Value, frameWidth: CGFloat, frameHeight: CGFloat) {
        self.handleDrag(gesture: gesture, frameWidth: frameWidth, frameHeight: frameHeight)
        self.isDragging = false
        self.isStretchingY = false
        self.isStretchingX = false
    }
    
}


