//
//  File.swift
//  
//
//  Created by Morgan McColl on 23/11/20.
//

#if canImport(TokamakShim)
import TokamakShim
#else
import SwiftUI
#endif

//protocol _DragableCollapsable: class {}

public protocol MoveCollapsableFromDrag: DragableCollapsable {}

public extension DragableCollapsable where Self: MoveCollapsableFromDrag {
    
    func handleCollapsedDrag(gesture: DragGesture.Value, frameWidth: CGFloat, frameHeight: CGFloat) {
        if !isDragging {
            offset = CGPoint(x: gesture.startLocation.x - location.x, y: gesture.startLocation.y - location.y)
            isDragging = true
        }
        updateLocationWithOffset(frameWidth: frameWidth, frameHeight: frameHeight, newLocation: gesture.location)
    }
    
    func finishCollapsedDrag(gesture: DragGesture.Value, frameWidth: CGFloat, frameHeight: CGFloat) {
        self.handleCollapsedDrag(gesture: gesture, frameWidth: frameWidth, frameHeight: frameHeight)
        self.isDragging = false
    }
    
}
