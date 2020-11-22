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

protocol _Moveable: class {}

extension Moveable where Self: _Moveable {
    
    func updateLocationWithOffset(newLocation: CGPoint) {
        let dx = newLocation.x - offset.x
        let dy = newLocation.y - offset.y
        self.location = CGPoint(x: dx, y: dy)
    }
    
}
