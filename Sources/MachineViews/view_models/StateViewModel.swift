//
//  StateViewModel.swift
//  
//
//  Created by Morgan McColl on 15/11/20.
//

#if canImport(TokamakShim)
import TokamakShim
#else
import SwiftUI
#endif
import Machines
import Attributes

final class StateViewModel: DynamicViewModel, Identifiable, Equatable {
    
    static func == (lhs: StateViewModel, rhs: StateViewModel) -> Bool {
        lhs === rhs
    }
    
    @Reference public var machine: Machine
    
    let path: Attributes.Path<Machine, Machines.State>
    
    @Published var location: CGPoint
    
    @Published var __width: CGFloat
    
    var _width: CGFloat {
        get {
            __width
        }
        set {
            __width = newValue
        }
    }
    
    @Published var __height: CGFloat
    
    var _height: CGFloat {
        get {
            __height
        }
        set {
            __height = newValue
        }
    }
    
    @Published var expanded: Bool
    
    @Published var _collapsedWidth: CGFloat
    
    @Published var _collapsedHeight: CGFloat
    
    @Published var _collapsedActions: [String: Bool]
    
    var collapsedActions: [String: Bool] {
        get {
            actions.forEach() {
                guard let _ = _collapsedActions[$0.name] else {
                    _collapsedActions[$0.name] = false
                    return
                }
            }
            if actions.count != _collapsedActions.count {
                let actionsSet = Set(actions.map { $0.name })
                _collapsedActions.forEach {
                    if !actionsSet.contains($0.0) {
                        _collapsedActions.removeValue(forKey: $0.0)
                    }
                }
            }
            return _collapsedActions
        }
        set {
            _collapsedActions = newValue
        }
    }
    
    let collapsedMinWidth: CGFloat = 150.0
    
    let collapsedMinHeight: CGFloat = 100.0
    
    let collapsedMaxWidth: CGFloat = 750.0
    
    let collapsedMaxHeight: CGFloat = 500.0
    
    let minTitleHeight: CGFloat = 42.0
    
    let maxTitleHeight: CGFloat = 42.0
    
    var minTitleWidth: CGFloat {
        elementMinWidth - buttonDimensions
    }
    
    var maxTitleWidth: CGFloat {
        elementMaxWidth - buttonDimensions
    }
    
    let minWidth: CGFloat = 200.0
    
    let maxWidth: CGFloat = 1200.0
    
    var minHeight: CGFloat {
        CGFloat(actions.count - collapsedActions.count) * minActionHeight +
            CGFloat(collapsedActions.count) * minCollapsedActionHeight +
            minTitleHeight + bottomPadding + topPadding + 20.0
    }
    
    let maxHeight: CGFloat = 600.0
    
    let minEditWidth: CGFloat = 800.0
    
    let maxEditTitleHeight: CGFloat = 32.0
    
    let editActionPadding: CGFloat = 20.0
    
    let minEditActionHeight: CGFloat = 200.0
    
    let editPadding: CGFloat = 10.0
    
    let topPadding: CGFloat = 10.0
    
    let leftPadding: CGFloat = 20.0
    
    let rightPadding: CGFloat = 20.0
    
    let bottomPadding: CGFloat = 20.0
    
    let buttonSize: CGFloat = 8.0
    
    let buttonDimensions: CGFloat = 15.0
    
    let minActionHeight: CGFloat = 80.0
    
    let minCollapsedActionHeight: CGFloat = 20.0
    
    let horizontalEdgeTolerance: CGFloat = 20.0

    let verticalEdgeTolerance: CGFloat = 20.0
    
    let collapsedActionHeight: CGFloat = 16.0
    
    let actionPadding: CGFloat = 0.0
    
    public var name: String {
        String(machine[keyPath: path.path].name)
    }
    
    var actions: [Machines.Action] {
        machine[keyPath: path.path].actions
    }
    
    var attributes: [AttributeGroup] {
        machine[keyPath: path.path].attributes
    }
    
    var transitions: [Transition] {
        machine[keyPath: path.path].transitions
    }
    
    var transitionViewModels: [TransitionViewModel]
    
    var elementMinWidth: CGFloat {
        minWidth - leftPadding - rightPadding
    }
    
    var elementMaxWidth: CGFloat {
        width - leftPadding - rightPadding
    }
    
    var elementMinHeight: CGFloat {
        minHeight - topPadding - bottomPadding
    }
    
    var elementMaxHeight: CGFloat {
        height - topPadding - bottomPadding - 20.0
    }
    
    var isAccepting: Bool {
        machine[keyPath: path.path].transitions.isEmpty
    }
    
    var isEmpty: Bool {
        return nil == actions.first { !$0.implementation.isEmpty }
    }
    
    var actionsMaxHeight: CGFloat {
        elementMaxHeight - maxTitleHeight
    }
    
