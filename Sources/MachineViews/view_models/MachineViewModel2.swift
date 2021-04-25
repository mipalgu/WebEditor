//
//  File.swift
//  
//
//  Created by Morgan McColl on 24/4/21.
//

import Foundation

#if canImport(TokamakShim)
import TokamakShim
#else
import SwiftUI
#endif

import Machines
import GUUI
import Utilities

final class MachineViewModel2: ObservableObject {
    
    @Published var data: [StateName: StateViewModel2]
    
    @Published var transitions: [StateName: [TransitionViewModel2]]
//
//    @Published var transitionOrder: [StateName: [UUID]]
    
    var isMoving: Bool = false
    
    var startLocations: [StateName: CGPoint] = [:]
    
    var transitionStartLocations: [StateName: [Curve]] = [:]
    
    var isStateMoving: Bool = false
    
    var movingState: StateName = ""
    
    var movingSourceTransitions: [CGPoint] = []
    
    var movingTargetTransitions: [StateName: [Int: CGPoint]] = [:]
    
    var originalDimensions: (CGFloat, CGFloat) = (0.0, 0.0)
    
    private var cache: IDCache<Machines.State> = IDCache()
    
    private var transitionCache: IDCache<Transition> = IDCache()
    
    init(data: [StateName: StateViewModel2] = [:], transitions: [StateName: [TransitionViewModel2]] = [:]) {
        self.data = data
        self.transitions = transitions
    }
    
    init(states: [Machines.State]) {
        var data: [StateName: StateViewModel2] = [:]
        var transitions: [StateName: [TransitionViewModel2]] = [:]
        transitions.reserveCapacity(states.count)
        var x: CGFloat = 100.0;
        var y: CGFloat = 100.0;
        states.indices.forEach {
            let newViewModel = StateViewModel2(location: CGPoint(x: x, y: y), expandedWidth: 100.0, expandedHeight: 100.0, expanded: true, collapsedWidth: 150.0, collapsedHeight: 100.0, isText: false)
            if y > 800 {
                x = 0
                y = 0
            } else if x > 800 {
                x = 0
                y += 100.0
            } else {
                x += 100.0
            }
            data[states[$0].name] = newViewModel
        }
        states.indices.forEach { stateIndex in
            var transitionViewModels: [TransitionViewModel2] = []
            let stateTransitions = states[stateIndex].transitions
            stateTransitions.indices.forEach { index in
                transitionViewModels.append(
                    TransitionViewModel2(
                        source: data[states[stateIndex].name]!,
                        target: data[states[stateIndex].transitions[index].target]!
                    )
                )
            }
            transitions[states[stateIndex].name] = transitionViewModels
        }
        self.data = data
        self.transitions = transitions
    }
    
    public convenience init(machine: Machine, plist data: String) {
        var trans: [StateName: [TransitionViewModel2]] = [:]
        var stateViewModels: [StateName: StateViewModel2] = [:]
        machine.states.indices.forEach { (stateIndex: Int) in
            let stateName = machine.states[stateIndex].name
            let statePlist: String = data.components(separatedBy: "<key>\(stateName)</key>")[1]
                .components(separatedBy: "<key>zoomedOnExitHeight</key>")[0]
            let transitionsPlist: String = statePlist.components(separatedBy: "<key>Transitions</key>")[1].components(separatedBy: "<key>bgColour</key>")[0]
            let transitionViewModels = machine.states[stateIndex].transitions.indices.map { (priority: Int) -> TransitionViewModel2 in
                let transitionPlist = transitionsPlist.components(separatedBy: "</dict>")[priority]
                    .components(separatedBy: "<dict>")[1]
                return TransitionViewModel2(plist: transitionPlist)
            }
            trans[stateName] = transitionViewModels
            stateViewModels[stateName] = StateViewModel2(plist: statePlist)
        }
//        stateViewModels.forEach { stateVM in
//            let externalTransitions: [TransitionViewModel2] = stateViewModels.flatMap {
//                $0.transitionViewModels.filter { $0.transition.target == stateVM.name }
//            }
//            externalTransitions.forEach {
//                $0.curve.point3 = stateVM.findEdge(point: $0.point3)
//            }
//            stateVM.transitionViewModels.forEach {
//                $0.point0 = stateVM.findEdge(point: $0.point0)
//            }
//        }
        var rectifiedTransitions: [StateName: [TransitionViewModel2]] = [:]
        trans.keys.forEach { state in
            let viewModels = trans[state]!
            rectifiedTransitions[state] = viewModels.map { transition in
                guard
                    stateViewModels[state] != nil,
                    let target = stateViewModels.values.first(where: {
                        $0.isWithin(point: transition.curve.point3, padding: 20.0)
                    })
                else {
                    return transition
                }
                return TransitionViewModel2(
                    source: stateViewModels[state]!,
                    sourcePoint: transition.curve.point0,
                    target: target,
                    targetPoint: transition.curve.point3
                )
            }
        }
        self.init(data: stateViewModels, transitions: rectifiedTransitions)
    }
    
