//
//  File.swift
//  
//
//  Created by Morgan McColl on 23/11/20.
//

import TokamakShim
import Foundation

import GUUI

public protocol _Rigidable {
    
    var _width: CGFloat { get set }
    
    var _height: CGFloat { get set }
    
}

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
    
    mutating func setLocation(width: CGFloat, height: CGFloat, newLocation: CGPoint) {
        let x = newLocation.x
        let y = newLocation.y
        self.location = CGPoint(
            x: min(max(self.width / 2.0, x), width - self.width / 2.0),
            y: min(max(self.height / 2.0, y), height - self.height / 2.0)
        )
    }
    
    func isWithin(point: CGPoint, padding: CGFloat) -> Bool {
        point.x >= left.x - padding && point.x <= right.x + padding && point.y >= top.y - padding && point.y <= bottom.y + padding
    }
    
    func isWithin(point: CGPoint) -> Bool {
        isWithin(point: point, padding: 0)
    }
    
    func findEdge(degrees: CGFloat) -> CGPoint {
        let normalisedDegrees = degrees.truncatingRemainder(dividingBy: 360.0)
        let theta = normalisedDegrees > 180.0 ? normalisedDegrees - 360.0 : normalisedDegrees
        if theta == 0.0 {
            return right
        }
        if theta == 90.0 {
            return bottom
        }
        if theta == -90.0 {
            return top
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
    
    func findEdge(point: CGPoint) -> CGPoint {
        let dx = point.x - location.x
        let dy = point.y - location.y
        let angle = atan2(Double(dy), Double(dx))
        let theta = angle / Double.pi * 180.0
        var x: CGFloat = 0
        var y: CGFloat = 0
        if theta >= -45.0 && theta <= 45.0 {
            x = right.x
            y = location.y + dx * CGFloat(tan(angle))
        } else if theta <= 135.0 && theta >= 45.0 {
            y = bottom.y
            x = location.x + dy / CGFloat(tan(angle))
        } else if theta < 180.0 && theta > 135.0 {
            x = left.x
            y = location.y + dx * CGFloat(tan(angle))
        } else if theta > -135.0 {
            y = top.y
            x = location.x + dy / CGFloat(tan(angle))
        } else {
            x = left.x
            y = location.y + dx * CGFloat(tan(angle))
        }
        return CGPoint(x: x, y: y)
    }
    
    func findEdgeCenter(degrees: CGFloat) -> CGPoint {
        let normalisedDegrees = degrees.truncatingRemainder(dividingBy: 360.0)
        let theta = normalisedDegrees > 180.0 ? normalisedDegrees - 360.0 : normalisedDegrees
        if theta >= -45.0 && theta <= 45.0 {
            return right
        } else if theta <= 135.0 && theta >= 45.0 {
            return bottom
        } else if theta >= -135.0 && theta < -45.0 {
            return top
        }
        return left
    }
    
    func findEdgeCenter(radians theta: CGFloat) -> CGPoint {
        findEdgeCenter(degrees: CGFloat(Double(theta) / Double.pi * 180.0))
    }
    
    func findEdgeCenter(point: CGPoint) -> CGPoint {
        let dx = point.x - location.x
        let dy = point.y - location.y
        let theta = CGFloat(atan2(Double(dy), Double(dx)))
        return findEdge(radians: theta)
    }
    
    
    
    func closestPointToTop(point: CGPoint) -> CGPoint {
        CGPoint(x: min(max(point.x, left.x), right.x), y: top.y)
    }
    
    func closestPointToBottom(point: CGPoint) -> CGPoint {
        CGPoint(x: min(max(point.x, left.x), right.x), y: bottom.y)
    }
        
    func closestPointToRight(point: CGPoint) -> CGPoint {
        CGPoint(x: right.x, y: min(max(point.y, top.y), bottom.y))
    }
        
    func closestPointToLeft(point: CGPoint) -> CGPoint {
        CGPoint(x: left.x, y: min(max(point.y, top.y), bottom.y))
    }
    
    func closestPointToEdge(point: CGPoint, degrees: CGFloat) -> CGPoint {
        let normalisedDegrees = degrees.truncatingRemainder(dividingBy: 360.0)
        let theta = normalisedDegrees > 180.0 ? normalisedDegrees - 360.0 : normalisedDegrees
        if theta >= -45.0 && theta <= 45.0 {
            return closestPointToRight(point: point)
        } else if theta <= 135.0 && theta >= 45.0 {
            return closestPointToBottom(point: point)
        } else if theta >= -135.0 && theta < -45.0 {
            return closestPointToTop(point: point)
        }
        return closestPointToLeft(point: point)
    }
    
    func closestPointToEdge(point: CGPoint, radians: CGFloat) -> CGPoint {
        closestPointToEdge(point: point, degrees: CGFloat(Double(radians) / Double.pi * 180.0))
    }
    
    func closestPointToEdge(point: CGPoint, source: CGPoint) -> CGPoint {
        let dx = source.x - location.x
        let dy = source.y - location.y
        let theta = CGFloat(atan2(Double(dy), Double(dx)))
        return closestPointToEdge(point: point, radians: theta)
    }
    
    func moveToEdge(point: CGPoint, edge: CGPoint) -> CGPoint {
        let relativeEdge = edge - point
        let angle = relativeEdge<
        if angle >= -45 && angle <= 45 || angle >= 135 || angle <= -135 {
            return CGPoint(x: edge.x, y: point.y)
        }
        return CGPoint(x: point.x, y: edge.y)
    }
    
}
