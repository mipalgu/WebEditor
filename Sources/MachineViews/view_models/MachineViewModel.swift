//
//  MachineViewModel.swift
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
import Transformations
import Utilities

public class MachineViewModel: ObservableObject, DynamicViewModel, Hashable {
    
    public func toggleExpand(frameWidth: CGFloat, frameHeight: CGFloat) {
    }
    

    public static func == (lhs: MachineViewModel, rhs: MachineViewModel) -> Bool {
        lhs === rhs
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(machine)
    }

    public var width: CGFloat = 1000.0
    
    public var height: CGFloat = 1000.0
    

    @Reference public var machine: Machine

    @Published var states: [StateViewModel]

    @Published public var _collapsedWidth: CGFloat = 100

    @Published public var _collapsedHeight: CGFloat = 100

    @Published public var _width: CGFloat

    @Published public var _height: CGFloat

    @Published public var location: CGPoint

    @Published public var expanded: Bool = false

    public let horizontalEdgeTolerance: CGFloat = 10

    public let verticalEdgeTolerance: CGFloat = 10

    public let minWidth: CGFloat = 200

    public let maxWidth: CGFloat = 1000

    public let minHeight: CGFloat = 100

    public let maxHeight: CGFloat = 800

    public let collapsedMinWidth: CGFloat = 100

    public let collapsedMaxWidth: CGFloat = 100

    public let collapsedMinHeight: CGFloat = 100

    public let collapsedMaxHeight: CGFloat = 100

    public var isDragging: Bool = false

    public var offset: CGPoint = .zero

    public var isStretchingX: Bool = false

    public var isStretchingY: Bool = false

    public var path: Attributes.Path<Machine, Machine> {
        machine.path
    }

    public var name: String {
        machine[keyPath: path.path].name
    }

    public var id: UUID {
        machine.id
    }

    let gridWidth: CGFloat = 80.0

    let gridHeight: CGFloat = 80.0

    public var isMoving: Bool = false

    var startLocations: [CGPoint] = []

    @Published var createTransitionMode: Bool = false

    @Published public var creatingTransition: Bool = false

    var dragStartLocation: CGPoint = .zero

    var source: StateViewModel?

    var destination: StateViewModel?

    @Published var currentMouseLocation: CGPoint = .zero

    var tempPoint0: CGPoint {
        guard let viewModel = source else {
            return .zero
        }
        return .zero
        //return viewModel.closestPointToEdge(point: dragStartLocation, source: currentMouseLocation)
    }

    var tempPoint1: CGPoint {
        let dx = currentMouseLocation.x - tempPoint0.x
        let dy = currentMouseLocation.y - tempPoint0.y
        return CGPoint(x: tempPoint0.x + dx / 3.0, y: tempPoint0.y + dy / 3.0)
    }

    var tempPoint2: CGPoint {
        let dx = currentMouseLocation.x - tempPoint0.x
        let dy = currentMouseLocation.y - tempPoint0.y
        return CGPoint(x: tempPoint0.x + dx * 2.0 / 3.0, y: tempPoint0.y + dy * 2.0 / 3.0)
    }

    var finishedDrag: Bool = false

    public convenience init(machine: Ref<Machine>) {
//        if let plist = try? String(contentsOf: machine.value.filePath.appendingPathComponent("Layout.plist")) {
//            self.init(machine: machine, plist: plist)
//        } else {
//            let statesPath: Attributes.Path<Machine, [Machines.State]> = machine.value.path.states
//            let states: [Machines.State] = machine.value[keyPath: statesPath.path]
//            let stateViewModels: [StateViewModel] = states.indices.map { stateIndex in
//                let stateX: CGFloat = 100.0
//                let stateY: CGFloat = 100.0 + CGFloat(stateIndex) * 200.0
////                return StateViewModel(
////                    machine: machine,
////                    path: machine.value.path.states[stateIndex],
////                    location: CGPoint(x: stateX, y: stateY)
////                )
//                return StateViewModel()
//            }
//            stateViewModels.enumerated().forEach { viewModel in
//                let transitionViewModels = viewModel.1.transitions.enumerated().map { (transition: (Int, Transition)) -> TransitionViewModel in
//                    guard let destinationViewModel = stateViewModels.first(where: { $0.name == transition.1.target }) else {
//                        fatalError("Failed to read machine \(machine.value.name). Transitions are pointing to states that don't exist. Machine may be corrupted.")
//                    }
//                    return TransitionViewModel(
//                        machine: machine,
//                        path: machine.value.path.states[viewModel.0].transitions[transition.0],
//                        source: viewModel.1,
//                        destination: destinationViewModel,
//                        priority: UInt8(transition.0)
//                    )
//                }
//                viewModel.1.transitionViewModels = transitionViewModels
//            }
//        }
        self.init(machine: machine, states: [])
    }

