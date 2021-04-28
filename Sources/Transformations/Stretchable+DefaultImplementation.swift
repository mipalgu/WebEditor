//
//  Stretchable+DefaultImplementation.swift
//  
//
//  Created by Morgan McColl on 22/11/20.
//

import TokamakShim
import Foundation

public extension Stretchable where Self: EdgeDetector {
    
    private func stretchWidth(gesture: DragGesture.Value) -> CGFloat {
        (gesture.location.x - location.x) * 2.0
    }
    
    private func stretchHeight(gesture: DragGesture.Value) -> CGFloat {
        (gesture.location.y - location.y) * 2.0
    }
    
    mutating func stretchCorner(gesture: DragGesture.Value) {
        stretchVertical(gesture: gesture)
        stretchHorizontal(gesture: gesture)
    }
    
    mutating func stretchHorizontal(gesture: DragGesture.Value) {
        if gesture.location.x >= self.location.x {
            self.width = stretchWidth(gesture: gesture)
        } else {
            self.width = -stretchWidth(gesture: gesture)
        }
        self.location = CGPoint(x: max(self.location.x, self.width / 2.0), y: self.location.y)
    }
    
    mutating func stretchVertical(gesture: DragGesture.Value) {
        if gesture.location.y >= self.location.y {
            self.height = stretchHeight(gesture: gesture)
        } else {
            self.height = -stretchHeight(gesture: gesture)
        }
        self.location = CGPoint(x: self.location.x, y: max(self.location.y, self.height / 2.0))
    }
}

public extension Stretchable where Self: EdgeDetector & Collapsable & BoundedSize {
    
    private func stretchWidth(gesture: DragGesture.Value) -> CGFloat {
        (gesture.location.x - location.x) * 2.0
    }
    
    private func stretchHeight(gesture: DragGesture.Value) -> CGFloat {
        (gesture.location.y - location.y) * 2.0
    }
    
    mutating func stretchCorner(gesture: DragGesture.Value) {
        stretchVertical(gesture: gesture)
        stretchHorizontal(gesture: gesture)
    }
    
    mutating func stretchHorizontal(gesture: DragGesture.Value) {
        if gesture.startLocation.x > location.x && gesture.location.x < location.x + minWidth / 2.0 {
            return
        }
        if gesture.startLocation.x < location.x && gesture.location.x > location.x - minWidth / 2.0 {
            return
        }
        let newWidth = gesture.location.x >= self.location.x ? stretchWidth(gesture: gesture) : -stretchWidth(gesture: gesture)
        if expanded {
            width = newWidth
            self.location = CGPoint(x: max(self.location.x, self.width / 2.0), y: self.location.y)
            return
        }
        collapsedWidth = newWidth
        self.location = CGPoint(x: max(self.location.x, self.collapsedWidth / 2.0), y: self.location.y)
    }
    
    mutating func stretchVertical(gesture: DragGesture.Value) {
        if gesture.startLocation.y > location.y && gesture.location.y < location.y + minHeight / 2.0 {
            return
        }
        if gesture.startLocation.y < location.y && gesture.location.y > location.y - minHeight / 2.0 {
            return
        }
        let newHeight = gesture.location.y >= self.location.y ? stretchHeight(gesture: gesture) : -stretchHeight(gesture: gesture)
        if expanded {
            self.height = newHeight
            self.location = CGPoint(x: self.location.x, y: max(self.location.y, self.height / 2.0))
            return
        }
        self.collapsedHeight = newHeight
        self.location = CGPoint(x: self.location.x, y: max(self.location.y, self.collapsedHeight / 2.0))
    }
}

//public extension Stretchable where Self: EdgeDetector  & Collapsable {
//
//    mutating func stretchHorizontal(gesture: DragGesture.Value) {
//        if gesture.startLocation.x > location.x && gesture.location.x < location.x + minWidth / 2.0 {
//            return
//        }
//        if gesture.startLocation.x < location.x && gesture.location.x > location.x - minWidth / 2.0 {
//            return
//        }
//        let newWidth = gesture.location.x >= self.location.x ? stretchWidth(gesture: gesture) : -stretchWidth(gesture: gesture)
//        if expanded {
//            width = newWidth
//            self.location = CGPoint(x: max(self.location.x, self.width / 2.0), y: self.location.y)
//            return
//        }
//        collapsedWidth = newWidth
//        self.location = CGPoint(x: max(self.location.x, self.collapsedWidth / 2.0), y: self.location.y)
//    }
//
//    mutating func stretchVertical(gesture: DragGesture.Value) {
//        let newHeight = gesture.location.y >= self.location.y ? stretchHeight(gesture: gesture) : -stretchHeight(gesture: gesture)
//        if expanded {
//            self.height = newHeight
//            self.location = CGPoint(x: self.location.x, y: max(self.location.y, self.height / 2.0))
//            return
//        }
//        self.collapsedHeight = newHeight
//        self.location = CGPoint(x: self.location.x, y: max(self.location.y, self.collapsedHeight / 2.0))
//    }
//
//}
