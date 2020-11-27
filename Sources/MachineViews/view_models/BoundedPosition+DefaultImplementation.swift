//
//  File.swift
//  
//
//  Created by Morgan McColl on 28/11/20.
//

#if canImport(TokamakShim)
import TokamakShim
#else
import SwiftUI
#endif

extension BoundedPosition {
    
    func getLocation(width: CGFloat, height: CGFloat) -> CGPoint {
        let x = self.location.x
        let y = self.location.y
        let parentBounded = CGPoint(x: min(max(0, x), width), y: min(max(0, y), height))
        return boundPoint(point: parentBounded)
    }
    
    func setLocation(width: CGFloat, height: CGFloat, newLocation: CGPoint) {
        let x = newLocation.x
        let y = newLocation.y
        let parentBounded = CGPoint(x: min(max(0, x), width), y: min(max(0, y), height))
        self.location = boundPoint(point: parentBounded)
    }
    
    func boundX(x: CGFloat) -> CGFloat {
        max(min(maxX, x), minX)
    }
    
    func boundY(y: CGFloat) -> CGFloat {
        max(min(maxY, y), minY)
    }
    
    func boundPoint(point: CGPoint) -> CGPoint {
        CGPoint(x: boundX(x: point.x), y: boundY(y: point.y))
    }
    
}
