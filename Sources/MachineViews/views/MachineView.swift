//
//  MachineView.swift
//
//
//  Created by Morgan McColl on 16/11/20.
//

#if canImport(TokamakShim)
import TokamakShim
#else
import SwiftUI
#endif

import Machines
import Attributes
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
    
    private func findMovingTransitions(state: StateName, states: [Machines.State]) {
        movingState = state
        movingSourceTransitions = transitions[state]!.map { $0.curve.point0 }
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
        movingTargetTransitions = targetTransitions
    }
    
    func moveTransitions(state: StateName, gesture: DragGesture.Value, states: [Machines.State], frameWidth: CGFloat, frameHeight: CGFloat) {
        if !isStateMoving {
            isStateMoving = true
            findMovingTransitions(state: state, states: states)
            return
        }
        movingSourceTransitions.indices.forEach {
            let newX = min(max(0, movingSourceTransitions[$0].x + gesture.translation.width), frameWidth)
            let newY = min(max(0, movingSourceTransitions[$0].y + gesture.translation.height), frameHeight)
            let point = CGPoint(x: newX, y: newY)
            transitions[movingState]![$0].curve.point0 = point
        }
        movingTargetTransitions.keys.forEach { name in
            movingTargetTransitions[name]!.keys.forEach { index in
                let newX = min(max(0, movingTargetTransitions[name]![index]!.x + gesture.translation.width), frameWidth)
                let newY = min(max(0, movingTargetTransitions[name]![index]!.y + gesture.translation.height), frameHeight)
                let point = CGPoint(x: newX, y: newY)
                transitions[name]![index].curve.point3 = point
            }
        }
    }
    
    func stretchTransitions(state: StateName, states: [Machines.State]) {
        let model = viewModel(for: state)
        if !isStateMoving {
            isStateMoving = true
            findMovingTransitions(state: state, states: states)
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
    
    
}

public struct MachineView: View {
    
    @Binding var machine: Machine
    
    @State var creatingCurve: Curve? = nil
    
    @EnvironmentObject var config: Config
    
    @StateObject var viewModel: MachineViewModel2
    
    let coordinateSpace = "MAIN_VIEW"
    
    let textWidth: CGFloat = 50.0
    
    let textHeight: CGFloat = 20.0
    
    public init(machine: Binding<Machine>) {
        self._machine = machine
        self._viewModel = StateObject(wrappedValue: MachineViewModel2(states: machine.states.wrappedValue))
    }
    
    public var body: some View {
        GeometryReader { (geometry: GeometryProxy) in
            ZStack {
                GridView()
                    .frame(width: geometry.size.width, height: geometry.size.height)
                    .gesture(DragGesture(minimumDistance: 0, coordinateSpace: .named(coordinateSpace))
                        .onChanged {
                            self.viewModel.moveElements(gesture: $0, frameWidth: geometry.size.width, frameHeight: geometry.size.height)
                        }.onEnded {
                            self.viewModel.finishMoveElements(gesture: $0, frameWidth: geometry.size.width, frameHeight: geometry.size.height)
                        }
                    )
                if let curve = creatingCurve {
                    ArrowView(curve: .constant(curve), strokeNumber: 0, colour: config.highlightColour)
                }
                ForEach(Array(machine.states.indices), id: \.self) { index in
                        ForEach(Array(machine.states[index].transitions.indices), id: \.self) { t in
                                TransitionView(
                                    machine: $machine,
                                    path: machine.path.states[index].transitions[t],
                                    curve: viewModel.binding(to: t, originatingFrom: machine.states[index]).curve,
                                    strokeNumber: UInt8(t),
                                    focused: .constant(false)
                                )
                                .clipped()
                    }
                }
                ForEach(Array(machine.states.indices), id: \.self) { index in
                    if viewModel.viewModel(for: machine.states[index]).isText {
                        VStack {
                            Text(machine.states[index].name)
                                .font(config.fontBody)
                                .frame(width: textWidth, height: textHeight)
                            //.foregroundColor(viewModel.viewModel(for: machine[keyPath: machine.path.states[index].name.keyPath]).highlighted ? config.highlightColour : config.textColor)
                        }
                        .coordinateSpace(name: coordinateSpace)
                        .position(viewModel.clampPosition(point: viewModel.viewModel(for: machine.states[index]).location, frameWidth: geometry.size.width, frameHeight: geometry.size.height, dx: textWidth / 2.0, dy: textHeight / 2.0))
                    } else {
                        ZStack {
                            VStack {
                                StateView(
                                    machine: $machine,
                                    path: machine.path.states[index],
                                    expanded: Binding(
                                        get: { viewModel.viewModel(for: machine.states[index]).expanded },
                                        set: { viewModel.assignExpanded(for: machine.states[index], newValue: $0, frameWidth: geometry.size.width, frameHeight: geometry.size.height) }
                                    ),
                                    collapsedActions: viewModel.binding(to: machine.states[index]).collapsedActions
                                )
                                    .frame(
                                        width: viewModel.viewModel(for: machine.states[index]).width,
                                        height: viewModel.viewModel(for: machine.states[index]).height
                                    )
                            }.coordinateSpace(name: coordinateSpace)
                            .position(viewModel.viewModel(for: machine.states[index]).location)
                            .gesture(
                                DragGesture(minimumDistance: 0, coordinateSpace: .named(coordinateSpace))
                                    .modifiers(.control)
                                    .onChanged {
                                        self.creatingCurve = Curve(source: $0.startLocation, target: $0.location)
                                    }
                                    .modifiers(.control)
                                    .onEnded {
                                        self.creatingCurve = nil
                                        guard let targetName = self.viewModel.createNewTransition(sourceState: machine.states[index].name, source: $0.startLocation, target: $0.location) else {
                                            return
                                        }
                                        try? machine.newTransition(source: machine.states[index].name, target: targetName)
                                    }
                            )
                            .gesture(
                                DragGesture(minimumDistance: 0, coordinateSpace: .named(coordinateSpace))
                                    .onChanged {
                                        self.viewModel.handleDrag(state: machine.states[index], gesture: $0, frameWidth: geometry.size.width, frameHeight: geometry.size.height)
                                        if !self.viewModel.viewModel(for: machine.states[index].name).isStretchingX && !self.viewModel.viewModel(for: machine.states[index].name).isStretchingY {
                                            self.viewModel.moveTransitions(state: machine.states[index].name, gesture: $0, states: machine.states, frameWidth: geometry.size.width, frameHeight: geometry.size.height)
                                        } else {
                                            self.viewModel.stretchTransitions(state: machine.states[index].name, states: machine.states)
                                        }
                                    }.onEnded {
                                        self.viewModel.finishMovingTransitions()
                                        self.viewModel.finishDrag(state: machine.states[index], gesture: $0, frameWidth: geometry.size.width, frameHeight: geometry.size.height)
                                    }
                            )
                            
                        }
                    }
                }
            }.frame(width: geometry.size.width, height: geometry.size.height)
            .clipped()
        }
    }
}

struct MachineView_Previews: PreviewProvider {
    
    struct Preview: View {
        
        @State var machine: Machine = Machine.initialSwiftMachine()
        
        @State var creatingTransitions: Bool = false
        
        let config = Config()
        
        var body: some View {
            MachineView(machine: $machine).environmentObject(config)
        }
        
    }
    
    static var previews: some View {
        VStack {
            Preview()
        }
    }
}
