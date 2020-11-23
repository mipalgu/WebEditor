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

extension Rigidable where Self: Positionable {
    
    func setLocation(width: CGFloat, height: CGFloat, newLocation: CGPoint) {
        let x = newLocation.x
        let y = newLocation.y
        self.location = CGPoint(
            x: min(max(self.width / 2.0, x), width - self.width / 2.0),
            y: min(max(self.height / 2.0, y), height - self.height / 2.0)
        )
    }
    
}
