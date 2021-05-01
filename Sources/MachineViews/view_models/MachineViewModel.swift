//
//  MachineViewModel.swift
//  
//
//  Created by Morgan McColl on 30/4/21.
//

import Foundation
import TokamakShim
import Machines
import Utilities

class MachineViewModel: ObservableObject, GlobalChangeNotifier {
    
    var cache: ViewCache
    
    var isMoving: Bool = false
    
    var isStateMoving: Bool = false
    
    var machineBinding: Binding<Machine>
    
    var movingSourceTransitions: [CGPoint] = []
    
    var movingState: StateName = ""
    
    var movingTargetTransitions: [StateName: IndexSet] = [:]
    
    var originalDimensions: (CGFloat, CGFloat) = (0.0, 0.0)
    
    var startLocations: [StateName: CGPoint] = [:]
    
    var transitionStartLocations: [StateName: [Curve]] = [:]
    
    var machine: Machine {
        machineBinding.wrappedValue
    }
    
    fileprivate init() {
        self.machineBinding = .constant(Machine.initialSwiftMachine())
        cache = ViewCache(empty: self.machineBinding)
        cache = ViewCache(machine: self.machineBinding, notifier: self)
        
    }
    
    init(machine: Binding<Machine>) {
        self.machineBinding = machine
        self.cache = ViewCache(empty: machine)
        self.cache = ViewCache(machine: machine, notifier: self)
    }
    
    func addSelectedState(view: CanvasView, at index: Int) {
        addSelected(view: view, focus: .state(stateIndex: index), selected: .state(stateIndex: index))
    }
    
    func addSelectedTransition(view: CanvasView, from state: Int, at index: Int) {
        addSelected(
            view: view,
            focus: .transition(stateIndex: state, transitionIndex: index),
            selected: .transition(stateIndex: state, transitionIndex: index)
        )
    }
    
    func clampPosition(point: CGPoint, frame: CGSize, dx: CGFloat = 0.0, dy: CGFloat = 0.0) -> CGPoint {
        var newX: CGFloat = point.x
        var newY: CGFloat = point.y
        if point.x < dx {
            newX = dx
        } else if point.x > frame.width - dx {
            newX = frame.width - dx
        }
        if point.y < dy {
            newY = dy
        } else if point.y > frame.height - dy {
            newY = frame.height - dy
        }
        return CGPoint(x: newX, y: newY)
    }
    
    func createState() {
        let result = machineBinding.wrappedValue.newState()
        guard let _ = try? result.get() else {
            return
        }
        let newStateIndex = machine.states.count - 1
        if !cache.addNewState(state: machineBinding.states[newStateIndex]) {
            fatalError("Created state but failed to create view models")
        }
        self.objectWillChange.send()
    }
    
    func createTransitionGesture(forView view: CanvasView, forState index: Int) -> some Gesture {
        DragGesture(minimumDistance: 0, coordinateSpace: .named(view.coordinateSpace))
            .modifiers(.command)
            .onChanged {
                view.creatingCurve = Curve(source: $0.startLocation, target: $0.location)
            }
            .modifiers(.command)
            .onEnded { gesture in
                view.creatingCurve = nil
                let stateName = self.machine.states[index].name
                guard let targetName = self.findOverlappingState(point: gesture.location) else {
                    return
                }
                let result = self.machineBinding.wrappedValue.newTransition(
                    source: self.machine.states[index].name,
                    target: targetName
                )
                guard let _ = try? result.get() else {
                    return
                }
                let lastIndex = self.machine.states[index].transitions.count - 1
                guard lastIndex >= 0 else {
                    return
                }
                let result2 = self.machineBinding.wrappedValue.modify(
                    attribute: self.machine.path.states[index].transitions[lastIndex].condition,
                    value: "true"
                )
                guard let _ = try? result2.get() else {
                    return
                }
                if !self.cache.addNewTransition(
                    for: stateName,
                    transition: self.machineBinding.states[index].transitions[lastIndex],
                    startLocation: gesture.startLocation,
                    endLocation: gesture.location
                ) {
                    fatalError("Created transition but couldn't create view models.")
                }
                self.objectWillChange.send()
            }
    }
    
