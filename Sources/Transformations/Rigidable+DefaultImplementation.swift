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

public extension Rigidable where Self: Positionable {
    
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
    
    func isWithin(point: CGPoint) -> Bool {
        point.x >= left.x && point.x <= right.x && point.y >= top.y && point.y <= bottom.y
    }
    
    func findEdge(degrees: CGFloat) -> CGPoint {
        let normalisedDegrees = degrees.truncatingRemainder(dividingBy: 360.0)
        let theta = normalisedDegrees > 180.0 ? normalisedDegrees - 360.0 : normalisedDegrees
        if theta == 0.0 {
            return right
        }
        if theta == 90.0 {
            return top
        }
        if theta == -90.0 {
            return bottom
        }
        if theta == 180.0 || theta == -180.0 {
            return left
        }
        var x: CGFloat = 0
        var y: CGFloat = 0
        let angle = Double(theta / 180.0) * Double.pi
        if theta >= -45.0 && theta <= 45.0 {
            x = right.x
            y = location.y + x * CGFloat(tan(angle))
        } else if theta <= 135.0 && theta >= 45.0 {
            y = bottom.y
            x = location.x + y / CGFloat(tan(angle))
        } else if theta < 180.0 && theta > 135.0 {
            x = left.x
            y = location.y - x * CGFloat(tan(angle))
        } else if theta > -135.0 {
            y = top.y
            x = location.x - y / CGFloat(tan(angle))
        } else {
            x = left.x
            y = location.y - x * CGFloat(tan(angle))
        }
        return CGPoint(x: min(max(left.x, x), right.x), y: min(max(y, top.y), bottom.y))
    }
    
    func findEdge(radians theta: CGFloat) -> CGPoint {
        findEdge(degrees: CGFloat(Double(theta) / Double.pi * 180.0))
    }
    
}
