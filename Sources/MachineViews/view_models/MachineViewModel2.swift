//
//  File.swift
//  
//
//  Created by Morgan McColl on 24/4/21.
//

import Foundation

import TokamakShim

import Machines
import GUUI
import Utilities

struct CacheContainer<T: Hashable>: Hashable {
    
    var index: Int
    
    var value: T
    
}

final class MachineViewModel2: ObservableObject, GlobalChangeNotifier {
    
    func send() {
        self.objectWillChange.send()
    }
    
    var machineBinding: Binding<Machine>
    
    var machine: Machine {
        machineBinding.wrappedValue
    }
    
    var data: [StateName: StateViewModel2]
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
    
    private var transitionCache: IDCache<CacheContainer<Transition>> = IDCache()
    
    private var transitionViewModelCache: IDCache<TransitionViewModel2> = IDCache()
    
//    var unattachedTransitionsAsRows: [Row<TransitionViewModel2>] {
//        unattachedTransitions.enumerated().map {
//            Row(id: transitionViewModelCache.id(for: $1), index: $0, data: $1)
//        }
//    }
    
    init(machine: Binding<Machine>, data: [StateName: StateViewModel2]) {
        self.machineBinding = machine
        self.data = data
    }
    
//    init(machine: Binding<Machine>) {
//        self.machineBinding = machine
//        let states = machine.wrappedValue.states
//        var data: [StateName: StateViewModel2] = [:]
//        var transitions: [StateName: [TransitionViewModel2]] = [:]
//        transitions.reserveCapacity(states.count)
//        var x: CGFloat = 100.0;
//        var y: CGFloat = 100.0;
//        var x2: CGFloat = 100.0;
//        var y2: CGFloat = 100.0;
//        states.indices.forEach {
//            if y > 800 {
//                x2 = 0
//                y2 = 0
//            } else if x > 800 {
//                x2 = 0
//                y2 += 100.0
//            } else {
//                x2 += 100.0
//            }
//            let newViewModel = StateViewModel2(
//                location: CGPoint(x: x, y: y),
//                expandedWidth: 100.0,
//                expandedHeight: 100.0,
//                expanded: true,
//                collapsedWidth: 150.0,
//                collapsedHeight: 100.0,
//                isText: false,
//                stateBinding: machineBinding.states[$0],
//                transitions: machine.wrappedValue.states[$0].transitions.map {
//                    TransitionViewModel2(source: CGPoint(x: x, y: y), target: CGPoint(x: x2, y: y2))
//                }
//            )
//            data[states[$0].name] = newViewModel
//        }
//        states.indices.forEach { stateIndex in
//            var transitionViewModels: [TransitionViewModel2] = []
//            let stateTransitions = states[stateIndex].transitions
//            stateTransitions.indices.forEach { index in
//                transitionViewModels.append(
//                    TransitionViewModel2(
//                        source: data[states[stateIndex].name]!,
//                        target: data[states[stateIndex].transitions[index].target]!
//                    )
//                )
//            }
//            transitions[states[stateIndex].name] = transitionViewModels
//        }
//        self.data = data
//        self.transitions = transitions
//    }
    