    func deleteSelected(_ view: CanvasView) {
        let stateIndexes = stateIndexes(from: view.selectedObjects)
        let result = machineBinding.wrappedValue.delete(states: stateIndexes)
        guard let _ = try? result.get() else {
            print(machine.errorBag.allErrors.description)
            return
        }
        let stateNames = states(from: view.selectedObjects).map(\.name)
        let _ = cache.deleteStates(names: stateNames)
        view.selectedObjects = []
        view.focus = .machine
        self.objectWillChange.send()
    }
    
    func deleteState(view: CanvasView, at index: Int) {
        let name = machine.states[index].name
        let result = machineBinding.wrappedValue.deleteState(atIndex: index)
        guard let _ = try? result.get() else {
            print(machine.errorBag.errors(includingDescendantsForPath: machine.path.states[index]))
            return
        }
        let _ = cache.deleteState(name: name)
        removeViewFocus(view: view, focus: .state(stateIndex: index), selected: .state(stateIndex: index))
        self.objectWillChange.send()
    }
    
    func deleteTransition(view: CanvasView, for stateIndex: Int, at transitionIndex: Int) {
        guard machine.states.count > stateIndex else {
            return
        }
        let stateName = machine.states[stateIndex].name
        let result = machineBinding.wrappedValue.deleteTransition(atIndex: transitionIndex, attachedTo: stateName)
        guard let _ = try? result.get() else {
            return
        }
        let _ = cache.deleteTransition(from: stateName, at: transitionIndex)
        removeViewFocus(
            view: view,
            focus: .transition(stateIndex: stateIndex, transitionIndex: transitionIndex),
            selected: .transition(stateIndex: stateIndex, transitionIndex: transitionIndex)
        )
        self.objectWillChange.send()
    }
    
    func dragCanvasGesture(coordinateSpace: String, size: CGSize) -> some Gesture {
        DragGesture(minimumDistance: 0, coordinateSpace: .named(coordinateSpace))
            .onChanged {
                self.moveElements(gesture: $0, frame: size)
                self.objectWillChange.send()
            }.onEnded {
                self.finishMoveElements(gesture: $0, frame: size)
                self.objectWillChange.send()
            }
    }
    
    func dragStateGesture(forView view: CanvasView, forState index: Int, size: CGSize) -> some Gesture {
        DragGesture(minimumDistance: 0, coordinateSpace: .named(view.coordinateSpace))
            .onChanged {
                self.cache.handleDrag(for: self.machine.states[index], gesture: $0, frame: size)
                let tracker = self.cache.tracker(for: self.machine.states[index])
                if !tracker.isStretchingX && !tracker.isStretchingY {
                    self.moveTransitions(state: self.machine.states[index].name, gesture: $0, frame: size)
                } else {
                    self.stretchTransitions(state: self.machine.states[index].name)
                }
                self.objectWillChange.send()
            }.onEnded {
                self.finishMovingTransitions()
                self.cache.finishDrag(for: self.machine.states[index], gesture: $0, frame: size)
                self.objectWillChange.send()
            }
    }
    
    func finishMoveElements(gesture: DragGesture.Value, frame: CGSize) {
        moveElements(gesture: gesture, frame: frame)
        isMoving = false
        self.objectWillChange.send()
    }
    
    func selectAll(_ view: CanvasView) {
        view.selectedObjects = Set(
            machine.states.indices.map {
                ViewType.state(stateIndex: $0)
            } +
            machine.states.indices.flatMap { stateIndex in
                machine.states[stateIndex].transitions.indices.map { transitionIndex in
                    ViewType.transition(stateIndex: stateIndex, transitionIndex: transitionIndex)
                }
            }
        )
    }
    
