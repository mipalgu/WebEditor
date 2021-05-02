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

class TransitionTracker: Positionable, Hashable, ObservableObject {
    
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
    
}

extension TransitionTracker {

    convenience init(plist data: String) {
        let helper = StringHelper()
        let point0X = helper.getValueFromFloat(plist: data, label: "srcPointX")
        let point0Y = helper.getValueFromFloat(plist: data, label: "srcPointY")
        let point1X = helper.getValueFromFloat(plist: data, label: "controlPoint1X")
        let point1Y = helper.getValueFromFloat(plist: data, label: "controlPoint1Y")
        let point2X = helper.getValueFromFloat(plist: data, label: "controlPoint2X")
        let point2Y = helper.getValueFromFloat(plist: data, label: "controlPoint2Y")
        let point3X = helper.getValueFromFloat(plist: data, label: "dstPointX")
        let point3Y = helper.getValueFromFloat(plist: data, label: "dstPointY")
        self.init(
            point0: CGPoint(x: point0X, y: point0Y),
            point1: CGPoint(x: point1X, y: point1Y),
            point2: CGPoint(x: point2X, y: point2Y),
            point3: CGPoint(x: point3X, y: point3Y)
        )
    }

    fileprivate func floatToPList(key: String, point: CGFloat) -> String {
        return "<key>\(key)</key>\n<real>\(point)</real>\n"
    }

    func toPlist() -> String {
        let helper = StringHelper()
        return "<dict>\n" + helper.tab(
            data: floatToPList(key: "controlPoint1X", point: self.curve.point1.x) +
                floatToPList(key: "controlPoint1Y", point: self.curve.point1.y) +
                floatToPList(key: "controlPoint2X", point: self.curve.point2.x) +
                floatToPList(key: "controlPoint2Y", point: self.curve.point2.y) +
                floatToPList(key: "dstPointX", point: self.curve.point3.x) +
                floatToPList(key: "dstPointY", point: self.curve.point3.y) +
                floatToPList(key: "srcPointX", point: self.curve.point0.x) +
                floatToPList(key: "srcPointY", point: self.curve.point0.y)
        ) + "</dict>"
    }

}
