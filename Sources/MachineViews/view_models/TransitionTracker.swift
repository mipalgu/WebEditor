//
//  TransitionTracker.swift
//  
//
//  Created by Morgan McColl on 30/4/21.
//

import Foundation
import GUUI
import Transformations
import Utilities

class TransitionTracker: ObservableObject, Hashable, Positionable {
    
    static func == (lhs: TransitionTracker, rhs: TransitionTracker) -> Bool {
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    var id: UUID = UUID()
    
    @Published var curve: Curve
    
    var location: CGPoint {
        get {
            curve.point1 + (curve.point2 - curve.point1) / 2.0
        }
        set {
            return
        }
    }
    
    var layout: TransitionLayout {
        TransitionLayout(curve: curve)
    }
    
    init(curve: Curve) {
        self.curve = curve
    }
    
    convenience init(point0: CGPoint, point1: CGPoint, point2: CGPoint, point3: CGPoint) {
        self.init(curve: Curve(point0: point0, point1: point1, point2: point2, point3: point3))
    }
    
    init(source: CGPoint, target: CGPoint) {
        self.curve = Curve(source: source, target: target)
    }
    
    convenience init(source: StateTracker, target: StateTracker) {
        let dx = target.location.x - source.location.x
        let dy = target.location.y - source.location.y
        let angle = atan2(Double(dy), Double(dx)) / Double.pi * 180.0
        let sourceEdge = source.findEdge(degrees: CGFloat(angle))
        let targetAngle = angle + 180.0
        let targetEdge = target.findEdge(degrees: CGFloat(targetAngle))
        self.init(source: sourceEdge, target: targetEdge)
    }
    
    convenience init(source: StateTracker, sourcePoint: CGPoint, target: StateTracker, targetPoint: CGPoint) {
        var sourceEdge = source.findEdge(point: sourcePoint)
        var targetEdge = target.findEdge(point: targetPoint)
        let targetSourceEdge = source.findEdgeCenter(degrees: (targetEdge - source.location)<)
        let sourceCenter = source.findEdgeCenter(degrees: (sourceEdge - source.location)<)
        if targetSourceEdge != sourceCenter {
            if source.expanded {
                sourceEdge = source.moveToEdge(point: sourcePoint, edge: targetSourceEdge)
            } else {
                let sourceDeg = (sourceEdge - source.location)<
                let targetDeg = (targetEdge - source.location)<
                if abs(sourceDeg - targetDeg) > 90.0 {
                    sourceEdge = source.moveToEdge(point: sourcePoint, edge: targetSourceEdge)
                }
            }
        }
        let targetsPreferredEdge = target.findEdgeCenter(degrees: (sourceEdge - target.location)<)
        let targetEdgeCenter = target.findEdgeCenter(degrees: (targetEdge - target.location)<)
        if targetEdgeCenter != targetsPreferredEdge {
            if target.expanded {
                targetEdge = target.moveToEdge(point: targetEdge, edge: targetsPreferredEdge)
            } else {
                let targetSourceDeg = (sourceEdge - target.location)<
                let targetEdgeDeg = (targetEdge - target.location)<
                let dDeg = targetSourceDeg - targetEdgeDeg
                if dDeg > 90.0 {
                    targetEdge = target.findEdge(degrees: targetEdgeDeg + 90.0)
                }
                if dDeg < -90.0 {
                    targetEdge = target.findEdge(degrees: targetEdgeDeg - 90.0)
                }
            }
        }
        self.init(source: sourceEdge, target: targetEdge)
    }
    
    convenience init(layout: TransitionLayout) {
        self.init(curve: layout.curve)
    }
    
}
