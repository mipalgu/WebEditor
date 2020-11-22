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

protocol MoveAndStretchFromDrag: Dragable, Moveable, BoundedStretchable {}

extension Dragable where Self: MoveAndStretchFromDrag {
    
    func onCorner(point: CGPoint) -> Bool {
        onTopRightCorner(point: point) || onBottomRightCorner(point: point) ||
            onBottomLeftCorner(point: point) || onTopLeftCorner(point: point)
    }
    
    func onVerticalEdge(point: CGPoint) -> Bool {
        onLeftEdge(point: point) || onRightEdge(point: point)
    }
    
    func onHorizontalEdge(point: CGPoint) -> Bool {
        onTopEdge(point: point) || onBottomEdge(point: point)
    }
    
    mutating func handleDrag(gesture: DragGesture.Value) {
        if isDragging {
            updateLocationWithOffset(newLocation: gesture.location)
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
    
    mutating func finishDrag(gesture: DragGesture.Value) {
        self.handleDrag(gesture: gesture)
        self.isDragging = false
        self.isStretchingY = false
        self.isStretchingX = false
    }
    
}
