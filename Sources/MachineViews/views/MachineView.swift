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
    
    init(data: [StateName: StateViewModel2] = [:], transitions: [StateName: [TransitionViewModel2]] = [:]) {
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
    
    func viewModel(for transition: Int, originatingFrom state: Machines.State) -> TransitionViewModel2 {
        return viewModel(for: transition, originatingFrom: state.name)
    }
    
    func viewModel(for transition: Int, originatingFrom stateName: StateName) -> TransitionViewModel2 {
        guard let viewModels = transitions[stateName] else {
            let newViewModel = TransitionViewModel2(source: .zero, target: .zero)
            transitions[stateName] = Array(repeating: newViewModel, count: transition + 1)
            return newViewModel
        }
        if viewModels.count <= transition {
            let newViewModel = TransitionViewModel2(source: .zero, target: .zero)
            transitions[stateName]?.append(contentsOf: Array(repeating: newViewModel, count: viewModels.count - transition - 1))
            return newViewModel
        }
        return viewModels[transition]
    }
    
//    func transitionViewModel(for state: Machines.State, index: Int) -> TransitionViewModel2 {
//        let stateViewModel = viewModel(for: state)
//        guard let viewModel = transitions[state.name]?[index] else {
//            let targetStateName = state.transitions[index].target
//            let targetViewModel = self.viewModel(for: targetStateName)
//            let sourceEdge = stateViewModel.findEdge(point: targetViewModel.location)
//            let targetEdge = targetViewModel.findEdge(point: stateViewModel.location)
//            let newViewModel = TransitionViewModel2(source: sourceEdge, target: targetEdge)
//            appendToOrder(stateName: state.name, id: newViewModel.id)
//            return newViewModel
//        }
//        return viewModel
//    }
    
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
//                data[$0].transitionViewModels.forEach {
//                    $0.point0 = $0.translate(point: $0.startLocation.0, trans: gesture.translation)
//                    $0.point1 = $0.translate(point: $0.startLocation.1, trans: gesture.translation)
//                    $0.point2 = $0.translate(point: $0.startLocation.2, trans: gesture.translation)
//                    $0.point3 = $0.translate(point: $0.startLocation.3, trans: gesture.translation)
//                }
            }
            return
        }
        data.forEach {
            startLocations[$0.0] = $0.1.location
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
    
}

public struct MachineView: View {
    
    @Binding var machine: Machine
    
    @Binding var creatingTransitions: Bool
    
    @EnvironmentObject var config: Config
    
    @StateObject var viewModel = MachineViewModel2()
    
    let coordinateSpace = "MAIN_VIEW"
    
    let textWidth: CGFloat = 50.0
    
    let textHeight: CGFloat = 20.0
    
    public init(machine: Binding<Machine>, creatingTransitions: Binding<Bool>) {
        self._machine = machine
        self._creatingTransitions = creatingTransitions
    }
    
//    func isFocused(stateIndex: Int, transitionIndex: Int) -> Binding<Bool> {
//        Binding(get: {
//            switch editorViewModel.focusedView {
//            case .transition(let stateInd, let transInd):
//                return transInd == transitionIndex && stateIndex == stateInd
//            default:
//                return false
//            }
//        }, set: {
//            if $0 {
//                editorViewModel.focusedView = ViewType.transition(stateIndex: stateIndex, transitionIndex: transitionIndex)
//            }
//        })
//    }
    
    public var body: some View {
        GeometryReader { (geometry: GeometryProxy) in
            ZStack {
                Image("grid", bundle: Bundle.module)
                    .resizable(resizingMode: .tile)
                    .frame(width: geometry.size.width, height: geometry.size.height)
                    .gesture(DragGesture(minimumDistance: 0, coordinateSpace: .named(coordinateSpace))
                        .onChanged {
                            self.viewModel.moveElements(gesture: $0, frameWidth: geometry.size.width, frameHeight: geometry.size.height)
                        }.onEnded {
                            self.viewModel.finishMoveElements(gesture: $0, frameWidth: geometry.size.width, frameHeight: geometry.size.height)
                        }
                    )
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
                                    .onChanged {
                                        self.viewModel.handleDrag(state: machine.states[index], gesture: $0, frameWidth: geometry.size.width, frameHeight: geometry.size.height)
                                    }.onEnded {
                                        self.viewModel.finishDrag(state: machine.states[index], gesture: $0, frameWidth: geometry.size.width, frameHeight: geometry.size.height)
                                    }
                            )
                        }
                    }
                }
            }.frame(width: geometry.size.width, height: geometry.size.height)
        }
    }
}

