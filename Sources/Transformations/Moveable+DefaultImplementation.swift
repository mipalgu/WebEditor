//
//  Moveable+DefaultImplementation.swift
//  
//
//  Created by Morgan McColl on 22/11/20.
//

#if canImport(TokamakShim)
import TokamakShim
#else
import SwiftUI
#endif

public protocol _Moveable {}

public extension Moveable where Self: _Moveable {
    
    mutating func updateLocationWithOffset(frameWidth: CGFloat, frameHeight: CGFloat, newLocation: CGPoint) {
        let x2 = newLocation.x - offset.x
        let y2 = newLocation.y - offset.y
        self.setLocation(width: frameWidth, height: frameHeight, newLocation: CGPoint(x: x2, y: y2))
    }
    
}