    public convenience init(machine: Binding<Machine>, plist data: String) {
        var trans: [StateName: [TransitionViewModel2]] = [:]
        var stateViewModels: [StateName: StateViewModel2] = [:]
        machine.wrappedValue.states.indices.forEach { (stateIndex: Int) in
            let stateName = machine.wrappedValue.states[stateIndex].name
            let statePlist: String = data.components(separatedBy: "<key>\(stateName)</key>")[1]
                .components(separatedBy: "<key>zoomedOnExitHeight</key>")[0]
            let transitionsPlist: String = statePlist.components(separatedBy: "<key>Transitions</key>")[1].components(separatedBy: "<key>bgColour</key>")[0]
            let transitionViewModels = machine.wrappedValue.states[stateIndex].transitions.indices.map { (priority: Int) -> TransitionViewModel2 in
                let transitionPlist = transitionsPlist.components(separatedBy: "</dict>")[priority]
                    .components(separatedBy: "<dict>")[1]
                return TransitionViewModel2(machine: machine, path: machine.wrappedValue.path.states[stateIndex].transitions[priority], transitionBinding: machine.states[stateIndex].transitions[priority], plist: transitionPlist)
            }
            trans[stateName] = transitionViewModels
            stateViewModels[stateName] = StateViewModel2(machine: machine, path: machine.wrappedValue.path.states[stateIndex], state: machine.states[stateIndex], plist: statePlist)
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
        trans.keys.forEach { state in
            let viewModels = trans[state]!
            let rectifiedTransitions: [TransitionViewModel2] = viewModels.map { transition in
                guard
                    stateViewModels[state] != nil,
                    let target = stateViewModels.values.first(where: {
                        $0.tracker.isWithin(point: transition.curve.point3, padding: 20.0)
                    })
                else {
                    return transition
                }
                return TransitionViewModel2(
                    machine: machine,
                    path: transition.path,
                    transitionBinding: transition.transitionBinding,
                    source: stateViewModels[state]!,
                    sourcePoint: transition.curve.point0,
                    target: target,
                    targetPoint: transition.curve.point3
                )
            }
            stateViewModels[state]!.transitions = rectifiedTransitions
        }
        self.init(machine: machine, data: stateViewModels)
        self.data.values.forEach { s in
            s.notifier = self
            s.transitions.forEach { t in
                t.notifier = self
            }
        }
    }
    
    public func toPlist(machine: Machine) -> String {
        let helper = StringHelper()
        let statesPlist = helper.reduceLines(data: data.sorted(by: { $0.key < $1.key }).map { (name, state) in
            guard let stateViewModel = data[name] else {
                return ""
            }
            return stateViewModel.plist
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
            guard let stateIndex = machine.states.firstIndex(where: { $0.name == stateName }) else {
                fatalError("Trying to construct view model for state that doesn't exist.")
            }
            let transitions: [TransitionViewModel2] = machine.states[stateIndex].transitions.indices.map {
                guard let target = data[machine.states[stateIndex].transitions[$0].target] else {
                    fatalError("Trying to create transition for target state that doesn't exist")
                }
                return TransitionViewModel2(machine: machineBinding, path: machine.path.states[stateIndex].transitions[$0], transitionBinding: machineBinding.states[stateIndex].transitions[$0], source: CGPoint(x: 150, y: 150), target: target.left, notifier: self)
            }
            let newViewModel = StateViewModel2(machine: machineBinding, path: machine.path.states[stateIndex], state: machineBinding.states[stateIndex], notifier: self)
            newViewModel.transitions = transitions
            data[stateName] = newViewModel
            return newViewModel
        }
        return viewModel
    }
    
    func transitionViewModels(for state: StateName) -> [TransitionViewModel2] {
        viewModel(for: state).transitions
    }
    
    private func setupNewTransition(for transition: Int, originatingFrom stateName: StateName, goingTo targetState: StateName) -> TransitionViewModel2 {
        guard
            let stateIndex = machine.states.firstIndex(where: { $0.name == stateName }),
            let _ = machine.states.firstIndex(where: { $0.name == targetState })
        else {
            fatalError("State doesn't exist")
        }
        let source = viewModel(for: stateName)
        let target = viewModel(for: targetState)
        return TransitionViewModel2(machine: machineBinding, path: machine.path.states[stateIndex].transitions[transition], transitionBinding: machineBinding.states[stateIndex].transitions[transition], source: source, target: target, notifier: self)
    }
    
    func viewModel(for transition: Int, originatingFrom state: Machines.State) -> TransitionViewModel2 {
        return viewModel(for: transition, originatingFrom: state.name, goingTo: state.transitions[transition].target)
    }
    
    func viewModel(for transition: Int, originatingFrom stateName: StateName, goingTo targetState: StateName) -> TransitionViewModel2 {
        let viewModels = transitionViewModels(for: stateName)
        guard transition < viewModels.count && transition >= 0 else {
            let newViewModel = setupNewTransition(for: transition, originatingFrom: stateName, goingTo: targetState)
            viewModel(for: stateName).transitions.append(newViewModel)
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
                self.objectWillChange.send()
            }
        )
    }
    
    func binding(to transition: Int, originatingFrom state: Machines.State) -> Binding<TransitionViewModel2> {
        return Binding(
            get: {
                return self.viewModel(for: transition, originatingFrom: state)
            },
            set: {
                self.viewModel(for: state).transitions[transition] = $0
                self.objectWillChange.send()
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
                self.viewModel(for: name).transitions.indices.forEach {
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
                    self.viewModel(for: name).transitions[$0].curve = curve
                }
            }
            return
        }
        data.forEach {
            startLocations[$0.0] = $0.1.location
        }
        data.values.forEach { state in
            transitionStartLocations[state.state.wrappedValue.name] = state.transitions.map(\.curve)
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
        data.first(where: { $0.1.isWithin(point: point) })
    }
    
    func createNewTransition(sourceState: StateName, source: CGPoint, target: CGPoint) -> StateName? {
        guard
            let (targetName, targetState) = findStateFromPoint(point: target),
            let stateIndex = machine.states.firstIndex(where: { $0.name == sourceState })
        else {
            return nil
        }
        let sourceModel = viewModel(for: sourceState)
        let lastIndex = machine.states[stateIndex].transitions.count - 1
        guard lastIndex >= 0 else {
            return nil
        }
        sourceModel.transitions.append(TransitionViewModel2(machine: machineBinding, path: machine.path.states[stateIndex].transitions[lastIndex], transitionBinding: machineBinding.states[stateIndex].transitions[lastIndex], source: sourceModel, sourcePoint: source, target: targetState, targetPoint: target, notifier: self))
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
                    targetsDictionary[index] = self.viewModel(for: index, originatingFrom: name, goingTo: state).curve.point3
                }
            })
            targetTransitions[name] = targetsDictionary
            
        }
        return (movingSources, targetTransitions)
    }
    
    private func displaceTransitions(sourceTransitions: [CGPoint], targetTransitions: [StateName: [Int: CGPoint]], dS: CGSize, frame: CGSize, source: StateName) {
        guard let state = machine.states.first(where: { $0.name == source }) else {
            return
        }
        sourceTransitions.indices.forEach {
            let newX = min(max(0, sourceTransitions[$0].x + dS.width), frame.width)
            let newY = min(max(0, sourceTransitions[$0].y + dS.height), frame.height)
            let point = CGPoint(x: newX, y: newY)
            self.viewModel(for: $0, originatingFrom: state).curve.point0 = point
        }
        targetTransitions.keys.forEach { name in
            targetTransitions[name]!.keys.forEach { index in
                guard let sourceState = machine.states.first(where: { $0.name == name }) else {
                    return
                }
                let newX = min(max(0, targetTransitions[name]![index]!.x + dS.width), frame.width)
                let newY = min(max(0, targetTransitions[name]![index]!.y + dS.height), frame.height)
                let point = CGPoint(x: newX, y: newY)
                self.viewModel(for: index, originatingFrom: sourceState).curve.point3 = point
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
            self.viewModel(for: $0, originatingFrom: movingStateObj).curve.point0 = point
        }
        movingTargetTransitions.keys.forEach { name in
            movingTargetTransitions[name]!.keys.forEach { index in
                guard let stateObj = machine.states.first(where: { $0.name == name }) else {
                    return
                }
                let x = movingTargetTransitions[name]![index]!.x
                let y = movingTargetTransitions[name]![index]!.y
                let relativeX = x - model.location.x
                let relativeY = y - model.location.y
                let dx = (model.width - originalDimensions.0) / 2.0
                let dy = (model.height - originalDimensions.1) / 2.0
                let newX = relativeX < 0 ? x - dx : x + dx
                let newY = relativeY < 0 ? y - dy : y + dy
                let point = CGPoint(x: newX, y: newY)
                self.viewModel(for: index, originatingFrom: stateObj).curve.point3 = point
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
            .onEnded { gesture in
                view.creatingCurve = nil
                guard let targetName = self.data.values.first(where: { $0.isWithin(point: gesture.location, padding: 20.0) })?.state.wrappedValue.name else {
                    return
                }
                guard let _ = try? self.machineBinding.wrappedValue.newTransition(source: self.machine.states[index].name, target: targetName).get() else {
                    return
                }
                guard let _ = self.createNewTransition(sourceState: self.machine.states[index].name, source: gesture.startLocation, target: gesture.location) else {
                    return
                }
                let lastIndex = self.machine.states[index].transitions.count - 1
                guard lastIndex >= 0 else {
                    return
                }
                self.viewModel(for: lastIndex, originatingFrom: self.machine.states[index]).condition = "true"
            }
    }
    
    func dragStateGesture(forView view: CanvasView, forState index: Int, size: CGSize) -> some Gesture {
        DragGesture(minimumDistance: 0, coordinateSpace: .named(view.coordinateSpace))
            .onChanged {
                self.handleDrag(state: self.machine.states[index], gesture: $0, frameWidth: size.width, frameHeight: size.height)
                if !self.viewModel(for: self.machine.states[index].name).isStretchingX && !self.viewModel(for: self.machine.states[index].name).isStretchingY {
                    self.moveTransitions(state: self.machine.states[index].name, gesture: $0, states: self.machine.states, frame: size)
                } else {
                    self.stretchTransitions(state: self.machine.states[index].name, states: self.machine.states)
                }
            }.onEnded {
                self.finishMovingTransitions()
                self.finishDrag(state: self.machine.states[index], gesture: $0, frameWidth: size.width, frameHeight: size.height)
            }
    }
    
    func selectionBoxGesture(forView view: CanvasView) -> some Gesture {
        DragGesture(minimumDistance: 0, coordinateSpace: .named(view.coordinateSpace))
            .modifiers(.shift)
            .onChanged {
                view.selectedBox = ($0.startLocation, $0.location)
            }
            .modifiers(.shift)
            .onEnded {
                view.selectedObjects = self.findObjectsInSelection(corner0: $0.startLocation, corner1: $0.location, states: self.machine.states)
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
        let ts = sourceViewModel.transitions
        guard
            ts.count == source.transitions.count,
            let stateIndex = machine.states.firstIndex(where: { $0 == source })
        else {
            fatalError("No view models for some \(source.name) transitions")
        }
        let newViewModels: [TransitionViewModel2] = source.transitions.indices.map {
            let existingViewModel = self.viewModel(for: $0, originatingFrom: source)
            return TransitionViewModel2(
                machine: machineBinding,
                path: machine.path.states[stateIndex].transitions[$0],
                transitionBinding: machineBinding.states[stateIndex].transitions[$0],
                source: sourceViewModel,
                sourcePoint: existingViewModel.curve.point0,
                target: viewModel(for: source.transitions[$0].target),
                targetPoint: existingViewModel.curve.point3,
                notifier: self
            )
        }
        sourceViewModel.transitions = newViewModels
    }
    
    func updateTransitionsTargets(source: Machines.State, states: [Machines.State]) {
        guard let sourceIndex = machine.states.firstIndex(where: { $0 == source }) else {
            return
        }
        let targets = findMovingTransitions(state: source.name, states: states).1
        targets.keys.forEach { name in
            guard let state = machine.states.first(where: { $0.name == name }) else {
                return
            }
            targets[name]!.forEach { (index, _) in
                let existingViewModel = self.viewModel(for: index, originatingFrom: state)
                self.viewModel(for: name).transitions[index] = TransitionViewModel2(
                    machine: machineBinding,
                    path: machine.path.states[sourceIndex].transitions[index],
                    transitionBinding: machineBinding.states[sourceIndex].transitions[index],
                    source: viewModel(for: name),
                    sourcePoint: existingViewModel.curve.point0,
                    target: viewModel(for: source.name),
                    targetPoint: existingViewModel.curve.point3,
                    notifier: self
                )
            }
        }
    }
    
    func updateTransitionLocations(source: Machines.State, states: [Machines.State]) {
        updateTransitionsSources(source: source)
        updateTransitionsTargets(source: source, states: states)
    }
    
    private func removeViewFocus(view: CanvasView, focus: Focus, selected: ViewType) {
        if view.focus == focus {
            view.focus = .machine
        }
        if view.selectedObjects.contains(selected) {
            view.selectedObjects.remove(selected)
        }
    }
    
    private func addSelected(view: CanvasView, focus: Focus, selected: ViewType) {
        view.selectedObjects.insert(selected)
        if view.selectedObjects.count == 1 {
            view.focus = focus
            return
        }
        view.focus = .machine
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
    
    func deleteState(view: CanvasView, at index: Int) {
        let name = machine.states[index].name
        guard let _ = try? machineBinding.wrappedValue.deleteState(atIndex: index).get() else {
            print(machine.errorBag.errors(includingDescendantsForPath: machine.path.states[index]))
            return
        }
        data[name] = nil
        removeViewFocus(view: view, focus: .state(stateIndex: index), selected: .state(stateIndex: index))
        self.objectWillChange.send()
//        guard let stateTransitions = transitions[name] else {
//            return
//        }
//        unattachedTransitions.append(contentsOf: stateTransitions)
//        transitions[name] = []
    }
    
    func deleteTransition(view: CanvasView, for stateIndex: Int, at transitionIndex: Int) {
        guard machine.states.count > stateIndex else {
            return
        }
        let stateName = machine.states[stateIndex].name
        let stateViewModel = self.viewModel(for: stateName)
        let ts = stateViewModel.transitions
        guard
            ts.count > transitionIndex,
            let _ = try? machineBinding.wrappedValue.deleteTransition(atIndex: transitionIndex, attachedTo: stateName).get()
        else {
            return
        }
        stateViewModel.transitions.remove(at: transitionIndex)
        removeViewFocus(
            view: view,
            focus: .transition(stateIndex: stateIndex, transitionIndex: transitionIndex),
            selected: .transition(stateIndex: stateIndex, transitionIndex: transitionIndex)
        )
        self.objectWillChange.send()
    }
    
    private func states(from selected: Set<ViewType>) -> IndexSet {
        IndexSet(selected.compactMap {
            switch $0 {
            case .state(let stateIndex):
                return stateIndex
            default:
                return nil
            }
        })
    }
    
    private func transitions(from selected: Set<ViewType>, in states: [Machines.State]) -> [StateName: [Int]] {
        var transitionIndexes: [StateName: [Int]] = [:]
        selected.forEach {
            switch $0 {
            case .transition(let stateIndex, let transitionIndex):
                let stateName = states[stateIndex].name
                guard nil != transitionIndexes[stateName] else {
                    transitionIndexes[stateName] = [transitionIndex]
                    return
                }
                transitionIndexes[stateName]!.append(transitionIndex)
            default:
                return
            }
        }
        return transitionIndexes
    }
    
    func deleteSelected(_ view: CanvasView) {
        let stateIndexes = states(from: view.selectedObjects)
        let transitionIndexes = transitions(from: view.selectedObjects, in: machine.states)
        transitionIndexes.keys.forEach {
            guard let _ = try? self.machineBinding.wrappedValue.delete(transitions: IndexSet(transitionIndexes[$0]!), attachedTo: $0).get() else {
                print(self.machine.errorBag.allErrors.description)
                return
            }
        }
        guard let _ = try? machineBinding.wrappedValue.delete(states: stateIndexes).get() else {
            print(machine.errorBag.allErrors.description)
            self.objectWillChange.send()
            return
        }
        view.selectedObjects = []
        view.focus = .machine
        self.objectWillChange.send()
    }
    
    func states(_ machine: Machine) -> [Row<Machines.State>] {
        let x = machine.states.enumerated().map {
            Row(id: cache.id(for: $1), index: $0, data: $1)
        }
        return x
    }
    
    func transitions(_ row: Row<Machines.State>) -> [Row<Transition>] {
        row.data.transitions.enumerated().map {
            Row(id: transitionCache.id(for: CacheContainer(index: $0, value: $1)), index: $0, data: $1)
        }
    }
    
    func straighten(state: StateName, transition: Int) {
        guard let stateIndex = machine.states.firstIndex(where: { $0.name == state }) else {
            return
        }
        let stateViewModel = self.viewModel(for: state)
        let ts = stateViewModel.transitions
        guard ts.count > transition else {
            return
        }
        let viewModel = ts[transition]
        stateViewModel.transitions[transition] = TransitionViewModel2(
            machine: machineBinding,
            path: machine.path.states[stateIndex].transitions[transition],
            transitionBinding: machineBinding.states[stateIndex].transitions[transition],
            source: viewModel.curve.point0,
            target: viewModel.curve.point3,
            notifier: self
        )
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
    
}