    public init(machine: Ref<Machine>, states: [StateViewModel], width: CGFloat = 100, height: CGFloat = 100, location: CGPoint = .zero) {
        self._width = width
        self._height = height
        self.location = location
        self._machine = Reference(reference: machine)
        self.states = states
        self.listen(to: $machine)
    }

    public func removeHighlights() {
//        states.forEach {
//            $0.highlighted = false
//        }
    }

    func getStateViewModel(stateName: String) -> StateViewModel {
//        guard let vm = self.states.first(where: { $0.name == stateName }) else {
//            fatalError("Tried to access state view model that didn't exist")
//        }
        return states.first!
    }

    func getStateIndex(viewModel: StateViewModel) -> Int? {
        self.states.firstIndex(where: { $0 === viewModel })
    }

    func deleteState(stateViewModel: StateViewModel) {
        /*if !stateViewModel.highlighted {
            return
        }*/
//        guard let stateIndex = self.states.firstIndex(of: stateViewModel) else {
//            return
//        }
//        do {
//            try self.machine.deleteState(atIndex: stateViewModel.stateIndex)
//            self.states.remove(at: stateIndex)
//        } catch let error {
//            print(error)
//        }
    }

    public func save() {
        do {
            try machine.save()
            let layoutPath = machine.filePath.appendingPathComponent("Layout.plist")
            let pListData = self.toPlist()
            try pListData.write(to: layoutPath, atomically: true, encoding: .utf8)
            let languagePath = machine.filePath.appendingPathComponent("Semantics.json")
            let encoder = JSONEncoder()
            let jsonData = try encoder.encode(machine.semantics)
            try jsonData.write(to: languagePath)
        } catch let error {
            print(error, stderr)
        }
    }

    func newState() {
//        do {
//            try machine.newState()
//            guard let newStateIndex = machine.states.firstIndex(where: { state in
//                nil == states.map { $0.name }.first(where: { state.name == $0 })
//            }) else {
//                fatalError("Failed to insert new state.")
//            }
//            states.insert(StateViewModel(machine: $machine, path: machine.path.states[newStateIndex]), at: newStateIndex)
//        } catch let error {
//            print("Failed to create state")
//            print(error, stderr)
//        }
    }

    public func moveElements(gesture: DragGesture.Value, frameWidth: CGFloat, frameHeight: CGFloat) {
//        if isMoving {
//            self.states.indices.forEach {
//                states[$0].location = CGPoint(
//                    x: startLocations[$0].x + gesture.translation.width,
//                    y: startLocations[$0].y + gesture.translation.height
//                )
//                states[$0].transitionViewModels.forEach {
//                    $0.point0 = $0.translate(point: $0.startLocation.0, trans: gesture.translation)
//                    $0.point1 = $0.translate(point: $0.startLocation.1, trans: gesture.translation)
//                    $0.point2 = $0.translate(point: $0.startLocation.2, trans: gesture.translation)
//                    $0.point3 = $0.translate(point: $0.startLocation.3, trans: gesture.translation)
//                }
//            }
//            return
//        }
//        startLocations = self.states.map {
//            $0.transitionViewModels.forEach {ts in
//                ts.startLocation = (ts.point0, ts.point1, ts.point2, ts.point3)
//            }
//            return $0.location
//        }
//        isMoving = true
    }

    public func finishMoveElements(gesture: DragGesture.Value, frameWidth: CGFloat, frameHeight: CGFloat) {
        moveElements(gesture: gesture, frameWidth: frameWidth, frameHeight: frameHeight)
        isMoving = false
    }

    public func startCreatingTransition(gesture: DragGesture.Value, sourceViewModel: StateViewModel) {
        if creatingTransition {
            currentMouseLocation = gesture.location
            return
        }
        source = sourceViewModel
        dragStartLocation = gesture.startLocation
        creatingTransition = true
    }

    public func finishCreatingTransition(gesture: DragGesture.Value, sourceViewModel: StateViewModel) {
//        if !creatingTransition {
//            return
//        }
//        creatingTransition = false
//        guard let destinationCandidate = states.first(where: { $0.isWithin(point: gesture.location) }) else {
//            print("You must finish dragging a transition to a valid state.")
//            return
//        }
//        sourceViewModel.createNewTransition(destination: destinationCandidate, point0: gesture.startLocation, point3: gesture.location)
    }

    public func getExternalTransitionsForState(state: StateViewModel) -> [TransitionViewModel] {
//        states.flatMap {
//            $0.transitionViewModels.filter { $0.transition.target == state.name }
//        }
        return []
    }

}