    var actionHeight: CGFloat {
        let expandedActions = collapsedActions.filter { $0.1 == false }.count
        if expandedActions == 0 {
            return collapsedActionHeight
        }
        let collapsedActionsNumber = CGFloat(actions.count - expandedActions)
        let availableSpace = actionsMaxHeight - CGFloat(actions.count) * actionPadding * 2.0 - collapsedActionsNumber * collapsedActionHeight
        return max(minActionHeight, availableSpace / CGFloat(expandedActions))
    }
    
    var isDragging: Bool = false
    
    var isStretchingX: Bool = false
    
    var isStretchingY: Bool = false
    
    var offset: CGPoint = CGPoint.zero
    
    @Published var highlighted: Bool
    
    var machineName: String {
        self.machine.name
    }
    
    var machineId: UUID {
        self.machine.id
    }
    
    var stateIndex: Int {
        self.machine.states.firstIndex(of: self.machine[keyPath: path.path]).wrappedValue
    }
    
    init(machine: Ref<Machine>, path: Attributes.Path<Machine, Machines.State>, location: CGPoint = CGPoint(x: 75, y: 100), width: CGFloat = 75.0, height: CGFloat = 100.0, expanded: Bool = false, collapsedHeight: CGFloat = 100.0, collapsedActions: [String: Bool] = [:], highlighted: Bool = false, transitionViewModels: [TransitionViewModel] = []) {
        self._machine = Reference(reference: machine)
        self.path = path
        self.location = CGPoint(x: max(0.0, location.x), y: max(0.0, location.y))
        self.__width = min(max(minWidth, width), maxWidth)
        self.__height = height
        self.expanded = expanded
        self._collapsedHeight = collapsedHeight
        self._collapsedWidth = collapsedMinWidth / collapsedMinHeight * collapsedHeight
        self._collapsedActions = collapsedActions
        self.highlighted = highlighted
        if transitionViewModels.count != machine.value[keyPath: path.path].transitions.count {
            fatalError("Not Enough transitions view models for machine.")
        }
        let transitionsSet = Set(transitionViewModels.map { $0.transition })
        machine.value[keyPath: path.path].transitions.forEach {
            if transitionsSet.contains($0) {
                return
            }
            fatalError("Not Enough transitions view models for machine.")
        }
        self.transitionViewModels = transitionViewModels
        self.listen(to: $machine)
    }
    
    init(machine: Ref<Machine>, path: Attributes.Path<Machine, Machines.State>, location: CGPoint = CGPoint(x: 75, y: 100), width: CGFloat = 75.0, height: CGFloat = 100.0, expanded: Bool = false, collapsedWidth: CGFloat = 150.0, collapsedActions: [String: Bool] = [:], highlighted: Bool = false, transitionViewModels: [TransitionViewModel] = []) {
        self._machine = Reference(reference: machine)
        self.path = path
        self.location = CGPoint(x: max(0.0, location.x), y: max(0.0, location.y))
        self.__width = min(max(minWidth, width), maxWidth)
        self.__height = height
        self.expanded = expanded
        self._collapsedWidth = collapsedWidth
        self._collapsedHeight = collapsedMinHeight / collapsedMinWidth * collapsedWidth
        self._collapsedActions = collapsedActions
        self.highlighted = highlighted
        if transitionViewModels.count != machine.value[keyPath: path.path].transitions.count {
            fatalError("Not Enough transitions view models for machine.")
        }
        let transitionsSet = Set(transitionViewModels.map { $0.transition })
        machine.value[keyPath: path.path].transitions.forEach {
            if transitionsSet.contains($0) {
                return
            }
            fatalError("Not Enough transitions view models for machine.")
        }
        self.transitionViewModels = transitionViewModels
        self.listen(to: $machine)
    }
    
    public convenience init(machine: Ref<Machine>, path: Attributes.Path<Machine, Machines.State>, location: CGPoint = CGPoint(x: 75, y: 100), width: CGFloat = 75.0, height: CGFloat = 100.0, expanded: Bool = false) {
        self.init(machine: machine, path: path, location: location, width: width, height: height, expanded: expanded, collapsedWidth: 150.0)
    }
    
    func isEmpty(forAction action: String) -> Bool {
        machine[keyPath: path.path].actions.first {
            $0.name == action
        }?.implementation.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ?? true
    }
    
    func createTitleView(forAction action: String, color: Color) -> AnyView {
        if self.isEmpty(forAction: action) {
            return AnyView(
                Text(action + ":").font(.headline).underline().italic().foregroundColor(color).frame(height: collapsedActionHeight)
            )
        }
        return AnyView(
            Text(action + ":").font(.headline).underline().foregroundColor(color).frame(height: collapsedActionHeight)
        )
    }
    
    func createCollapsedBinding(forAction action: String) -> Binding<Bool> {
        Binding(
            get: { self.collapsedActions[action] ?? false },
            set: { self.collapsedActions[action] = $0 }
        )
    }
    
    fileprivate func collapsedEdge(theta: Double) -> CGPoint {
        rectEdge(theta: theta)
    }
    
