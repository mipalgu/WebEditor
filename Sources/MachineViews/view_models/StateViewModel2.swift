//
//  File.swift
//  
//
//  Created by Morgan McColl on 17/4/21.
//

import TokamakShim

import Machines
import Attributes
import Transformations
import Utilities

final class ActionViewModel: ObservableObject, Hashable {
    
    static func == (lhs: ActionViewModel, rhs: ActionViewModel) -> Bool {
        lhs === rhs
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(path)
    }
    
    private var machine: Binding<Machine>
    
    let path: Attributes.Path<Machine, Action>
    
    var action: Binding<Action>
    
    weak var notifier: GlobalChangeNotifier?
    
    @Published var collapsed: Bool
    
    var errors: [String] {
        get {
            machine.wrappedValue.errorBag.errors(forPath: path).map(\.message)
        } set {}
    }
    
    var name: String {
        get {
            action.wrappedValue.name
        }
        set {
            let result = machine.wrappedValue.modify(attribute: path.name, value: newValue)
            guard let notifier = notifier, let hasTrigger = try? result.get(), hasTrigger == true else {
                self.objectWillChange.send()
                return
            }
            notifier.send()
        }
    }
    
    var implementation: Code {
        get {
            action.wrappedValue.implementation
        }
        set {
            let result = machine.wrappedValue.modify(attribute: path.implementation, value: newValue)
            guard let notifier = notifier, let hasTrigger = try? result.get(), hasTrigger == true else {
                self.objectWillChange.send()
                return
            }
            notifier.send()
        }
    }
    
    var language: Language {
        get {
            action.wrappedValue.language
        } set {
            let result = machine.wrappedValue.modify(attribute: path.language, value: newValue)
            guard let notifier = notifier, let hasTrigger = try? result.get(), hasTrigger == true else {
                self.objectWillChange.send()
                return
            }
            notifier.send()
        }
    }
    
    init(machine: Binding<Machine>, path: Attributes.Path<Machine, Action>, action: Binding<Action>, notifier: GlobalChangeNotifier? = nil, collapsed: Bool = false) {
        self.machine = machine
        self.path = path
        self.action = action
        self.notifier = notifier
        self.collapsed = collapsed
    }
    
}

final class StateTitleViewModel: ObservableObject {
    
    private var machine: Binding<Machine>
    
    let path: Attributes.Path<Machine, StateName>
    
    weak var notifier: GlobalChangeNotifier?
    
    var name: String {
        get {
            machine.wrappedValue[keyPath: path.path]
        } set {
            let result = machine.wrappedValue.modify(attribute: path, value: newValue)
            guard let notifier = notifier, let hasTrigger = try? result.get(), hasTrigger == true else {
                self.objectWillChange.send()
                return
            }
            notifier.send()
        }
    }
    
    var errors: [String] {
        get {
            machine.wrappedValue.errorBag.errors(forPath: path).map(\.message)
        } set {}
    }
    
    init(machine: Binding<Machine>, path: Attributes.Path<Machine, StateName>, notifier: GlobalChangeNotifier? = nil) {
        self.machine = machine
        self.path = path
        self.notifier = notifier
    }
    
}

final class StateViewModel2: ObservableObject {
    
    private var machine: Binding<Machine>
    
    let path: Attributes.Path<Machine, Machines.State>
    
    var state: Binding<Machines.State>
    
    @Published var tracker: StateTracker
    
    weak var notifier: GlobalChangeNotifier?
    
    var actions: [ActionViewModel]
    
    var transitions: [TransitionViewModel2]
    
    var title: StateTitleViewModel {
        StateTitleViewModel(machine: machine, path: path.name, notifier: notifier)
    }
    
    var location: CGPoint {
        get {
            tracker.location
        } set {
            tracker.location = newValue
        }
    }
    
    var expanded: Bool {
        get {
            tracker.expanded
        }
        set {
            tracker.expanded = newValue
        }
    }
    
    var expandedBinding: Binding<Bool> {
        Binding(get: { self.expanded }, set: { self.expanded = $0 })
    }
    
    var height: CGFloat {
        tracker.height
    }
    
    var isText: Bool {
        get {
            tracker.isText
        }
        set {
            tracker.isText = newValue
        }
    }
    
    var isStretchingX: Bool {
        get {
            tracker.isStretchingX
        }
        set {
            tracker.isStretchingX = newValue
        }
    }
    
    var isStretchingY: Bool {
        get {
            tracker.isStretchingY
        }
        set {
            tracker.isStretchingY = newValue
        }
    }
    
    var left: CGPoint {
        tracker.left
    }
    
    var width: CGFloat {
        tracker.width
    }
    