    /// Creates a gesture for dragging a selection box.
    /// - Parameter view: The view using the gesture.
    /// - Returns: The gesture.
    func selectionBoxGesture(forView view: CanvasView) -> some Gesture {
        DragGesture(minimumDistance: 0, coordinateSpace: .named(view.coordinateSpace))
            .modifiers(.shift)
            .onChanged {
                view.selectedBox = ($0.startLocation, $0.location)
            }
            .modifiers(.shift)
            .onEnded {
                view.selectedObjects = self.findObjectsInSelection(corner0: $0.startLocation, corner1: $0.location)
                view.selectedBox = nil
            }
    }
    
    func send() {
        self.objectWillChange.send()
    }
    
    func straighten(state: StateName, transitionIndex: Int) {
        let tracker = cache.tracker(for: transitionIndex, originating: state)
        if !cache.updateTracker(
            for: transitionIndex,
            in: state,
            newTracker: TransitionTracker(
                source: tracker.curve.point0,
                target: tracker.curve.point3
            )
        ) { return }
        self.objectWillChange.send()
    }
    
    func tracker(for state: StateName) -> StateTracker {
        self.cache.tracker(for: state)
    }
    
    func tracker(for transition: Int, originating from: StateName) -> TransitionTracker {
        self.cache.tracker(for: transition, originating: from)
    }
    
    func transition(for transition: Int, in state: StateName) -> TransitionViewModel {
        self.cache.viewModel(for: transition, originating: state)
    }
    
    func updateTransitionLocations(source: Machines.State) {
        updateTransitionsSources(source: source)
        updateTransitionsTargets(source: source)
        self.objectWillChange.send()
    }
    
    func viewModel(for stateName: StateName) -> StateViewModel {
        self.cache.viewModel(for: stateName)
    }
    
    private func addSelected(view: CanvasView, focus: Focus, selected: ViewType) {
        view.selectedObjects.insert(selected)
        if view.selectedObjects.count == 1 {
            view.focus = focus
            return
        }
        view.focus = .machine
    }
    
    private func displaceTransitions(sourceTransitions: [CGPoint], targetTransitions: [StateName: IndexSet], dS: CGSize, frame: CGSize, source: StateName) {
        guard let state = machine.states.first(where: { $0.name == source }) else {
            return
        }
        sourceTransitions.indices.forEach {
            let newX = min(max(0, sourceTransitions[$0].x + dS.width), frame.width)
            let newY = min(max(0, sourceTransitions[$0].y + dS.height), frame.height)
            let point = CGPoint(x: newX, y: newY)
            if !self.cache.updateTracker(for: $0, in: state, point0: point) {
                fatalError("Cannot move transition")
            }
        }
        targetTransitions.keys.forEach { name in
            let validIndexes = targetTransitions[name]!
            guard let stateIndex = machine.states.firstIndex(where: { $0.name == name }) else {
                return
            }
            machine.states[stateIndex].transitions.indices.forEach {
                if !validIndexes.contains($0) {
                    return
                }
                let sourceState = machine.states[stateIndex]
                let tracker = self.cache.tracker(for: $0, originating: name)
                let newX = min(max(0, tracker.curve.point3.x + dS.width), frame.width)
                let newY = min(max(0, tracker.curve.point3.y + dS.height), frame.height)
                let point = CGPoint(x: newX, y: newY)
                if !self.cache.updateTracker(for: $0, in: sourceState, point3: point) {
                    fatalError("Cannot move transition")
                }
            }
        }
    }
    