    public func toPlist(machine: Machine) -> String {
        let helper = StringHelper()
        let statesPlist = helper.reduceLines(data: data.map { (name, state) in
            guard
                let state = machine.states.first(where: { $0.name == name }),
                let stateViewModel = data[name],
                let transitionViewModels = transitions[name]
            else {
                return ""
            }
            return stateViewModel.toPList(transitionViewModels: transitionViewModels, state: state)
        })
        return "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n" +
        "<!DOCTYPE plist PUBLIC \"-//Apple//DTD PLIST 1.0//EN\" \"http://www.apple.com/DTDs/PropertyList-1.0.dtd\">\n" +
            "<plist version=\"1.0\">\n<dict>\n" + helper.tab(
                data: "<key>States</key>\n<dict>\n" + helper.tab(data: statesPlist) + "\n</dict>\n<key>Version</key>\n<string>1.3</string>"
            ) +
        "\n</dict>\n</plist>"
    }
    
    func viewModel(for state: Machines.State) -> StateViewModel2 {
        return viewModel(for: state.name)
    }
    
    func viewModel(for stateName: StateName) -> StateViewModel2 {
        guard let viewModel = data[stateName] else {
            let newViewModel = StateViewModel2()
            data[stateName] = newViewModel
            return newViewModel
        }
        return viewModel
    }
    
    func transitionViewModels(for state: StateName) -> [TransitionViewModel2] {
        guard let models = transitions[state] else {
            transitions[state] = []
            return []
        }
        return models
    }
    
    private func setupNewTransition(for transition: Int, originatingFrom stateName: StateName, goingTo targetState: StateName) -> TransitionViewModel2 {
        let source = viewModel(for: stateName)
        let target = viewModel(for: targetState)
        return TransitionViewModel2(source: source, target: target)
    }
    
    func viewModel(for transition: Int, originatingFrom state: Machines.State) -> TransitionViewModel2 {
        return viewModel(for: transition, originatingFrom: state.name, goingTo: state.transitions[transition].target)
    }
    
    func viewModel(for transition: Int, originatingFrom stateName: StateName, goingTo targetState: StateName) -> TransitionViewModel2 {
        guard let viewModels = transitions[stateName] else {
            let newViewModel = setupNewTransition(for: transition, originatingFrom: stateName, goingTo: targetState)
            transitions[stateName] = [newViewModel]
            return newViewModel
        }
        guard transition < viewModels.count && transition >= 0 else {
            let newViewModel = setupNewTransition(for: transition, originatingFrom: stateName, goingTo: targetState)
            transitions[stateName]!.append(newViewModel)
            return newViewModel
        }
        let transitionViewModel = viewModels[transition]
        return transitionViewModel
    }
    