    init(machine: Binding<Machine>, path: Attributes.Path<Machine, Machines.State>, state: Binding<Machines.State>, notifier: GlobalChangeNotifier? = nil) {
        self.machine = machine
        self.path = path
        self.state = state
        self.tracker = StateTracker()
        self.notifier = notifier
        self.actions = state.wrappedValue.actions.indices.map {
            ActionViewModel(machine: machine, path: path.actions[$0], action: state.actions[$0], notifier: notifier, collapsed: false)
        }
        self.transitions = []
    }
    
    init(location: CGPoint = CGPoint(x: 75, y: 100), expandedWidth: CGFloat = 75.0, expandedHeight: CGFloat = 100.0, expanded: Bool = false, collapsedWidth: CGFloat = 150.0, collapsedHeight: CGFloat = 100.0, isText: Bool = false, machine: Binding<Machine>, path: Attributes.Path<Machine, Machines.State>, state: Binding<Machines.State>, notifier: GlobalChangeNotifier? = nil) {
        self.tracker = StateTracker(location: location, expandedWidth: expandedWidth, expandedHeight: expandedHeight, expanded: expanded, collapsedWidth: collapsedWidth, collapsedHeight: collapsedHeight, isText: isText)
        self.state = state
        self.notifier = notifier
        self.machine = machine
        self.path = path
        self.actions = state.wrappedValue.actions.indices.map {
            ActionViewModel(machine: machine, path: path.actions[$0], action: state.actions[$0], notifier: notifier, collapsed: false)
        }
        self.transitions = []
    }
    
    func findEdge(degrees: CGFloat) -> CGPoint {
        tracker.findEdge(degrees: degrees)
    }
    
    func findEdge(point: CGPoint) -> CGPoint {
        tracker.findEdge(point: point)
    }
    
    func findEdgeCenter(degrees: CGFloat) -> CGPoint {
        tracker.findEdgeCenter(degrees: degrees)
    }
    
    func moveToEdge(point: CGPoint, edge: CGPoint) -> CGPoint {
        tracker.moveToEdge(point: point, edge: edge)
    }
    
    func handleDrag(gesture: DragGesture.Value, frameWidth: CGFloat, frameHeight: CGFloat) {
        tracker.handleDrag(gesture: gesture, frameWidth: frameWidth, frameHeight: frameHeight)
    }
    
    func finishDrag(gesture: DragGesture.Value, frameWidth: CGFloat, frameHeight: CGFloat) {
        tracker.finishDrag(gesture: gesture, frameWidth: frameWidth, frameHeight: frameHeight)
    }
    
    func toggleExpand(frameWidth: CGFloat, frameHeight: CGFloat) {
        tracker.toggleExpand(frameWidth: frameWidth, frameHeight: frameHeight)
    }
    
    func isWithin(point: CGPoint) -> Bool {
        tracker.isWithin(point: point)
    }
    
    func isWithin(point: CGPoint, padding: CGFloat) -> Bool {
        tracker.isWithin(point: point, padding: padding)
    }
    
}

struct StateTracker: MoveAndStretchFromDrag, _Collapsable, Collapsable, EdgeDetector, TextRepresentable, BoundedSize, _Rigidable {
    
    var isText: Bool
    
    var isDragging: Bool = false
    
    var _collapsedWidth: CGFloat
    
    var _collapsedHeight: CGFloat
    
    var expanded: Bool
    
    var location: CGPoint

    let collapsedMinWidth: CGFloat = 150.0
    
    let collapsedMaxWidth: CGFloat = 250.0
    
    let collapsedMinHeight: CGFloat = 100.0
    
    let collapsedMaxHeight: CGFloat = 125.0
    
    var _expandedWidth: CGFloat
    
    var _expandedHeight: CGFloat
    
    var offset: CGPoint = CGPoint.zero
    
    let expandedMinWidth: CGFloat = 200.0
    
    let expandedMaxWidth: CGFloat = 600.0
    
    let expandedMinHeight: CGFloat = 150.0
    
    var expandedMaxHeight: CGFloat = 300.0
    
    var isStretchingX: Bool = false
    
    var isStretchingY: Bool = false
    
    let _collapsedTolerance: CGFloat = 0
    
    let _expandedTolerance: CGFloat = 20.0
    
    var horizontalEdgeTolerance: CGFloat {
        expanded ? _expandedTolerance : _collapsedTolerance
    }
    
    var verticalEdgeTolerance: CGFloat {
        horizontalEdgeTolerance
    }
    
    init(location: CGPoint = CGPoint(x: 75, y: 100), expandedWidth: CGFloat = 75.0, expandedHeight: CGFloat = 100.0, expanded: Bool = false, collapsedWidth: CGFloat = 150.0, collapsedHeight: CGFloat = 100.0, isText: Bool = false) {
        self.location = location
        self._expandedWidth = expandedWidth
        self._expandedHeight = expandedHeight
        self.expanded = expanded
        self._collapsedWidth = collapsedWidth
        self._collapsedHeight = collapsedHeight
        self.isText = isText
    }
    
