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
    
    var isMoving: Bool = false
    
    var isStateMoving: Bool = false
    
    var machineBinding: Binding<Machine>
    
    var movingState: StateName = ""
    
    var startLocations: [StateName: CGPoint] = [:]
    
    var states: [StateName: StateViewModel]
    
    var stateTrackers: [StateName: StateTracker]
    
    var transitions: [StateName: [TransitionViewModel]]
    
    var transitionStartLocations: [StateName: [Curve]] = [:]
    
    var transitionTrackers: [StateName: [TransitionTracker]]
    
    var targetTransitions: [StateName: [TransitionViewModel]]
    
    var machine: Machine {
        machineBinding.wrappedValue
    }
    
    fileprivate init() {
        self.machineBinding = .constant(Machine.initialSwiftMachine())
        self.states = [:]
        self.stateTrackers = [:]
        self.transitions = [:]
        self.transitionTrackers = [:]
        self.targetTransitions = [:]
    }
    
    init(machine: Binding<Machine>) {
        self.machineBinding = machine
        var tempStates: [StateName: StateViewModel] = [:]
        var tempStateTrackers: [StateName: StateTracker] = [:]
        var tempTransitions: [StateName: [TransitionViewModel]] = [:]
        var tempTransitionTrackers: [StateName: [TransitionTracker]] = [:]
        var tempTargetTransitions: [StateName: [TransitionViewModel]] = [:]
        machine.wrappedValue.states.indices.forEach { stateIndex in
            let stateName = machine.wrappedValue.states[stateIndex].name
            tempStates[stateName] = StateViewModel(
                machine: machine,
                path: machine.wrappedValue.path.states[stateIndex],
                state: machine.states[stateIndex]
            )
            tempStateTrackers[stateName] = StateTracker()
        }
        machine.wrappedValue.states.indices.forEach { stateIndex in
            let stateName = machine.wrappedValue.states[stateIndex].name
            var tempTransitionArray: [TransitionViewModel] = []
            var tempTransitionTrackerArray: [TransitionTracker] = []
            machine.wrappedValue.states[stateIndex].transitions.indices.forEach { transitionIndex in
                let transition = machine.wrappedValue.states[stateIndex].transitions[transitionIndex]
                let transitionViewModel = TransitionViewModel(
                    machine: machine,
                    path: machine.wrappedValue.path.states[stateIndex].transitions[transitionIndex],
                    transitionBinding: machine.states[stateIndex].transitions[transitionIndex],
                    notifier: nil
                )
                guard
                    let sourceTracker = tempStateTrackers[stateName],
                    let targetTracker = tempStateTrackers[transition.target]
                else {
                    return
                }
                tempTransitionArray.append(transitionViewModel)
                tempTransitionTrackerArray.append(TransitionTracker(source: sourceTracker, target: targetTracker))
                guard let _ = tempTargetTransitions[transition.target] else {
                    tempTargetTransitions[transition.target] = [transitionViewModel]
                    return
                }
                tempTargetTransitions[transition.target]!.append(transitionViewModel)
            }
            tempTransitions[stateName] = tempTransitionArray
            tempTransitionTrackers[stateName] = tempTransitionTrackerArray
        }
        self.states = tempStates
        self.stateTrackers = tempStateTrackers
        self.transitions = tempTransitions
        self.transitionTrackers = tempTransitionTrackers
        self.targetTransitions = tempTargetTransitions
        self.states.values.forEach { s in
            s.notifier = self
        }
        self.transitions.values.forEach {
            $0.forEach { transition in
                transition.notifier = self
            }
        }
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
        let stateName = machine.states[newStateIndex].name
        states[stateName] = newStateViewModel(stateIndex: newStateIndex)
        stateTrackers[stateName] = StateTracker()
        transitions[stateName] = []
        transitionTrackers[stateName] = []
        targetTransitions[stateName] = []
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
                let result = self.machineBinding.wrappedValue.newTransition(source: self.machine.states[index].name, target: targetName)
                guard let _ = try? result.get() else {
                    return
                }
                let lastIndex = self.machine.states[index].transitions.count - 1
                guard lastIndex >= 0 else {
                    return
                }
                self.addTransition(source: stateName, at: lastIndex, sourcePoint: gesture.startLocation, target: gesture.location)
                self.transition(for: lastIndex, in: stateName).condition.wrappedValue = "true"
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
        clearDictionaries(with: stateNames)
        let stateNameSet = Set(stateNames)
        let transitionIndexes = transitionIndexes(from: view.selectedObjects)
        transitionIndexes.keys.forEach {
            if stateNameSet.contains($0) {
                return
            }
            let result = self.machineBinding.wrappedValue.delete(transitions: transitionIndexes[$0]!, attachedTo: $0)
            guard let _ = try? result.get() else {
                print(self.machine.errorBag.allErrors.description)
                return
            }
            clearTransitions(originating: $0, in: transitionIndexes[$0]!)
        }
        view.selectedObjects = []
        view.focus = .machine
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
        clearTransition(originating: stateName, at: transitionIndex)
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
            }.onEnded {
                self.finishMoveElements(gesture: $0, frame: size)
            }
    }
    
    func dragStateGesture(forView view: CanvasView, forState index: Int, size: CGSize) -> some Gesture {
        DragGesture(minimumDistance: 0, coordinateSpace: .named(view.coordinateSpace))
            .onChanged {
                self.handleDrag(state: self.machine.states[index], gesture: $0, frameWidth: size.width, frameHeight: size.height)
                if !self.tracker(for: self.machine.states[index].name).isStretchingX && !self.tracker(for: self.machine.states[index].name).isStretchingY {
                    self.moveTransitions(state: self.machine.states[index].name, gesture: $0, frame: size)
                } else {
                    self.stretchTransitions(state: self.machine.states[index].name, states: self.machine.states)
                }
                self.objectWillChange.send()
            }.onEnded {
                self.finishMovingTransitions()
                self.finishDrag(state: self.machine.states[index], gesture: $0, frameWidth: size.width, frameHeight: size.height)
                self.objectWillChange.send()
            }
    }
    
    func finishMoveElements(gesture: DragGesture.Value, frame: CGSize) {
        moveElements(gesture: gesture, frame: frame)
        isMoving = false
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
        let viewModel = tracker(for: transitionIndex, originating: state)
        transitionTrackers[state]![transitionIndex] = TransitionTracker(source: viewModel.curve.point0, target: viewModel.curve.point3)
    }
    
    /// Returns a tracker for the State specified.
    /// - Parameter stateName: The name fo the state.
    /// - Returns: The state tracker for the state.
    func tracker(for stateName: StateName) -> StateTracker {
        guard let tracker = stateTrackers[stateName] else {
            let newTracker = StateTracker()
            stateTrackers[stateName] = newTracker
            return newTracker
        }
        return tracker
    }
    
    func tracker(for transition: Int, originating from: StateName) -> TransitionTracker {
        guard
            let trackers = transitionTrackers[from],
            trackers.count > transition
        else {
            fatalError("No Tracker for Transition")
        }
        return trackers[transition]
    }
    
    func transition(for transition: Int, in state: StateName) -> TransitionViewModel {
        guard
            let ts = transitions[state],
            ts.count > transition
        else {
            fatalError("Failed to get transition view model")
        }
        return ts[transition]
    }
    
    func transitionTrackers(for stateName: StateName) -> [TransitionTracker] {
        let _ = viewModel(for: stateName)
        guard let trackers = transitionTrackers[stateName] else {
            transitions[stateName] = []
            transitionTrackers[stateName] = []
            return []
        }
        return trackers
    }
    
    func viewModel(for state: Machines.State) -> StateViewModel {
        if let viewModel = states[state.name] {
            return viewModel
        }
        guard let stateIndex = machine.states.firstIndex(where: { $0 == state }) else {
            fatalError("Trying to create view model for state that doesn't exist!")
        }
        let newViewModel = newStateViewModel(stateIndex: stateIndex)
        states[state.name] = newViewModel
        let _ = tracker(for: state.name)
        return newViewModel
    }
    
    func viewModel(for stateName: StateName) -> StateViewModel {
        guard let state = machine.states.first(where: { $0.name == stateName }) else {
            fatalError("Trying to create view model for state that doesn't exist!")
        }
        return viewModel(for: state)
    }
    
    private func addSelected(view: CanvasView, focus: Focus, selected: ViewType) {
        view.selectedObjects.insert(selected)
        if view.selectedObjects.count == 1 {
            view.focus = focus
            return
        }
        view.focus = .machine
    }
    
    private func addTarget(target name: StateName, transition: TransitionViewModel) {
        guard let _ = targetTransitions[name] else {
            targetTransitions[name] = [transition]
            return
        }
        targetTransitions[name]!.append(transition)
    }
    
    private func addTransition(source: StateName, at index: Int, sourcePoint: CGPoint, target: CGPoint) {
        guard let stateIndex = machine.states.firstIndex(where: { $0.name == source }) else {
            return
        }
        let transition = machine.states[stateIndex].transitions[index]
        let sourceTracker = tracker(for: source)
        let targetTracker = tracker(for: transition.target)
        let newViewModel = TransitionViewModel(
            machine: machineBinding,
            path: machine.path.states[stateIndex].transitions[index],
            transitionBinding: machineBinding.states[stateIndex].transitions[index],
            notifier: self
        )
        let newTracker = TransitionTracker(source: sourceTracker, sourcePoint: sourcePoint, target: targetTracker, targetPoint: target)
        guard let _ = transitions[source] else {
            transitions[source] = [newViewModel]
            transitionTrackers[source] = [newTracker]
            addTarget(target: transition.target, transition: newViewModel)
            return
        }
        transitions[source]!.append(newViewModel)
        transitionTrackers[source]!.append(newTracker)
        addTarget(target: transition.target, transition: newViewModel)
    }
    
    private func clearDictionaries(with names: [StateName]) {
        names.forEach {
            clearTargetTransitions(with: $0)
            states[$0] = nil
            stateTrackers[$0] = nil
            transitions[$0] = nil
            transitionTrackers[$0] = nil
        }
    }
    
    private func clearTargetTransitions(with source: StateName) {
        let tempTransitions = Set(transitions[source]!)
        targetTransitions.keys.forEach { target in
            targetTransitions[target]!.removeAll(where: { t in tempTransitions.contains(t) })
        }
    }
    
    private func clearTransition(originating from: StateName, at index: Int) {
        let tempTransition = transitions[from]![index]
        targetTransitions.keys.forEach {
            targetTransitions[$0]!.removeAll(where: { t in t == tempTransition })
        }
        transitions[from]?.remove(at: index)
        transitionTrackers[from]?.remove(at: index)
    }
    
    private func clearTransitions(originating from: StateName, in set: IndexSet) {
        let tempTransitions: Set<TransitionViewModel> = Set(transitions[from]!.indices.compactMap {
            if set.contains($0) {
                return transitions[from]![$0]
            }
            return nil
        })
        targetTransitions.keys.forEach {
            targetTransitions[$0]!.removeAll(where: { trans in
                tempTransitions.contains(trans)
            })
        }
        transitions[from]!.remove(atOffsets: set)
        transitionTrackers[from]!.remove(atOffsets: set)
    }
    
    private func findMovingTransitions(state: StateName) -> ([CGPoint], [StateName: [Int: CGPoint]]) {
        movingState = state
        let movingSources = transitionTrackers(for: state).map(\.curve.point0)
        var targetTransitions: [StateName: [Int: CGPoint]] = [:]
        machine.states.forEach { stateObj in
            let name = stateObj.name
            let stateTransitions = stateObj.transitions
            var targetsDictionary: [Int: CGPoint] = [:]
            stateTransitions.indices.forEach({ index in
                if stateTransitions[index].target == state {
                    targetsDictionary[index] = self.viewModel(for: index, originatingFrom: name, goingTo: state).curve.point3
                }
            })
            targetTransitions[name] = targetsDictionary

        }
        return (movingSources, targetTransitions)
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
        for key in stateTrackers.keys {
            if stateTrackers[key]!.isWithin(point: point) {
                return key
            }
        }
        return nil
    }
    
    
    /// Finds the states within the selection box.
    /// - Parameters:
    ///   - corner0: A corner of the selection box.
    ///   - corner1: The second corner of the selection box (opposite to corner0).
    /// - Returns: A set of ViewTypes signifying the states within the selection box.
    private func findSelectedStates(corner0: CGPoint, corner1: CGPoint) -> Set<ViewType> {
        let allStates = machine.states
        let focusedStates = allStates.indices.filter {
            let position = tracker(for: allStates[$0].name).location
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
            focusedTransitions.append(contentsOf: transitionTrackers(for: allStates[stateIndex].name).indices.filter { index in
                let position = transitionTrackers(for: allStates[stateIndex].name)[index].location
                return isWithinBound(corner0: corner0, corner1: corner1, position: position)
            }.map {
                ViewType.transition(stateIndex: stateIndex, transitionIndex: $0)
            })
        }
        return Set(focusedTransitions)
    }
    
    private func handleDrag(state: Machines.State, gesture: DragGesture.Value, frameWidth: CGFloat, frameHeight: CGFloat) {
        guard let _ = stateTrackers[state.name] else {
            return
        }
        stateTrackers[state.name]!.handleDrag(gesture: gesture, frameWidth: frameWidth, frameHeight: frameHeight)
    }
    
    private func isWithinBound(corner0: CGPoint, corner1: CGPoint, position: CGPoint) -> Bool {
        position.x >= min(corner0.x, corner1.x) &&
            position.x <= max(corner0.x, corner1.x) &&
            position.y >= min(corner0.y, corner1.y) &&
            position.y <= max(corner0.y, corner1.y)
    }
    
    private func moveElements(gesture: DragGesture.Value, frame: CGSize) {
        if isMoving {
            stateTrackers.keys.forEach {
                moveState(stateName: $0, gesture: gesture, frame: frame)
            }
            transitionStartLocations.keys.forEach { name in
                self.transitionTrackers(for: name).indices.forEach {
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
        let _ = tracker(for: stateName)
        stateTrackers[stateName]!.location = CGPoint(
            x: newX,
            y: newY
        )
        if newX > frame.width || newY > frame.height || newX < 0.0 || newY < 0.0 {
            stateTrackers[stateName]!.isText = true
        } else {
            stateTrackers[stateName]!.isText = false
        }
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
        var tracker = self.tracker(for: transitionIndex, originating: name)
        tracker.curve = curve
        transitionTrackers[name]![transitionIndex] = tracker
    }
    
    func moveTransitions(state: StateName, gesture: DragGesture.Value, frame: CGSize) {
        if !isStateMoving {
            isStateMoving = true
            let effected = findMovingTransitions(state: state, states: machine.states)
            movingSourceTransitions = effected.0
            movingTargetTransitions = effected.1
            return
        }
        displaceTransitions(sourceTransitions: movingSourceTransitions, targetTransitions: movingTargetTransitions, dS: gesture.translation, frame: frame, source: movingState)
//        movingSourceTransitions.indices.forEach {
//            let newX = min(max(0, movingSourceTransitions[$0].x + gesture.translation.width), frameWidth)
//            let newY = min(max(0, movingSourceTransitions[$0].y + gesture.translation.height), frameHeight)
//            let point = CGPoint(x: newX, y: newY)
//            transitions[movingState]![$0].curve.point0 = point
//        }
//        movingTargetTransitions.keys.forEach { name in
//            movingTargetTransitions[name]!.keys.forEach { index in
//                let newX = min(max(0, movingTargetTransitions[name]![index]!.x + gesture.translation.width), frameWidth)
//                let newY = min(max(0, movingTargetTransitions[name]![index]!.y + gesture.translation.height), frameHeight)
//                let point = CGPoint(x: newX, y: newY)
//                transitions[name]![index].curve.point3 = point
//            }
//        }
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
        states.keys.forEach {
            startLocations[$0] = self.tracker(for: $0).location
            transitionStartLocations[$0] = self.transitionTrackers(for: $0).map(\.curve)
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
    
}

//PLIST EXTENSION
extension MachineViewModel {
    
    convenience init(machine: Binding<Machine>, plist data: String) {
        var tempStates: [StateName: StateViewModel] = [:]
        var tempStateTrackers: [StateName: StateTracker] = [:]
        var tempTransitions: [StateName: [TransitionViewModel]] = [:]
        var tempTransitionTrackers: [StateName: [TransitionTracker]] = [:]
        var tempTargetTransitions: [StateName: [TransitionViewModel]] = [:]
        // Create models from plist
        machine.wrappedValue.states.indices.forEach { (stateIndex: Int) in
            let stateName = machine.wrappedValue.states[stateIndex].name
            let statePlist: String = data.components(separatedBy: "<key>\(stateName)</key>")[1]
                .components(separatedBy: "<key>zoomedOnExitHeight</key>")[0]
            let transitionsPlist: String = statePlist.components(separatedBy: "<key>Transitions</key>")[1].components(separatedBy: "<key>bgColour</key>")[0]
            let transitionTrackers = machine.wrappedValue.states[stateIndex].transitions.indices.map { (priority: Int) -> TransitionTracker in
                let transitionPlist = transitionsPlist.components(separatedBy: "</dict>")[priority]
                    .components(separatedBy: "<dict>")[1]
                return TransitionTracker(plist: transitionPlist)
            }
            let transitionViewModels = machine.wrappedValue.states[stateIndex].transitions.indices.map { (priority: Int) -> TransitionViewModel in
                let transition = machine.wrappedValue.states[stateIndex].transitions[priority]
                let viewModel = TransitionViewModel(
                    machine: machine,
                    path: machine.wrappedValue.path.states[stateIndex].transitions[priority],
                    transitionBinding: machine.states[stateIndex].transitions[priority]
                )
                guard let _ = tempTargetTransitions[transition.target] else {
                    tempTargetTransitions[transition.target] = [viewModel]
                    return viewModel
                }
                tempTargetTransitions[transition.target]!.append(viewModel)
                return viewModel
            }
            tempTransitions[stateName] = transitionViewModels
            tempTransitionTrackers[stateName] = transitionTrackers
            tempStateTrackers[stateName] = StateTracker(plist: statePlist)
            tempStates[stateName] = StateViewModel(
                machine: machine,
                path: machine.wrappedValue.path.states[stateIndex],
                state: machine.states[stateIndex]
            )
        }
        // Correct for invalid plist transition snap points
        tempTransitions.keys.forEach { state in
            guard let trackers = tempTransitionTrackers[state] else {
                return
            }
            trackers.indices.forEach { trackerIndex in
                guard let stateIndex = machine.wrappedValue.states.firstIndex(where: { $0.name == state }) else {
                    return
                }
                let stateObj = machine.wrappedValue.states[stateIndex]
                guard stateObj.transitions.count > trackerIndex else {
                    return
                }
                let transition = stateObj.transitions[trackerIndex]
                guard
                    let tracker = tempTransitionTrackers[state]?[trackerIndex],
                    tempStates[state] != nil,
                    tempStates[transition.target] != nil,
                    let sourceTracker = tempStateTrackers[state],
                    let targetTracker = tempStateTrackers[transition.target]
                else {
                    return
                }
                guard
                    !tempStateTrackers[transition.target]!.isWithin(point: tracker.curve.point3),
                    tempStateTrackers[transition.target]!.onEdge(point: tracker.curve.point3)
                else {
                    tempTransitionTrackers[state]![trackerIndex] = TransitionTracker(
                        source: sourceTracker,
                        target: targetTracker
                    )
                    return
                }
                
            }
        }
        self.init()
        self.machineBinding = machine
        self.states = tempStates
        self.stateTrackers = tempStateTrackers
        self.transitions = tempTransitions
        self.transitionTrackers = tempTransitionTrackers
        self.targetTransitions = tempTargetTransitions
        self.states.values.forEach { s in
            s.notifier = self
        }
        self.transitions.values.forEach {
            $0.forEach { t in
                t.notifier = self
            }
        }
    }
    
}
