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
import Transformations
import Utilities

public final class TransitionViewModel: ObservableObject, Equatable, Hashable, Dragable {
    
    public static func == (lhs: TransitionViewModel, rhs: TransitionViewModel) -> Bool {
        lhs === rhs
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(machine)
        hasher.combine(path)
    }
    
    @Reference var machine: Machine
    
    let path: Attributes.Path<Machine, Transition>
    
    var transition: Transition {
        machine[keyPath: path.path]
    }
    
    @Published var priority: UInt8
    
    @Published var point0: CGPoint
    
    @Published var point1: CGPoint
    
    @Published var point2: CGPoint
    
    @Published var point3: CGPoint
    
    let pointDiameter: CGFloat
    
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
    
    public var isDragging: Bool = false
    
    var startLocation: (CGPoint, CGPoint, CGPoint, CGPoint) = (.zero, .zero, .zero, .zero)
    
    public init(machine: Ref<Machine>, path: Attributes.Path<Machine, Transition>, point0: CGPoint, point1: CGPoint, point2: CGPoint, point3: CGPoint, priority: UInt8, pointDiameter: CGFloat = 10.0) {
        self._machine = Reference(reference: machine)
        self.path = path
        self.point0 = point0
        self.point1 = point1
        self.point2 = point2
        self.point3 = point3
        self.priority = priority
        self.pointDiameter = pointDiameter
    }
    
    public convenience init(machine: Ref<Machine>, path: Attributes.Path<Machine, Transition>, source: CGPoint, destination: CGPoint, priority: UInt8, pointDiameter: CGFloat = 10.0) {
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
        self.init(machine: machine, path: path, point0: source, point1: CGPoint(x: p1x, y: p1y), point2: CGPoint(x: p2x, y: p2y), point3: destination, priority: priority, pointDiameter: pointDiameter)
    }
    
    public convenience init(machine: Ref<Machine>, path: Attributes.Path<Machine, Transition>, source: StateViewModel, destination: StateViewModel, priority: UInt8, pointDiameter: CGFloat = 10.0) {
        let dx = destination.location.x - source.location.x
        let dy = destination.location.y - source.location.y
        let theta = atan2(Double(dy), Double(dx))
        let sourceEdge = source.findEdge(radians: CGFloat(theta))
        let destinationTheta = theta + Double.pi > Double.pi ? theta - Double.pi : theta + Double.pi
        let destinationEdge = destination.findEdge(radians: CGFloat(destinationTheta))
        self.init(machine: machine, path: path, source: sourceEdge, destination: destinationEdge, priority: priority, pointDiameter: pointDiameter)
    }
    
    func translate(point: CGPoint, trans: CGSize) -> CGPoint {
        CGPoint(x: point.x + trans.width, y: point.y + trans.height)
    }
    
    func boundPoint(point: CGPoint, frameWidth: CGFloat, frameHeight: CGFloat) -> CGPoint {
        CGPoint(x: min(max(0, point.x), frameWidth), y: min(max(0, point.y), frameHeight))
    }
    
    private func boundTranslate(point: CGPoint, trans: CGSize, frameWidth: CGFloat, frameHeight: CGFloat) -> CGPoint {
        boundPoint(point: translate(point: point, trans: trans), frameWidth: frameWidth, frameHeight: frameHeight)
    }
    
    public func handleDrag(gesture: DragGesture.Value, frameWidth: CGFloat, frameHeight: CGFloat) {
        if isDragging {
            point0 = boundTranslate(point: startLocation.0, trans: gesture.translation, frameWidth: frameWidth, frameHeight: frameHeight)
            point1 = boundTranslate(point: startLocation.1, trans: gesture.translation, frameWidth: frameWidth, frameHeight: frameHeight)
            point2 = boundTranslate(point: startLocation.2, trans: gesture.translation, frameWidth: frameWidth, frameHeight: frameHeight)
            point3 = boundTranslate(point: startLocation.3, trans: gesture.translation, frameWidth: frameWidth, frameHeight: frameHeight)
            return
        }
        startLocation = (point0, point1, point2, point3)
        isDragging = true
    }
    
    public func finishDrag(gesture: DragGesture.Value, frameWidth: CGFloat, frameHeight: CGFloat) {
        handleDrag(gesture: gesture, frameWidth: frameWidth, frameHeight: frameHeight)
        isDragging = false
    }
    
}
