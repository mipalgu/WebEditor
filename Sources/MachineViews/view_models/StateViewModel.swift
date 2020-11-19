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

public class StateViewModel: ObservableObject {
    
    @Published var _machine: Ref<Machine>
    
    var machine: Machine {
        get {
            _machine.value
        }
        set {
            _machine.value = newValue
        }
    }
    
    let path: Attributes.Path<Machine, Machines.State>
    
    @Published var location: CGPoint
    
    @Published fileprivate var _width: CGFloat
    
    @Published fileprivate var _height: CGFloat
    
    @Published var expanded: Bool
    
    @Published fileprivate var _collapsedWidth: CGFloat
    
    @Published fileprivate var _collapsedHeight: CGFloat
    
    @Published var collapsedActions: [String: Bool]
    
    var collapsedWidth: CGFloat {
        get {
            min(max(collapsedMinWidth, _collapsedWidth), collapsedMaxWidth)
        }
        set {
            let newWidth = min(max(collapsedMinWidth, newValue), collapsedMaxWidth)
            _collapsedWidth = newWidth
            _collapsedHeight = collapsedMinHeight / collapsedMinWidth * newWidth
        }
    }
    
    var collapsedHeight: CGFloat {
        get {
            min(max(collapsedMinHeight, _collapsedHeight), collapsedMaxHeight)
        }
        set {
            let newHeight = min(max(collapsedMinHeight, newValue), collapsedMaxHeight)
            _collapsedHeight = newHeight
            _collapsedWidth = collapsedMinWidth / collapsedMinHeight * newHeight
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
    
    let maxHeight: CGFloat = 1200.0
    
    let minEditWidth: CGFloat = 800.0
    
    let topPadding: CGFloat = 10.0
    
    let leftPadding: CGFloat = 20.0
    
    let rightPadding: CGFloat = 20.0
    
    let bottomPadding: CGFloat = 20.0
    
    let buttonSize: CGFloat = 8.0
    
    let buttonDimensions: CGFloat = 15.0
    
    let minActionHeight: CGFloat = 80.0
    
    let minCollapsedActionHeight: CGFloat = 20.0
    
    let edgeTolerance: CGFloat = 20.0
    
    var width: CGFloat {
        get {
            min(max(_width, minWidth), maxWidth)
        }
        set {
            _width = min(max(minWidth, newValue), maxWidth)
        }
    }

    var height: CGFloat {
        get {
            min(max(_height, minHeight), maxHeight)
        }
        set {
            _height = min(max(minHeight, newValue), maxHeight)
        }
    }
    
    var name: String {
        String(machine[keyPath: path.path].name)
    }
    
    var actions: [Machines.Action] {
        machine[keyPath: path.path].actions
    }
    
    var attributes: [AttributeGroup] {
        machine[keyPath: path.path].attributes
    }
    
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
        height - topPadding - bottomPadding
    }
    
    var isAccepting: Bool {
        machine[keyPath: path.path].transitions(in: machine).count == 0
    }
    
    var isEmpty: Bool {
        return nil == actions.first { !$0.implementation.isEmpty }
    }
    
    var actionsMaxHeight: CGFloat {
        elementMaxHeight - maxTitleHeight
    }
    
    var isDragging: Bool = false
    
    var isStretchingX: Bool = false
    
    var isStretchingY: Bool = false
    
    var offset: CGPoint = CGPoint.zero
    
    public init(machine: Ref<Machine>, path: Attributes.Path<Machine, Machines.State>, location: CGPoint = CGPoint(x: 75, y: 100), width: CGFloat = 75.0, height: CGFloat = 100.0, expanded: Bool = false, collapsedHeight: CGFloat = 100.0, collapsedActions: [String: Bool] = [:]) {
        self._machine = machine
        self.path = path
        self.location = location
        self._width = min(max(minWidth, width), maxWidth)
        self._height = height
        self.expanded = expanded
        self._collapsedHeight = collapsedHeight
        self._collapsedWidth = collapsedMinWidth / collapsedMinHeight * collapsedHeight
        self.collapsedActions = collapsedActions
    }
    
    public init(machine: Ref<Machine>, path: Attributes.Path<Machine, Machines.State>, location: CGPoint = CGPoint(x: 75, y: 100), width: CGFloat = 75.0, height: CGFloat = 100.0, expanded: Bool = false, collapsedWidth: CGFloat = 150.0, collapsedActions: [String: Bool] = [:]) {
        self._machine = machine
        self.path = path
        self.location = location
        self._width = min(max(minWidth, width), maxWidth)
        self._height = height
        self.expanded = expanded
        self._collapsedWidth = collapsedWidth
        self._collapsedHeight = collapsedMinHeight / collapsedMinWidth * collapsedWidth
        self.collapsedActions = collapsedActions
    }
    
    public convenience init(machine: Ref<Machine>, path: Attributes.Path<Machine, Machines.State>, location: CGPoint = CGPoint(x: 75, y: 100), width: CGFloat = 75.0, height: CGFloat = 100.0, expanded: Bool = false) {
        self.init(machine: machine, path: path, location: location, width: width, height: height, expanded: expanded, collapsedWidth: 150.0)
    }
    
    func isEmpty(forAction action: String) -> Bool {
        machine[keyPath: path.path].actions.first { $0.name == action }?.implementation.isEmpty ?? true
    }
    
    func toggleExpand() {
        expanded = !expanded
    }
    
    func createTitleView(forAction action: String, color: Color) -> AnyView {
        if self.isEmpty(forAction: action) {
            return AnyView(
                Text(action + ":").font(.headline).underline().italic().foregroundColor(color)
            )
        }
        return AnyView(
            Text(action + ":").font(.headline).underline().foregroundColor(color)
        )
    }
    
    func createCollapsedBinding(forAction action: String) -> Binding<Bool> {
        Binding(
            get: { self.collapsedActions[action] ?? false },
            set: { self.collapsedActions[action] = $0 }
        )
    }
    
    func onVerticalEdge(point: CGPoint) -> Bool {
        let leftEdge = self.location.x - width / 2.0
        let rightEdge = self.location.x + width / 2.0
        let leftBoundLower = leftEdge - edgeTolerance
        let leftBoundUpper = leftEdge + edgeTolerance
        let rightBoundLower = rightEdge - edgeTolerance
        let rightBoundUpper = rightEdge + edgeTolerance
        let x = point.x
        return (x >= leftBoundLower && x <= leftBoundUpper) || (x >= rightBoundLower && x <= rightBoundUpper)
    }
    
    func onHorizontalEdge(point: CGPoint) -> Bool {
        let topEdge = self.location.y - height / 2.0
        let bottomEdge = self.location.y + height / 2.0
        let topEdgeAbove = topEdge - edgeTolerance
        let topEdgeBelow = topEdge + edgeTolerance
        let bottomEdgeAbove = bottomEdge - edgeTolerance
        let bottomEdgeBelow = bottomEdge + edgeTolerance
        let y = point.y
        return (y >= topEdgeAbove && y <= topEdgeBelow) || (y >= bottomEdgeAbove && y <= bottomEdgeBelow)
    }
    
    func onCorner(point: CGPoint) -> Bool {
        return onHorizontalEdge(point: point) && onVerticalEdge(point: point)
    }
    
    func updateLocationWithOffset(newLocation: CGPoint) {
        let dx = newLocation.x - offset.x
        let dy = newLocation.y - offset.y
        self.location = CGPoint(x: dx, y: dy)
    }
    
    func stretchWidth(gesture: DragGesture.Value) -> CGFloat {
        (gesture.location.x - location.x) * 2.0
    }
    
    func stretchHeight(gesture: DragGesture.Value) -> CGFloat {
        (gesture.location.y - location.y) * 2.0
    }
    
    func handleDrag(gesture: DragGesture.Value) {
        if isDragging {
            updateLocationWithOffset(newLocation: gesture.location)
            return
        }
        if isStretchingX {
            self.width = stretchWidth(gesture: gesture)
            return
        }
        if isStretchingY {
            self.height = stretchHeight(gesture: gesture)
            return
        }
        if onCorner(point: gesture.startLocation) {
            self.height = stretchHeight(gesture: gesture)
            self.width = stretchWidth(gesture: gesture)
            isStretchingX = true
            isStretchingY = true
            return
        }
        if onVerticalEdge(point: gesture.startLocation) {
            self.width = stretchWidth(gesture: gesture)
            isStretchingX = true
            return
        }
        if onHorizontalEdge(point: gesture.startLocation) {
            self.height = stretchHeight(gesture: gesture)
            isStretchingY = true
            return
        }
        offset = CGPoint(x: gesture.startLocation.x - location.x, y: gesture.startLocation.y - location.y)
        isDragging = true
    }
    
    func handleCollapsedDrag(gesture: DragGesture.Value) {
        if !isDragging {
            offset = CGPoint(x: gesture.startLocation.x - location.x, y: gesture.startLocation.y - location.y)
            isDragging = true
        }
        updateLocationWithOffset(newLocation: gesture.location)
    }
    
    func finishDrag(gesture: DragGesture.Value) {
        self.handleDrag(gesture: gesture)
        self.isDragging = false
        self.isStretchingY = false
        self.isStretchingX = false
    }
    
    func finishCollapsedDrag(gesture: DragGesture.Value) {
        self.handleCollapsedDrag(gesture: gesture)
        self.isDragging = false
    }
    
}
