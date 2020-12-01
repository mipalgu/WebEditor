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
    
    @Published var point0ViewModel: RigidMoveableViewModel
    
    @Published var point1ViewModel: RigidMoveableViewModel
    
    @Published var point2ViewModel: RigidMoveableViewModel
    
    @Published var point3ViewModel: RigidMoveableViewModel
    
    @Published var priority: UInt8
    
    var point0: CGPoint {
        get {
            point0ViewModel.location
        }
        set {
            point0ViewModel.location = newValue
        }
    }
    
    var point1: CGPoint {
        get {
            point1ViewModel.location
        }
        set {
            point1ViewModel.location = newValue
        }
    }
    
    var point2: CGPoint {
        get {
            point2ViewModel.location
        }
        set {
            point2ViewModel.location = newValue
        }
    }
    
    var point3: CGPoint {
        get {
            point3ViewModel.location
        }
        set {
            point3ViewModel.location = newValue
        }
    }
    
    let pointDiameter: CGFloat
    
    let arrowHeadLength: Double = 50.0
    
    let basePriorityLength: CGFloat = 20.0
    
    let priorityScale: CGFloat = 0.2
    
    let strokeSeparation: CGFloat = 5.0
    
    var lineAngle: Double {
        let dx = Double(point1.x - point0.x)
        let dy = Double(point1.y - point0.y)
        return atan2(dy, dx)
    }
    
    var strokeAngle: Double {
        let unsanitisedTheta = lineAngle + Double.pi / 2.0
        if unsanitisedTheta > Double.pi {
            return unsanitisedTheta - Double.pi
        }
        return unsanitisedTheta
    }
    
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
    
    public var isDragging: Bool = false
    
    var startLocation: (CGPoint, CGPoint, CGPoint, CGPoint) = (.zero, .zero, .zero, .zero)
    
    public init(machine: Ref<Machine>, path: Attributes.Path<Machine, Transition>, point0: CGPoint, point1: CGPoint, point2: CGPoint, point3: CGPoint, priority: UInt8, pointDiameter: CGFloat = 10.0) {
        self._machine = Reference(reference: machine)
        self.path = path
        self.point0ViewModel = RigidMoveableViewModel(location: point0, width: pointDiameter, height: pointDiameter)
        self.point1ViewModel = RigidMoveableViewModel(location: point1, width: pointDiameter, height: pointDiameter)
        self.point2ViewModel = RigidMoveableViewModel(location: point2, width: pointDiameter, height: pointDiameter)
        self.point3ViewModel = RigidMoveableViewModel(location: point3, width: pointDiameter, height: pointDiameter)
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
    
    func strokeLength(transition: UInt8) -> CGFloat {
        if transition == 0 {
            return 0.0
        }
        return basePriorityLength + basePriorityLength * (CGFloat(transition) - 1.0 ) * priorityScale
    }
    
    func strokePoints(transition: UInt8) -> (CGPoint, CGPoint) {
        let length = strokeLength(transition: transition)
        let locationX = point0.x + strokeSeparation *  CGFloat(transition) * CGFloat(cos(lineAngle))
        let locationY = point0.y + strokeSeparation *  CGFloat(transition) * CGFloat(sin(lineAngle))
        let dx = length / 2.0 * CGFloat(cos(strokeAngle))
        let dy = length / 2.0 * CGFloat(sin(strokeAngle))
        let stroke0 = CGPoint(x: locationX + dx, y: locationY + dy)
        let stroke1 = CGPoint(x: locationX - dx, y: locationY - dy)
        return (stroke0, stroke1)
    }
    
    func translate(point: CGPoint, trans: CGSize) -> CGPoint {
        CGPoint(x: point.x - trans.width, y: point.y - trans.height)
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
