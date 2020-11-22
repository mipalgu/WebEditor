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

import Combine

public final class StateViewModel: ObservableObject, Stretchable, BoundedStretchable, Collapsable, Positionable, DynamicViewModel {
    
    @Reference public var machine: Machine
    
    let path: Attributes.Path<Machine, Machines.State>
    
    @Published var _location: CGPoint
    
    var location: CGPoint {
        get {
            _location
        }
        set {
            let minX = expanded ? width / 2.0 : collapsedWidth / 2.0
            let minY = expanded ? height / 2.0 : collapsedHeight / 2.0
            self._location = CGPoint(x: max(minX, newValue.x), y: max(minY, newValue.y))
        }
    }
    
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
    
    let maxHeight: CGFloat = 600.0
    
    let minEditWidth: CGFloat = 800.0
    
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
    
    public var name: String {
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
        machine[keyPath: path.path].transitions.isEmpty
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
    
    public init(machine: Ref<Machine>, path: Attributes.Path<Machine, Machines.State>, location: CGPoint = CGPoint(x: 75, y: 100), width: CGFloat = 75.0, height: CGFloat = 100.0, expanded: Bool = false, collapsedHeight: CGFloat = 100.0, collapsedActions: [String: Bool] = [:], highlighted: Bool = false) {
        self._machine = Reference(reference: machine)
        self.path = path
        self._location = CGPoint(x: max(0.0, location.x), y: max(0.0, location.y))
        self.__width = min(max(minWidth, width), maxWidth)
        self.__height = height
        self.expanded = expanded
        self._collapsedHeight = collapsedHeight
        self._collapsedWidth = collapsedMinWidth / collapsedMinHeight * collapsedHeight
        self.collapsedActions = collapsedActions
        self.highlighted = highlighted
        self.$machine.objectWillChange.subscribe(Subscribers.Sink(receiveCompletion: { _ in }, receiveValue: { self.objectWillChange.send() }))
    }
    
    public init(machine: Ref<Machine>, path: Attributes.Path<Machine, Machines.State>, location: CGPoint = CGPoint(x: 75, y: 100), width: CGFloat = 75.0, height: CGFloat = 100.0, expanded: Bool = false, collapsedWidth: CGFloat = 150.0, collapsedActions: [String: Bool] = [:], highlighted: Bool = false) {
        self._machine = Reference(reference: machine)
        self.path = path
        self._location = CGPoint(x: max(0.0, location.x), y: max(0.0, location.y))
        self.__width = min(max(minWidth, width), maxWidth)
        self.__height = height
        self.expanded = expanded
        self._collapsedWidth = collapsedWidth
        self._collapsedHeight = collapsedMinHeight / collapsedMinWidth * collapsedWidth
        self.collapsedActions = collapsedActions
        self.highlighted = highlighted
        self.$machine.objectWillChange.subscribe(Subscribers.Sink(receiveCompletion: { _ in }, receiveValue: { self.objectWillChange.send() }))
    }
    
    public convenience init(machine: Ref<Machine>, path: Attributes.Path<Machine, Machines.State>, location: CGPoint = CGPoint(x: 75, y: 100), width: CGFloat = 75.0, height: CGFloat = 100.0, expanded: Bool = false) {
        self.init(machine: machine, path: path, location: location, width: width, height: height, expanded: expanded, collapsedWidth: 150.0)
    }
    
    func isEmpty(forAction action: String) -> Bool {
        machine[keyPath: path.path].actions.first { $0.name == action }?.implementation.isEmpty ?? true
    }
    
    func toggleExpand() {
        expanded = !expanded
        self.location = _location
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
    
    func onTopEdge(point: CGPoint) -> Bool {
        let topEdge = self.location.y - height / 2.0
        let topEdgeAbove = topEdge - horizontalEdgeTolerance
        let topEdgeBelow = topEdge + horizontalEdgeTolerance
        let y = point.y
        return y >= topEdgeAbove && y <= topEdgeBelow
    }
    
    func onBottomEdge(point: CGPoint) -> Bool {
        let bottomEdge = self.location.y + height / 2.0
        let bottomEdgeAbove = bottomEdge - horizontalEdgeTolerance
        let bottomEdgeBelow = bottomEdge + horizontalEdgeTolerance
        let y = point.y
        return y >= bottomEdgeAbove && y <= bottomEdgeBelow
    }
    
    func onLeftEdge(point: CGPoint) -> Bool {
        let leftEdge = self.location.x - width / 2.0
        let leftBoundLower = leftEdge - verticalEdgeTolerance
        let leftBoundUpper = leftEdge + verticalEdgeTolerance
        let x = point.x
        return x >= leftBoundLower && x <= leftBoundUpper
    }
    
    func onRightEdge(point: CGPoint) -> Bool {
        let rightEdge = self.location.x + width / 2.0
        let rightBoundLower = rightEdge - verticalEdgeTolerance
        let rightBoundUpper = rightEdge + verticalEdgeTolerance
        let x = point.x
        return x >= rightBoundLower && x <= rightBoundUpper
    }
    
    func onTopRightCorner(point: CGPoint) -> Bool {
        return onTopEdge(point: point) && onRightEdge(point: point)
    }
    
    func onBottomRightCorner(point: CGPoint) -> Bool {
        return onBottomEdge(point: point) && onRightEdge(point: point)
    }
    
    func onBottomLeftCorner(point: CGPoint) -> Bool {
        return onBottomEdge(point: point) && onLeftEdge(point: point)
    }
    
    func onTopLeftCorner(point: CGPoint) -> Bool {
        return onTopEdge(point: point) && onLeftEdge(point: point)
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
    
    func stretchCorner(gesture: DragGesture.Value) {
        let point = gesture.location
        if onTopRightCorner(point: point) {
            self.width = stretchWidth(gesture: gesture)
            self.height = -stretchHeight(gesture: gesture)
            return
        }
        if onBottomRightCorner(point: point) {
            self.width = stretchWidth(gesture: gesture)
            self.height = stretchHeight(gesture: gesture)
            return
        }
        if onBottomLeftCorner(point: point) {
            self.width = -stretchWidth(gesture: gesture)
            self.height = stretchHeight(gesture: gesture)
            return
        }
        self.width = -stretchWidth(gesture: gesture)
        self.height = -stretchHeight(gesture: gesture)
    }
    
    func stretchHorizontal(gesture: DragGesture.Value) {
        if onRightEdge(point: gesture.location) {
            self.width = stretchWidth(gesture: gesture)
            return
        }
        self.width = -stretchWidth(gesture: gesture)
    }
    
    func stretchVertical(gesture: DragGesture.Value) {
        if onBottomEdge(point: gesture.location) {
            self.height = stretchHeight(gesture: gesture)
            return
        }
        self.height = -stretchHeight(gesture: gesture)
    }
    
    func onCorner(point: CGPoint) -> Bool {
        onTopRightCorner(point: point) || onBottomRightCorner(point: point) ||
            onBottomLeftCorner(point: point) || onTopLeftCorner(point: point)
    }
    
    func onVerticalEdge(point: CGPoint) -> Bool {
        onLeftEdge(point: point) || onRightEdge(point: point)
    }
    
    func onHorizontalEdge(point: CGPoint) -> Bool {
        onTopEdge(point: point) || onBottomEdge(point: point)
    }
    
    func handleDrag(gesture: DragGesture.Value) {
        if isDragging {
            updateLocationWithOffset(newLocation: gesture.location)
            return
        }
        if isStretchingX && isStretchingY {
            stretchCorner(gesture: gesture)
            return
        }
        if isStretchingX {
            stretchHorizontal(gesture: gesture)
            return
        }
        if isStretchingY {
            stretchVertical(gesture: gesture)
            return
        }
        if onCorner(point: gesture.startLocation) {
            isStretchingX = true
            isStretchingY = true
            return
        }
        if onVerticalEdge(point: gesture.startLocation) {
            isStretchingX = true
            return
        }
        if onHorizontalEdge(point: gesture.startLocation) {
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
        //self.handleDrag(gesture: gesture)
        self.isDragging = false
        self.isStretchingY = false
        self.isStretchingX = false
    }
    
    func finishCollapsedDrag(gesture: DragGesture.Value) {
        self.handleCollapsedDrag(gesture: gesture)
        self.isDragging = false
    }
    
}
