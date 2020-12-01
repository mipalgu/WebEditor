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

public extension Stretchable where Self: EdgeDetector {
    
    private func stretchWidth(gesture: DragGesture.Value) -> CGFloat {
        (gesture.location.x - location.x) * 2.0
    }
    
    private func stretchHeight(gesture: DragGesture.Value) -> CGFloat {
        (gesture.location.y - location.y) * 2.0
    }
    
    func stretchCorner(gesture: DragGesture.Value) {
        stretchVertical(gesture: gesture)
        stretchHorizontal(gesture: gesture)
    }
    
    func stretchHorizontal(gesture: DragGesture.Value) {
        if gesture.location.x >= self.location.x {
            self.width = stretchWidth(gesture: gesture)
        } else {
            self.width = -stretchWidth(gesture: gesture)
        }
        self.location = CGPoint(x: max(self.location.x, self.width / 2.0), y: self.location.y)
    }
    
    func stretchVertical(gesture: DragGesture.Value) {
        if gesture.location.y >= self.location.y {
            self.height = stretchHeight(gesture: gesture)
        } else {
            self.height = -stretchHeight(gesture: gesture)
        }
        self.location = CGPoint(x: self.location.x, y: max(self.location.y, self.height / 2.0))
    }
}