    private func mutate(_ state: Machines.State, perform: (inout StateViewModel2) -> Void) {
        var viewModel = self.viewModel(for: state)
        perform(&viewModel)
        data[state.name] = viewModel
    }
    
    func binding(to state: Machines.State) -> Binding<StateViewModel2> {
        return Binding(
            get: {
                return self.viewModel(for: state)
            },
            set: {
                self.data[state.name] = $0
            }
        )
    }
    
    func binding(to transition: Int, originatingFrom state: Machines.State) -> Binding<TransitionViewModel2> {
        return Binding(
            get: {
                return self.viewModel(for: transition, originatingFrom: state)
            },
            set: {
                self.transitions[state.name]?[transition] = $0
            }
        )
    }
    
    func handleDrag(state: Machines.State, gesture: DragGesture.Value, frameWidth: CGFloat, frameHeight: CGFloat) {
        mutate(state) { $0.handleDrag(gesture: gesture, frameWidth: frameWidth, frameHeight: frameHeight) }
    }
    
    func finishDrag(state: Machines.State, gesture: DragGesture.Value, frameWidth: CGFloat, frameHeight: CGFloat) {
        mutate(state) { $0.finishDrag(gesture: gesture, frameWidth: frameWidth, frameHeight: frameHeight) }
    }
    
    public func moveElements(gesture: DragGesture.Value, frameWidth: CGFloat, frameHeight: CGFloat) {
        if isMoving {
            data.keys.forEach {
                let newX = startLocations[$0]!.x - gesture.translation.width
                let newY = startLocations[$0]!.y - gesture.translation.height
                data[$0]?.location = CGPoint(
                    x: newX,
                    y: newY
                )
                if newX > frameWidth || newY > frameHeight || newX < 0.0 || newY < 0.0 {
                    data[$0]?.isText = true
                } else {
                    data[$0]?.isText = false
                }
            }
            transitionStartLocations.keys.forEach { name in
                transitions[name]!.indices.forEach {
                    let x0 = transitionStartLocations[name]![$0].point0.x - gesture.translation.width
                    let y0 = transitionStartLocations[name]![$0].point0.y - gesture.translation.height
                    let x1 = transitionStartLocations[name]![$0].point1.x - gesture.translation.width
                    let y1 = transitionStartLocations[name]![$0].point1.y - gesture.translation.height
                    let x2 = transitionStartLocations[name]![$0].point2.x - gesture.translation.width
                    let y2 = transitionStartLocations[name]![$0].point2.y - gesture.translation.height
                    let x3 = transitionStartLocations[name]![$0].point3.x - gesture.translation.width
                    let y3 = transitionStartLocations[name]![$0].point3.y - gesture.translation.height
                    let curve = Curve(
                        point0: CGPoint(x: x0, y: y0),
                        point1: CGPoint(x: x1, y: y1),
                        point2: CGPoint(x: x2, y: y2),
                        point3: CGPoint(x: x3, y: y3)
                    )
                    transitions[name]![$0].curve = curve
                }
            }
            return
        }
        data.forEach {
            startLocations[$0.0] = $0.1.location
        }
        transitions.forEach {
            transitionStartLocations[$0.0] = $0.1.map {
                $0.curve
            }
        }
        isMoving = true
    }
    
    public func finishMoveElements(gesture: DragGesture.Value, frameWidth: CGFloat, frameHeight: CGFloat) {
        moveElements(gesture: gesture, frameWidth: frameWidth, frameHeight: frameHeight)
        isMoving = false
    }
    
    public func clampPosition(point: CGPoint, frameWidth: CGFloat, frameHeight: CGFloat, dx: CGFloat = 0.0, dy: CGFloat = 0.0) -> CGPoint {
        var newX: CGFloat = point.x
        var newY: CGFloat = point.y
        if point.x < dx {
            newX = dx
        } else if point.x > frameWidth - dx {
            newX = frameWidth - dx
        }
        if point.y < dy {
            newY = dy
        } else if point.y > frameHeight - dy {
            newY = frameHeight - dy
        }
        return CGPoint(x: newX, y: newY)
    }
    