    private func findMovingTransitions(state: StateName) -> ([CGPoint], [StateName: IndexSet]) {
        movingState = state
        let movingSources = self.cache.trackers(for: state).map(\.curve.point0)
        let movingTargets = self.cache.transitions(target: state)
        var movingIndices: [StateName: IndexSet] = [:]
        movingTargets.keys.forEach { sourceName in
            let candidates = movingTargets[sourceName]!
            let transitions = self.cache.transitions(source: sourceName)
            movingIndices[sourceName] = IndexSet(transitions.indices.filter { index in
                candidates.contains(transitions[index])
            })
        }
        return (movingSources, movingIndices)
    }
    
    
    /// Finds all the views within the selection box.
    /// - Parameters:
    ///   - corner0: A corner of the selection box.
    ///   - corner1: The second corner of the selection box (opposite to corner0).
    /// - Returns: A set of ViewTypes signifying the views within the selection box.
    private func findObjectsInSelection(corner0: CGPoint, corner1: CGPoint) -> Set<ViewType> {
        findSelectedStates(corner0: corner0, corner1: corner1).union(findSelectedTransitions(corner0: corner0, corner1: corner1))
    }
        
    private func findOverlappingState(point: CGPoint) -> StateName? {
        self.cache.overlappingState(point: point)
    }
    
    
    /// Finds the states within the selection box.
    /// - Parameters:
    ///   - corner0: A corner of the selection box.
    ///   - corner1: The second corner of the selection box (opposite to corner0).
    /// - Returns: A set of ViewTypes signifying the states within the selection box.
    private func findSelectedStates(corner0: CGPoint, corner1: CGPoint) -> Set<ViewType> {
        let allStates = machine.states
        let focusedStates = allStates.indices.filter {
            let position =  self.cache.tracker(for: allStates[$0]).location
            return isWithinBound(corner0: corner0, corner1: corner1, position: position)
        }.map { ViewType.state(stateIndex: $0) }
        return Set(focusedStates)
    }
    
    
    /// Finds the transitions within the selection box.
    /// - Parameters:
    ///   - corner0: A corner of the selection box.
    ///   - corner1: The second corner of the selection box (opposite to corner0).
    /// - Returns: A set of ViewTypes signifying the transitions within the selection box.
    private func findSelectedTransitions(corner0: CGPoint, corner1: CGPoint) -> Set<ViewType> {
        let allStates = machine.states
        var focusedTransitions: [ViewType] = []
        allStates.indices.forEach { stateIndex in
            let trackers = self.cache.trackers(for: allStates[stateIndex])
            focusedTransitions.append(
                contentsOf: trackers.indices.filter { index in
                    let position = trackers[index].location
                    return isWithinBound(corner0: corner0, corner1: corner1, position: position)
                }.map {
                    ViewType.transition(stateIndex: stateIndex, transitionIndex: $0)
                }
            )
        }
        return Set(focusedTransitions)
    }
    
    private func finishMovingTransitions() {
        isStateMoving = false
    }
    
    private func isWithinBound(corner0: CGPoint, corner1: CGPoint, position: CGPoint) -> Bool {
        position.x >= min(corner0.x, corner1.x) &&
            position.x <= max(corner0.x, corner1.x) &&
            position.y >= min(corner0.y, corner1.y) &&
            position.y <= max(corner0.y, corner1.y)
    }
    
    private func moveElements(gesture: DragGesture.Value, frame: CGSize) {
        if isMoving {
            let stateNames = machine.states.map(\.name)
            stateNames.forEach {
                moveState(stateName: $0, gesture: gesture, frame: frame)
            }
            transitionStartLocations.keys.forEach { name in
                let trackers = self.cache.trackers(for: name)
                trackers.indices.forEach {
                    moveTransition(state: name, transitionIndex: $0, gesture: gesture)
                }
            }
            return
        }
        startMoving()
    }
    
    private func moveState(stateName: StateName, gesture: DragGesture.Value, frame: CGSize) {
        let newX = startLocations[stateName]!.x - gesture.translation.width
        let newY = startLocations[stateName]!.y - gesture.translation.height
        let _ = self.cache.updateTracker(for: stateName, newLocation: CGPoint(x: newX, y: newY))
        let _ = self.cache.updateTracker(for: stateName, isText: newX > frame.width || newY > frame.height || newX < 0.0 || newY < 0.0)
    }
    