    mutating func toggleExpand(frameWidth: CGFloat, frameHeight: CGFloat) {
        self.expanded = !self.expanded
        let newLocation: CGPoint
        if self.expanded {
            newLocation = CGPoint(
                x: self.location.x,
                y: self.location.y + collapsedHeight / 2.0
            )
        } else {
            newLocation = CGPoint(
                x: self.location.x,
                y: self.location.y - expandedHeight / 2.0
            )
        }
        self.setLocation(width: frameWidth, height: frameHeight, newLocation: newLocation)
    }

}

extension StateViewModel2 {

    convenience init(machine: Binding<Machine>, path: Attributes.Path<Machine, Machines.State>, state: Binding<Machines.State>, plist data: String, notifier: GlobalChangeNotifier? = nil) {
        let transitions = state.wrappedValue.transitions
        let helper = StringHelper()
        let x = helper.getValueFromFloat(plist: data, label: "x")
        let y = helper.getValueFromFloat(plist: data, label: "y")
        let w = helper.getValueFromFloat(plist: data, label: "w")
        let h = helper.getValueFromFloat(plist: data, label: "h")
        let expanded = helper.getValueFromBool(plist: data, label: "expanded")
//        let highlighted = helper.getValueFromBool(plist: data, label: "stateSelected")
        let transitionsPlist: String = data.components(separatedBy: "<key>Transitions</key>")[1].components(separatedBy: "<key>bgColour</key>")[0]
        let transitionViewModels = transitions.indices.map { (priority: Int) -> TransitionViewModel2 in
            let transitionPlist = transitionsPlist.components(separatedBy: "</dict>")[priority]
                .components(separatedBy: "<dict>")[1]
            return TransitionViewModel2(machine: machine, path: path.transitions[priority], transitionBinding: state.transitions[priority], plist: transitionPlist)
        }
        self.init(
            location: CGPoint(x: x, y: y),
            expandedWidth: CGFloat(w),
            expandedHeight: CGFloat(h),
            expanded: expanded,
            collapsedWidth: 150.0,
            collapsedHeight: 100.0,
            isText: false,
            machine: machine,
            path: path,
            state: state,
            notifier: notifier
        )
        self.transitions = transitionViewModels
    }

    fileprivate func colourPList() -> String {
        let helper = StringHelper()
        return "<dict>\n" +
            helper.tab(data: "<key>alpha</key>\n<real>1</real>\n<key>blue</key>\n<real>0.92000000000000004</real>" +
        "\n<key>green</key>\n<real>0.92000000000000004</real>\n<key>red</key>\n<real>0.92000000000000004</real>"
            )
            + "\n</dict>"
    }

    fileprivate func strokePlist() -> String {
        let helper = StringHelper()
        return "<dict>\n" +
            helper.tab(data: "<key>alpha</key>\n<real>1</real>\n<key>blue</key>\n<real>0.0</real>" +
        "\n<key>green</key>\n<real>0.0</real>\n<key>red</key>\n<real>0.0</real>"
            )
            + "\n</dict>"
    }

    fileprivate func boolToPlist(value: Bool) -> String {
        value ? "<true/>" : "<false/>"
    }

    fileprivate func actionHeightstoPList(state: Machines.State) -> String {
        let helper = StringHelper()
        return helper.reduceLines(data: state.actions.map {
            "<key>\($0.name)Height</key>\n<real>\(100.0)</real>"
        })
    }

    var plist: String {
        let helper = StringHelper()
        let transitionPList = helper.reduceLines(data: transitions.map { $0.toPlist() })
        return "<key>\(state.wrappedValue.name)</key>\n<dict>\n"
            + helper.tab(data: "<key>Transitions</key>\n\(transitions.count == 0 ? "<array/>" : "<array>")\n" +
                            helper.tab(data: transitionPList) + "\(transitions.count == 0 ? "" : "\n</array>")" +
                "\n<key>bgColour</key>\n" + colourPList() + "\n<key>editingMode</key>\n<false/>\n" +
                "<key>expanded</key>\n\(boolToPlist(value: expanded))\n" +
                            "<key>h</key>\n<real>\(height)</real>\n" + actionHeightstoPList(state: state.wrappedValue) +
                "\n<key>stateSelected</key>\n\(boolToPlist(value: false))\n<key>strokeColour</key>\n" +
                strokePlist() + "\n<key>w</key>\n<real>\(width)</real>\n<key>x</key>\n<real>\(location.x)</real>\n" +
                "<key>y</key>\n<real>\(location.y)</real>\n<key>zoomedInternalHeight</key>\n<real>0.0</real>\n" +
                "<key>zoomedOnEntryHeight</key>\n<real>0.0</real>\n<key>zoomedOnExitHeight</key>\n<real>0.0</real>"
            ) + "\n</dict>"
    }

}