    fileprivate func staticHeightEdge(theta: Double) -> CGPoint {
        let pctTheta = 1.0 - (abs(theta) / (Double.pi / 4.0)).truncatingRemainder(dividingBy: 1.0)
        let dx = CGFloat(pctTheta * Double(abs(theta) > Double.pi / 2.0 ? -width : width))
        let dy = theta > 0 ? -height : height
        return CGPoint(x: location.x + dx, y: location.y + dy)
    }
    
    fileprivate func staticWidthEdge(theta: Double) -> CGPoint {
        let pctTheta = (abs(theta) / (Double.pi / 4.0)).truncatingRemainder(dividingBy: 1.0)
        let dx = abs(theta) <= Double.pi / 4.0 ? width : -width
        let dy = CGFloat(pctTheta * Double(theta > 0  ? -height : height ))
        return CGPoint(x: location.x + dx, y: location.y + dy)
    }
    
    fileprivate func rectEdge(theta: Double) -> CGPoint {
        if abs(theta) <= Double.pi / 4.0 {
            return staticWidthEdge(theta: theta)
        }
        if abs(theta) >= 3 * Double.pi / 4.0 {
            return staticWidthEdge(theta: theta)
        }
        return staticHeightEdge(theta: theta)
    }
    
    func edge(theta: Double) -> CGPoint {
        if expanded {
            return rectEdge(theta: theta)
        }
        return collapsedEdge(theta: theta)
    }
    
    func transitionViewModel(transition: Transition, index: Int, target destinationViewModel: StateViewModel) -> TransitionViewModel {
        let dx = destinationViewModel.location.x - location.x
        let dy = destinationViewModel.location.y - location.y
        let theta = atan2(Double(dy), Double(dx))
        let sourceEdge = edge(theta: theta)
        let destinationTheta = theta + Double.pi > Double.pi ? theta - Double.pi : theta + Double.pi
        let destinationEdge = destinationViewModel.edge(theta: destinationTheta)
        let tPath: Attributes.Path<Machine, Transition> = path.transitions[index]
        let priority = UInt8(index)
        return TransitionViewModel(
            machine: $machine,
            path: tPath,
            source: sourceEdge,
            destination: destinationEdge,
            priority: priority
        )
    }
    
    func getHeightOfAction(actionName: String) -> CGFloat {
        guard let collapsed = collapsedActions[actionName] else {
            return collapsedActionHeight
        }
        return collapsed ? collapsedActionHeight : actionHeight
    }
    
    func getHeightOfActionForEdit(height editHeight: CGFloat) -> CGFloat {
        let numberOfActions = CGFloat(actions.count)
        let availableSpace = editHeight - maxTitleHeight - editPadding * 2.0 - numberOfActions * editActionPadding
        return max(minEditActionHeight, availableSpace / numberOfActions)
    }
    
    fileprivate func colourPList() -> String {
        let helper = StringHelper()
        return "<dict>" +
            helper.tab(data: "<key>alpha</key>\n<real>1</real>\n<key>blue</key>\n<real>0.92000000000000004</real>" +
        "\n<key>green</key>\n<real>0.92000000000000004</real>\n<key>red</key>\n<real>0.92000000000000004</real>"
            )
            + "\n</dict>"
    }
    
    fileprivate func strokePlist() -> String {
        let helper = StringHelper()
        return "<dict>" +
            helper.tab(data: "<key>alpha</key>\n<real>1</real>\n<key>blue</key>\n<real>0.0</real>" +
        "\n<key>green</key>\n<real>0.0</real>\n<key>red</key>\n<real>0.0</real>"
            )
            + "\n</dict>"
    }
    
    fileprivate func boolToPlist(value: Bool) -> String {
        value ? "<true/>" : "<false/>"
    }
    
    fileprivate func actionHeightstoPList() -> String {
        let helper = StringHelper()
        return helper.reduceLines(data: actions.map {
            "<key>\($0.name)Height</key>\n<real>\(getHeightOfAction(actionName: $0.name))</real>"
        })
    }
    
    func toPList() -> String {
        let helper = StringHelper()
        let transitionPList = helper.reduceLines(data: transitionViewModels.map { $0.toPlist() })
        return "<key>\(name)</key>"
            + helper.tab(data: "<dict>\n" +
                helper.tab(data: "<key>Transitions</key>\n<array>\n" +
                    helper.tab(data: transitionPList)
                ) +
                "\n</array>\n" + colourPList() + "\n<key>editingMode</key>\n<false/>\n" +
                "<key>expanded</key>\n\(boolToPlist(value: expanded))\n" +
                "<key>h</key>\n<real>\(height)</real>\n" + actionHeightstoPList() +
                "\n<key>stateSelected</key>\n\(boolToPlist(value: highlighted))\n" +
                strokePlist() + "\n<key>w</key>\n<real>\(width)</real>\n<key>x</key>\n<real>\(location.x)</real>\n" +
                "<key>y</key>\n<real>\(location.y)</real>\n<key>zoomedInternalHeight</key>\n<real>0.0</real>\n" +
                "<key>zoomedOnEntryHeight</key>\n<real>0.0</real>\n<key>zoomedOnExitHeight</key>\n<real>0.0</real>"
            ) + "\n</dict>"
    }
    
}