    private func moveTransition(state name: StateName, transitionIndex: Int, gesture: DragGesture.Value) {
        let x0 = transitionStartLocations[name]![transitionIndex].point0.x - gesture.translation.width
        let y0 = transitionStartLocations[name]![transitionIndex].point0.y - gesture.translation.height
        let x1 = transitionStartLocations[name]![transitionIndex].point1.x - gesture.translation.width
        let y1 = transitionStartLocations[name]![transitionIndex].point1.y - gesture.translation.height
        let x2 = transitionStartLocations[name]![transitionIndex].point2.x - gesture.translation.width
        let y2 = transitionStartLocations[name]![transitionIndex].point2.y - gesture.translation.height
        let x3 = transitionStartLocations[name]![transitionIndex].point3.x - gesture.translation.width
        let y3 = transitionStartLocations[name]![transitionIndex].point3.y - gesture.translation.height
        let curve = Curve(
            point0: CGPoint(x: x0, y: y0),
            point1: CGPoint(x: x1, y: y1),
            point2: CGPoint(x: x2, y: y2),
            point3: CGPoint(x: x3, y: y3)
        )
        let _ = self.cache.updateTracker(for: transitionIndex, in: name, curve: curve)
    }
    
    private func moveTransitions(state: StateName, gesture: DragGesture.Value, frame: CGSize) {
        if !isStateMoving {
            isStateMoving = true
            let effected = findMovingTransitions(state: state)
            movingSourceTransitions = effected.0
            movingTargetTransitions = effected.1
            return
        }
        displaceTransitions(sourceTransitions: movingSourceTransitions, targetTransitions: movingTargetTransitions, dS: gesture.translation, frame: frame, source: movingState)
    }
    
    private func newStateViewModel(stateIndex: Int) -> StateViewModel {
        StateViewModel(
            machine: machineBinding,
            path: machine.path.states[stateIndex],
            state: machineBinding.states[stateIndex],
            notifier: self
        )
    }
    
    private func removeViewFocus(view: CanvasView, focus: Focus, selected: ViewType) {
        if view.focus == focus {
            view.focus = .machine
        }
        if view.selectedObjects.contains(selected) {
            view.selectedObjects.remove(selected)
        }
    }
    
    private func startMoving() {
        machine.states.map(\.name).forEach {
            startLocations[$0] = self.cache.tracker(for: $0).location
            transitionStartLocations[$0] = self.cache.trackers(for: $0).map(\.curve)
        }
        isMoving = true
    }
    
    private func stateIndexes(from views: Set<ViewType>) -> IndexSet {
        IndexSet(machine.states.indices.compactMap {
            if views.contains(.state(stateIndex: $0)) {
                return $0
            }
            return nil
        })
    }
    
    private func states(from views: Set<ViewType>) -> [Machines.State] {
        machine.states.indices.compactMap {
            if views.contains(.state(stateIndex: $0)) {
                return machine.states[$0]
            }
            return nil
        }
    }
    
