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
    
    var bottom: CGPoint {
        CGPoint(x: location.x, y: location.y + height / 2.0)
    }
    
    var top: CGPoint {
        CGPoint(x: location.x, y: location.y - height / 2.0)
    }
    
    var right: CGPoint {
        CGPoint(x: location.x + width / 2.0, y: location.y)
    }
    
    var left: CGPoint {
        CGPoint(x: location.x - width / 2.0, y: location.y)
    }
    
    func getLocation(width: CGFloat, height: CGFloat) -> CGPoint {
        let x = self.location.x
        let y = self.location.y
        return CGPoint(
            x: min(max(self.width / 2.0, x), width - self.width / 2.0),
            y: min(max(self.height / 2.0, y), height - self.height / 2.0)
        )
    }
    
    func setLocation(width: CGFloat, height: CGFloat, newLocation: CGPoint) {
        let x = newLocation.x
        let y = newLocation.y
        self.location = CGPoint(
            x: min(max(self.width / 2.0, x), width - self.width / 2.0),
            y: min(max(self.height / 2.0, y), height - self.height / 2.0)
        )
    }
    
}
