//
//  TransitionViewModel.swift
//  
//
//  Created by Morgan McColl on 22/11/20.
//

#if canImport(TokamakShim)
import TokamakShim
#else
import SwiftUI
#endif
import Machines
import Attributes

class TransitionViewModel: ObservableObject {
    
    @Reference var machine: Machine
    
    let path: Attributes.Path<Machine, Transition>
    
    @Published var point0: CGPoint
    
    @Published var point1: CGPoint
    
    @Published var point2: CGPoint
    
    @Published var point3: CGPoint
    
    @Published var priority: UInt8
    
    let pointDiameter: CGFloat = 5.0
    
    let arrowHeadLength: Double = 50.0
    
    var condition: String {
        get {
            String(machine[keyPath: path.path].condition ?? "")
        }
        set {
            do {
                try machine.modify(attribute: path.condition, value: Expression(newValue))
            } catch let error {
                print(error)
            }
        }
    }
    
    var conditionPosition: CGPoint {
        let dx = (point2.x - point1.x) / 2.0
        let dy = (point2.y - point1.y) / 2.0
        return CGPoint(x: point1.x + dx, y: point1.y + dy)
    }
    
    var arrowPoint0: CGPoint {
        let dx = point3.x - point2.x
        let dy = point3.y - point2.y
        let theta = atan2(Double(dy), Double(dx)) + Double.pi - Double.pi / 4.0
        let r = arrowHeadLength
        return CGPoint(x: point3.x + CGFloat(r * cos(theta)), y: point3.y + CGFloat(r * sin(theta)))
    }
    
    var arrowPoint1: CGPoint {
        let dx = point3.x - point2.x
        let dy = point3.y - point2.y
        let theta = atan2(Double(dy), Double(dx)) + Double.pi + Double.pi / 4.0
        let r = arrowHeadLength
        return CGPoint(x: point3.x + CGFloat(r * cos(theta)), y: point3.y + CGFloat(r * sin(theta)))
    }
    
    init(machine: Ref<Machine>, path: Attributes.Path<Machine, Transition>, source: CGPoint, destination: CGPoint, priority: UInt8) {
        self._machine = Reference(reference: machine)
        self.path = path
        self.point0 = source
        self.point3 = destination
        let dx = destination.x - source.x
        let dy = destination.y - source.y
        let r = sqrt(dx * dx + dy * dy)
        let theta = atan2(Double(dy), Double(dx))
        let rcost = r * CGFloat(cos(theta))
        let rsint = r * CGFloat(sin(theta))
        let p1x = source.x + 0.33 * rcost
        let p1y = source.y + 0.33 * rsint
        let p2x = source.x + 0.66 * rcost
        let p2y = source.y + 0.66 * rsint
        self.point1 = CGPoint(x: p1x, y: p1y)
        self.point2 = CGPoint(x: p2x, y: p2y)
        self.priority = priority
    }
    
    init(machine: Ref<Machine>, path: Attributes.Path<Machine, Transition>, point0: CGPoint, point1: CGPoint, point2: CGPoint, point3: CGPoint, priority: UInt8) {
        self._machine = Reference(reference: machine)
        self.path = path
        self.point0 = point0
        self.point1 = point1
        self.point2 = point2
        self.point3 = point3
        self.priority = priority
    }
    
}