    func assignExpanded(for state: Machines.State, newValue: Bool, frameWidth: CGFloat, frameHeight: CGFloat) {
        if newValue == viewModel(for: state).expanded {
            return
        }
        mutate(state) { $0.toggleExpand(frameWidth: frameWidth, frameHeight: frameHeight) }
    }
    
    private func isWithinBounds(testPoint: CGPoint, center: CGPoint, width: CGFloat, height: CGFloat) -> Bool {
        testPoint.x >= center.x - width / 2.0 && testPoint.x <= center.x + width / 2.0
            && testPoint.y <= center.y + height / 2.0
            && testPoint.y >= center.y - height / 2.0
    }
    
    private func findStateFromPoint(point: CGPoint) -> (StateName, StateViewModel2)? {
        for d in data {
            if d.1.isWithin(point: point) {
                return d
            }
        }
        return nil
    }
    
    func createNewTransition(sourceState: StateName, source: CGPoint, target: CGPoint) -> StateName? {
        guard let (targetName, targetState) = findStateFromPoint(point: target) else {
            return nil
        }
        let sourceModel = viewModel(for: sourceState)
        guard let _ = transitions[sourceState] else {
            transitions[sourceState] = [TransitionViewModel2(source: sourceModel, sourcePoint: source, target: targetState, targetPoint: target)]
            return targetName
        }
        transitions[sourceState]!.append(TransitionViewModel2(source: sourceModel, sourcePoint: source, target: targetState, targetPoint: target))
        return targetName
    }
    
    private func findMovingTransitions(state: StateName, states: [Machines.State]) -> ([CGPoint], [StateName: [Int: CGPoint]]) {
        movingState = state
        let movingSources = transitionViewModels(for: state).map { $0.curve.point0 }
        var targetTransitions: [StateName: [Int: CGPoint]] = [:]
        states.forEach { stateObj in
            let name = stateObj.name
            let stateTransitions = stateObj.transitions
            var targetsDictionary: [Int: CGPoint] = [:]
            stateTransitions.indices.forEach({ index in
                if stateTransitions[index].target == state {
                    targetsDictionary[index] = transitions[name]![index].curve.point3
                }
            })
            targetTransitions[name] = targetsDictionary
            
        }
        return (movingSources, targetTransitions)
    }
    
    private func displaceTransitions(sourceTransitions: [CGPoint], targetTransitions: [StateName: [Int: CGPoint]], dS: CGSize, frame: CGSize, source: StateName) {
        guard let _ = transitions[source] else {
            return
        }
        sourceTransitions.indices.forEach {
            let newX = min(max(0, sourceTransitions[$0].x + dS.width), frame.width)
            let newY = min(max(0, sourceTransitions[$0].y + dS.height), frame.height)
            let point = CGPoint(x: newX, y: newY)
            transitions[source]![$0].curve.point0 = point
        }
        targetTransitions.keys.forEach { name in
            targetTransitions[name]!.keys.forEach { index in
                let newX = min(max(0, targetTransitions[name]![index]!.x + dS.width), frame.width)
                let newY = min(max(0, targetTransitions[name]![index]!.y + dS.height), frame.height)
                let point = CGPoint(x: newX, y: newY)
                transitions[name]![index].curve.point3 = point
            }
        }
    }
    
