//
//  File.swift
//  
//
//  Created by Morgan McColl on 18/4/21.
//

import Foundation
import Transformations

struct Curve {
    
    var point0: CGPoint
    
    var point1: CGPoint
    
    var point2: CGPoint
    
    var point3: CGPoint
    
    init(point0: CGPoint, point1: CGPoint, point2: CGPoint, point3: CGPoint) {
        self.point0 = point0
        self.point1 = point1
        self.point2 = point2
        self.point3 = point3
    }
    
    init(source: CGPoint, target: CGPoint) {
        point0 = source
        point3 = target
        let middle = CGPoint(
            x: (target.x - source.x) / 2.0 + source.x,
            y: (target.y - source.y) / 2.0 + source.y
        )
        let quarter = CGPoint(
            x: (middle.x - source.x) / 2.0,
            y: (middle.y - source.y) / 2.0
        )
        point1 = CGPoint(
            x: source.x + quarter.x,
            y: source.y + quarter.y
        )
        point2 = CGPoint(
            x: target.x - quarter.x,
            y: target.y - quarter.y
        )
    }
    
}

struct TransitionViewModel2: Identifiable   {
    
    var id: UUID = UUID()
    
    var curve: Curve
    
    init(curve: Curve) {
        self.curve = curve
    }
    
    init(point0: CGPoint, point1: CGPoint, point2: CGPoint, point3: CGPoint) {
        self.init(curve: Curve(point0: point0, point1: point1, point2: point2, point3: point3))
    }
    
    init(source: CGPoint, target: CGPoint) {
        self.curve = Curve(source: source, target: target)
    }
    
    init(source: StateViewModel2, target: StateViewModel2) {
        let dx = target.location.x - source.location.x
        let dy = target.location.y - source.location.y
        let angle = atan2(Double(dy), Double(dx)) / Double.pi * 180.0
        let sourceEdge = source.findEdge(degrees: CGFloat(angle))
        let targetAngle = angle + 180.0
        let targetEdge = target.findEdge(degrees: CGFloat(targetAngle))
        self.init(source: sourceEdge, target: targetEdge)
    }
    
    init(source: StateViewModel2, sourcePoint: CGPoint, target: StateViewModel2, targetPoint: CGPoint) {
        let sourceEdge = source.findEdge(point: sourcePoint)
        let targetEdge = target.findEdge(point: targetPoint)
        self.init(source: sourceEdge, target: targetEdge)
    }
    
}
