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

extension Positionable {
    
    func setLocation(width: CGFloat, height: CGFloat, newLocation: CGPoint) {
        let x = newLocation.x
        let y = newLocation.y
        self.location = CGPoint(x: min(max(0, x), width), y: min(max(0, y), height))
    }
    
}