    func moveTransitions(state: StateName, gesture: DragGesture.Value, states: [Machines.State], frame: CGSize) {
        if !isStateMoving {
            isStateMoving = true
            let effected = findMovingTransitions(state: state, states: states)
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
    
    func stretchTransitions(state: StateName, states: [Machines.State]) {
        let model = viewModel(for: state)
        if !isStateMoving {
            isStateMoving = true
            let effected = findMovingTransitions(state: state, states: states)
            movingSourceTransitions = effected.0
            movingTargetTransitions = effected.1
            originalDimensions = (model.width, model.height)
            return
        }
        movingSourceTransitions.indices.forEach {
            let x = movingSourceTransitions[$0].x
            let y = movingSourceTransitions[$0].y
            let relativeX = x - model.location.x
            let relativeY = y - model.location.y
            let dx = (model.width - originalDimensions.0) / 2.0
            let dy = (model.height - originalDimensions.1) / 2.0
            let newX = relativeX < 0 ? x - dx : x + dx
            let newY = relativeY < 0 ? y - dy : y + dy
            let point = CGPoint(x: newX, y: newY)
            transitions[movingState]![$0].curve.point0 = point
        }
        movingTargetTransitions.keys.forEach { name in
            movingTargetTransitions[name]!.keys.forEach { index in
                let x = movingTargetTransitions[name]![index]!.x
                let y = movingTargetTransitions[name]![index]!.y
                let relativeX = x - model.location.x
                let relativeY = y - model.location.y
                let dx = (model.width - originalDimensions.0) / 2.0
                let dy = (model.height - originalDimensions.1) / 2.0
                let newX = relativeX < 0 ? x - dx : x + dx
                let newY = relativeY < 0 ? y - dy : y + dy
                let point = CGPoint(x: newX, y: newY)
                transitions[name]![index].curve.point3 = point
            }
        }
    }
    
    func finishMovingTransitions() {
        isStateMoving = false
    }
    
    private func isWithinBound(corner0: CGPoint, corner1: CGPoint, position: CGPoint) -> Bool {
        position.x >= min(corner0.x, corner1.x) &&
            position.x <= max(corner0.x, corner1.x) &&
            position.y >= min(corner0.y, corner1.y) &&
            position.y <= max(corner0.y, corner1.y)
    }
    
    func findObjectsInSelection(corner0: CGPoint, corner1: CGPoint, states: [Machines.State]) -> Set<ViewType> {
        let focusedStates = states.indices.filter {
            let position = viewModel(for: states[$0]).location
            return isWithinBound(corner0: corner0, corner1: corner1, position: position)
        }.map { ViewType.state(stateIndex: $0) }
        var focusedTransitions: [ViewType] = []
        states.indices.forEach { stateIndex in
            focusedTransitions.append(contentsOf: transitionViewModels(for: states[stateIndex].name).indices.filter { index in
                let position = transitionViewModels(for: states[stateIndex].name)[index].location
                return isWithinBound(corner0: corner0, corner1: corner1, position: position)
            }.map {
                ViewType.transition(stateIndex: stateIndex, transitionIndex: $0)
            })
        }
        return Set(focusedStates + focusedTransitions)
    }
    
    func createTransitionGesture(forView view: CanvasView, forState index: Int) -> some Gesture {
        DragGesture(minimumDistance: 0, coordinateSpace: .named(view.coordinateSpace))
            .modifiers(.command)
            .onChanged {
                view.creatingCurve = Curve(source: $0.startLocation, target: $0.location)
            }
            .modifiers(.command)
            .onEnded {
                view.creatingCurve = nil
                guard let targetName = self.createNewTransition(sourceState: view.machine.states[index].name, source: $0.startLocation, target: $0.location) else {
                    return
                }
                guard let _ = try? view.machine.newTransition(source: view.machine.states[index].name, target: targetName) else {
                    return
                }
                let lastIndex = view.machine.states[index].transitions.count - 1
                guard lastIndex >= 0 else {
                    return
                }
                try? view.machine.modify(attribute: Machine.path.states[index].transitions[lastIndex].condition, value: "true")
            }
    }
    
    func dragStateGesture(forView view: CanvasView, forState index: Int, size: CGSize) -> some Gesture {
        DragGesture(minimumDistance: 0, coordinateSpace: .named(view.coordinateSpace))
            .onChanged {
                self.handleDrag(state: view.machine.states[index], gesture: $0, frameWidth: size.width, frameHeight: size.height)
                if !self.viewModel(for: view.machine.states[index].name).isStretchingX && !self.viewModel(for: view.machine.states[index].name).isStretchingY {
                    self.moveTransitions(state: view.machine.states[index].name, gesture: $0, states: view.machine.states, frame: size)
                } else {
                    self.stretchTransitions(state: view.machine.states[index].name, states: view.machine.states)
                }
            }.onEnded {
                self.finishMovingTransitions()
                self.finishDrag(state: view.machine.states[index], gesture: $0, frameWidth: size.width, frameHeight: size.height)
            }
    }
    
    func selectionBoxGesture(forView view: CanvasView) -> some Gesture {
        DragGesture(minimumDistance: 0, coordinateSpace: .named(view.coordinateSpace))
            .modifiers(.control)
            .onChanged {
                view.selectedBox = ($0.startLocation, $0.location)
            }
            .modifiers(.control)
            .onEnded {
                view.selectedObjects = self.findObjectsInSelection(corner0: $0.startLocation, corner1: $0.location, states: view.machine.states)
                view.selectedBox = nil
            }
    }
    
    func dragCanvasGesture(coordinateSpace: String, size: CGSize) -> some Gesture {
        DragGesture(minimumDistance: 0, coordinateSpace: .named(coordinateSpace))
            .onChanged {
                self.moveElements(gesture: $0, frameWidth: size.width, frameHeight: size.height)
            }.onEnded {
                self.finishMoveElements(gesture: $0, frameWidth: size.width, frameHeight: size.height)
            }
    }
    
    func updateTransitionsSources(source: Machines.State) {
        let sourceViewModel = self.viewModel(for: source)
        guard
            let ts = transitions[source.name],
            ts.count == source.transitions.count
        else {
            return
        }
        let newViewModels = source.transitions.indices.map {
            TransitionViewModel2(
                source: sourceViewModel,
                sourcePoint: transitions[source.name]![$0].curve.point0,
                target: viewModel(for: source.transitions[$0].target),
                targetPoint: transitions[source.name]![$0].curve.point3
            )
        }
        transitions[source.name] = newViewModels
    }
    
    func updateTransitionsTargets(source: Machines.State, states: [Machines.State]) {
        let targets = findMovingTransitions(state: source.name, states: states).1
        targets.keys.forEach { name in
            targets[name]!.forEach { (index, _) in
                transitions[name]![index] = TransitionViewModel2(
                    source: viewModel(for: name),
                    sourcePoint: transitions[name]![index].curve.point0,
                    target: viewModel(for: source.name),
                    targetPoint: transitions[name]![index].curve.point3
                )
            }
        }
    }
    
    func updateTransitionLocations(source: Machines.State, states: [Machines.State]) {
        updateTransitionsSources(source: source)
        updateTransitionsTargets(source: source, states: states)
    }
    
    func deleteState(view: CanvasView, at index: Int) {
        let name = view.machine.states[index].name
        guard let _ = try? view.$machine.wrappedValue.deleteState(atIndex: index) else {
            print(view.machine.errorBag.errors(includingDescendantsForPath: view.machine.path.states[index]))
            return
        }
        data[name] = nil
        transitions[name] = []
        view.focus = .machine
    }
    
    func states(_ machine: Machine) -> [Row<Machines.State>] {
        machine.states.enumerated().map {
            Row(id: cache.id(for: $1), index: $0, data: $1)
        }
    }
    
    func transitions(_ row: Row<Machines.State>) -> [Row<Transition>] {
        row.data.transitions.enumerated().map {
            Row(id: transitionCache.id(for: $1), index: $0, data: $1)
        }
    }
    
    func straighten(state: StateName, transition: Int) {
        guard
            let ts = transitions[state],
            ts.count > transition
        else {
            return
        }
        let viewModel = ts[transition]
        transitions[state]![transition] = TransitionViewModel2(source: viewModel.curve.point0, target: viewModel.curve.point3)
    }
    
}