    private func stretchTransitions(state: StateName) {
        let model = self.cache.tracker(for: state)
        if !isStateMoving {
            isStateMoving = true
            let effected = findMovingTransitions(state: state)
            movingSourceTransitions = effected.0
            movingTargetTransitions = effected.1
            originalDimensions = (model.width, model.height)
            return
        }
        movingSourceTransitions.indices.forEach {
            guard let movingStateObj = machine.states.first(where: { $0.name == movingState }) else {
                return
            }
            let x = movingSourceTransitions[$0].x
            let y = movingSourceTransitions[$0].y
            let relativeX = x - model.location.x
            let relativeY = y - model.location.y
            let dx = (model.width - originalDimensions.0) / 2.0
            let dy = (model.height - originalDimensions.1) / 2.0
            let newX = relativeX < 0 ? x - dx : x + dx
            let newY = relativeY < 0 ? y - dy : y + dy
            let point = CGPoint(x: newX, y: newY)
            let _ = self.cache.updateTracker(for: $0, in: movingStateObj, point0: point)
        }
        movingTargetTransitions.keys.forEach { source in
            guard let stateIndex = machine.states.firstIndex(where: { $0.name == source }) else {
                return
            }
            let candidates = movingTargetTransitions[source]!
            self.machine.states[stateIndex].transitions.indices.forEach {
                if !candidates.contains($0) {
                    return
                }
                let stateObj = self.machine.states[stateIndex]
                let tracker = self.cache.tracker(for: $0, originating: stateObj)
                let x = tracker.curve.point3.x
                let y = tracker.curve.point3.y
                let relativeX = x - model.location.x
                let relativeY = y - model.location.y
                let dx = (model.width - originalDimensions.0) / 2.0
                let dy = (model.height - originalDimensions.1) / 2.0
                let newX = relativeX < 0 ? x - dx : x + dx
                let newY = relativeY < 0 ? y - dy : y + dy
                let point = CGPoint(x: newX, y: newY)
                let _ = self.cache.updateTracker(for: $0, in: stateObj, point3: point)
            }
        }
    }
    
    private func transitionIndexes(from views: Set<ViewType>) -> [StateName: IndexSet] {
        var temp: [StateName: IndexSet] = [:]
        machine.states.indices.forEach { stateIndex in
            temp[machine.states[stateIndex].name] = IndexSet(machine.states[stateIndex].transitions.indices.compactMap { transitionIndex in
                if views.contains(.transition(stateIndex: stateIndex, transitionIndex: transitionIndex)) {
                    return transitionIndex
                }
                return nil
            })
        }
        return temp
    }
    
    private func updateTransitionsSources(source: Machines.State) {
        let sourceTracker = self.cache.tracker(for: source.name)
        source.transitions.indices.forEach {
            let existingViewModel = self.cache.tracker(for: $0, originating: source)
            let targetTracker = self.cache.tracker(for: source.transitions[$0].target)
            let _ = self.cache.updateTracker(
                for: $0,
                in: source,
                newTracker: TransitionTracker(
                    source: sourceTracker,
                    sourcePoint: existingViewModel.curve.point0,
                    target: targetTracker,
                    targetPoint: existingViewModel.curve.point3
                )
            )
        }
    }
    
    private func updateTransitionsTargets(source: Machines.State) {
        guard let _ = machine.states.firstIndex(where: { $0 == source }) else {
            return
        }
        let targets = findMovingTransitions(state: source.name).1
        targets.keys.forEach { name in
            guard let stateIndex = machine.states.firstIndex(where: { $0.name == name }) else {
                return
            }
            let state = machine.states[stateIndex]
            let candidates = targets[name]!
            machine.states[stateIndex].transitions.indices.forEach {
                if !candidates.contains($0) {
                    return
                }
                let existingTracker = self.cache.tracker(for: $0, originating: state.name)
                let targetName = state.transitions[$0].target
                let sourceTracker = self.cache.tracker(for: state.name)
                let targetTracker = self.cache.tracker(for: targetName)
                let _ = self.cache.updateTracker(
                    for: $0,
                    in: state.name,
                    newTracker: TransitionTracker(
                        source: sourceTracker,
                        sourcePoint: existingTracker.curve.point0,
                        target: targetTracker,
                        targetPoint: existingTracker.curve.point3
                    )
                )
            }
        }
    }
    
}

//PLIST EXTENSION
extension MachineViewModel {
    
    convenience init(machine: Binding<Machine>, plist data: String) {
        self.init()
        self.machineBinding = machine
        self.cache = ViewCache(machine: machine, plist: data, notifier: self)
    }
    
}
