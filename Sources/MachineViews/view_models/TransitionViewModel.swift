//
//  File.swift
//  
//
//  Created by Morgan McColl on 18/4/21.
//

import Foundation
import TokamakShim
import Transformations
import Utilities
import GUUI
import Machines
import Attributes

final class TransitionViewModel: ObservableObject {
    
    private var machine: Binding<Machine>
    
    let path: Attributes.Path<Machine, Transition>
    
    var transitionBinding: Binding<Transition>
    
    @Published var tracker: TransitionTracker
    
    weak var notifier: GlobalChangeNotifier?
    
    var curve: Curve {
        get {
            tracker.curve
        }
        set {
            tracker.curve = newValue
        }
    }
    
    var location: CGPoint {
        get {
            tracker.location
        }
        set {
            tracker.location = newValue
        }
    }
    
    var condition: String {
        get {
            transitionBinding.wrappedValue.condition ?? ""
        } set {
            let result = machine.wrappedValue.modify(attribute: path.condition, value: newValue)
            guard let notifier = notifier, let hasTrigger = try? result.get(), hasTrigger == true else {
                self.objectWillChange.send()
                return
            }
            notifier.send()
        }
    }
    
    init(machine: Binding<Machine>, path: Attributes.Path<Machine, Transition>, transitionBinding: Binding<Transition>, curve: Curve, notifier: GlobalChangeNotifier? = nil) {
        self.machine = machine
        self.path = path
        self.transitionBinding = transitionBinding
        self.tracker = TransitionTracker(curve: curve)
        self.notifier = notifier
    }
    
    init(machine: Binding<Machine>, path: Attributes.Path<Machine, Transition>, transitionBinding: Binding<Transition>, point0: CGPoint, point1: CGPoint, point2: CGPoint, point3: CGPoint, notifier: GlobalChangeNotifier? = nil) {
        self.machine = machine
        self.path = path
        self.transitionBinding = transitionBinding
        self.tracker = TransitionTracker(point0: point0, point1: point1, point2: point2, point3: point3)
        self.notifier = notifier
    }
    
    init(machine: Binding<Machine>, path: Attributes.Path<Machine, Transition>, transitionBinding: Binding<Transition>, source: CGPoint, target: CGPoint, notifier: GlobalChangeNotifier? = nil) {
        self.machine = machine
        self.path = path
        self.transitionBinding = transitionBinding
        self.tracker = TransitionTracker(source: source, target: target)
        self.notifier = notifier
    }
    
    init(machine: Binding<Machine>, path: Attributes.Path<Machine, Transition>, transitionBinding: Binding<Transition>, source: StateViewModel, target: StateViewModel, notifier: GlobalChangeNotifier? = nil) {
        self.machine = machine
        self.path = path
        self.transitionBinding = transitionBinding
        self.tracker = TransitionTracker(source: source, target: target)
        self.notifier = notifier
    }
    
    init(machine: Binding<Machine>, path: Attributes.Path<Machine, Transition>, transitionBinding: Binding<Transition>, source: StateViewModel, sourcePoint: CGPoint, target: StateViewModel, targetPoint: CGPoint, notifier: GlobalChangeNotifier? = nil) {
        self.machine = machine
        self.path = path
        self.transitionBinding = transitionBinding
        self.tracker = TransitionTracker(source: source, sourcePoint: sourcePoint, target: target, targetPoint: targetPoint)
        self.notifier = notifier
    }
}

extension TransitionViewModel {

    convenience init(machine: Binding<Machine>, path: Attributes.Path<Machine, Transition>, transitionBinding: Binding<Transition>, plist data: String, notifier: GlobalChangeNotifier? = nil) {
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
            machine: machine,
            path: path,
            transitionBinding: transitionBinding,
            point0: CGPoint(x: point0X, y: point0Y),
            point1: CGPoint(x: point1X, y: point1Y),
            point2: CGPoint(x: point2X, y: point2Y),
            point3: CGPoint(x: point3X, y: point3Y),
            notifier: notifier
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

extension TransitionViewModel: Hashable {
    static func == (lhs: TransitionViewModel, rhs: TransitionViewModel) -> Bool {
        lhs === rhs
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(tracker)
    }
    
}
