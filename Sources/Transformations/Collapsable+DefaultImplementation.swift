//
//  File.swift
//  
//
//  Created by Morgan McColl on 23/11/20.
//

import TokamakShim
import Foundation

import GUUI

public protocol _Collapsable {
    
    var _collapsedWidth: CGFloat {get set}
    
    var _collapsedHeight: CGFloat {get set}
    
    var _expandedWidth: CGFloat { get set }
    
    var _expandedHeight: CGFloat { get set }
    
}

public extension Collapsable where Self: _Collapsable {
    
    var _width: CGFloat {
        get {
            if expanded {
                return expandedWidth
            }
            return collapsedWidth
        }
        set {
            if expanded {
                expandedWidth = newValue
                return
            }
            collapsedWidth = newValue
        }
    }
    
    var _height: CGFloat {
        get {
            if expanded {
                return expandedHeight
            }
            return collapsedHeight
        }
        set {
            if expanded {
                expandedHeight = newValue
                return
            }
            collapsedHeight = newValue
        }
    }
    
    var expandedWidth: CGFloat {
        get {
            max(min(_expandedWidth, expandedMaxWidth), expandedMinWidth)
        }
        set {
            _expandedWidth = max(min(newValue, expandedMaxWidth), expandedMinWidth)
        }
    }
    
    var expandedHeight: CGFloat {
        get {
            max(min(_expandedHeight, expandedMaxHeight), expandedMinHeight)
        }
        set {
            _expandedHeight = max(min(newValue, expandedMaxHeight), expandedMinHeight)
        }
    }
    
    var minWidth: CGFloat {
        if expanded {
            return expandedMinWidth
        }
        return collapsedMinWidth
    }
    
    var maxWidth: CGFloat {
        if expanded {
            return expandedMaxWidth
        }
        return collapsedMaxWidth
    }
    
    var minHeight: CGFloat {
        if expanded {
            return expandedMinHeight
        }
        return collapsedMinHeight
    }
    
    var maxHeight: CGFloat {
        if expanded {
            return expandedMaxHeight
        }
        return collapsedMaxHeight
    }
    
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
    
    var collapsedWidth: CGFloat {
        get {
            min(max(collapsedMinWidth, _collapsedWidth), collapsedMaxWidth)
        }
        set {
            let newWidth = min(max(collapsedMinWidth, newValue), collapsedMaxWidth)
            _collapsedWidth = newWidth
//            _collapsedHeight = collapsedMinHeight / collapsedMinWidth * newWidth
        }
    }
    
    var collapsedHeight: CGFloat {
        get {
            min(max(collapsedMinHeight, _collapsedHeight), collapsedMaxHeight)
        }
        set {
            let newHeight = min(max(collapsedMinHeight, newValue), collapsedMaxHeight)
            _collapsedHeight = newHeight
//            _collapsedWidth = collapsedMinWidth / collapsedMinHeight * newHeight
        }
    }
    
    mutating func toggleExpand(frameWidth: CGFloat, frameHeight: CGFloat) {
        self.expanded = !self.expanded
        self.setLocation(width: frameWidth, height: frameHeight, newLocation: self.location)
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
        if expanded {
            //Rectangle
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
        //Ellipse
        let radians = Double(theta) / 180.0 * Double.pi
        let tanr = tan(radians)
        let a = collapsedWidth / 2.0
        let b = collapsedHeight / 2.0
        var x: CGFloat = CGFloat(Double(a * b) /
            sqrt(Double(b * b) + Double(a * a) * tanr * tanr))
        var y: CGFloat = CGFloat(Double(a * b) * tanr /
            sqrt(Double(b * b) + Double(a * a) * tanr * tanr))
        if radians > Double.pi / 2.0 || radians < -Double.pi / 2.0 {
            x = -x
            y = -y
        }
        x = location.x + x
        y = location.y + y
        return CGPoint(x: x, y: y)
    }
    
    func findEdge(point: CGPoint) -> CGPoint {
        let dx = point.x - location.x
        let dy = point.y - location.y
        let angle = atan2(Double(dy), Double(dx))
        let theta = angle / Double.pi * 180.0
        if !expanded {
            return findEdge(degrees: CGFloat(theta))
        }
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
    
    func isWithin(point: CGPoint, padding: CGFloat) -> Bool {
        if expanded {
            return point.x >= left.x - padding && point.x <= right.x + padding && point.y >= top.y - padding && point.y <= bottom.y + padding
        }
        let dx = point.x - location.x
        let dy = point.y - location.y
        let angle = atan2(Double(dy), Double(dx)) / Double.pi * 180.0
        let edge = findEdge(degrees: CGFloat(angle))
        if angle >= 90 {
            return point.x >= edge.x - padding && point.y <= edge.y + padding
        }
        if angle <= -90 {
            return point.x >= edge.x - padding && point.y >= edge.y - padding
        }
        if angle >= 0 {
            return point.x <= edge.x + padding && point.y <= edge.y + padding
        }
        return point.x <= edge.x + padding && point.y >= edge.y - padding
        
    }
    
    func findEdgeCenter(degrees: CGFloat) -> CGPoint {
        if !expanded {
            return findEdge(degrees: degrees)
        }
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
    
    func moveToEdge(point: CGPoint, edge: CGPoint) -> CGPoint {
        if !expanded {
            return edge
        }
        let relativeEdge = edge - point
        let angle = relativeEdge<
        if angle >= -45 && angle <= 45 || angle >= 135 || angle <= -135 {
            return CGPoint(x: edge.x, y: point.y)
        }
        return CGPoint(x: point.x, y: edge.y)
    }
    
}
