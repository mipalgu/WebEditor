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
    
    init(data: [StateName: StateViewModel2] = [:]) {
        self.data = data
    }
    
    func viewModel(for state: Machines.State) -> StateViewModel2 {
        guard let viewModel = data[state.name] else {
            let newViewModel = StateViewModel2()
            data[state.name] = newViewModel
            return newViewModel
        }
        return viewModel
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
    
    func handleDrag(state: Machines.State, gesture: DragGesture.Value, frameWidth: CGFloat, frameHeight: CGFloat) {
        mutate(state) { $0.handleDrag(gesture: gesture, frameWidth: frameWidth, frameHeight: frameHeight) }
    }
    
    func finishDrag(state: Machines.State, gesture: DragGesture.Value, frameWidth: CGFloat, frameHeight: CGFloat) {
        mutate(state) { $0.finishDrag(gesture: gesture, frameWidth: frameWidth, frameHeight: frameHeight) }
    }
    
}

public struct MachineView: View {
    
    @Binding var machine: Machine
    
    @Binding var creatingTransitions: Bool
    
    @EnvironmentObject var config: Config
    
    @StateObject var viewModel = MachineViewModel2()
    
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
//                ForEach(machine.path.states, id: \.self) { statePath in
//                    ForEach(Array(viewModel.states[stateIndex].transitions.indices), id: \.self) { (index: Int) -> AnyView in
//                        let stateViewModel = viewModel.states[stateIndex]
//                        let transition = stateViewModel.transitions[index]
//                        guard let transitionViewModel = index >= stateViewModel.transitionViewModels.count ? nil : stateViewModel.transitionViewModels[index],
//                            stateViewModel.path.transitions[index] == transitionViewModel.path,
//                            transition == transitionViewModel.machine[keyPath: transitionViewModel.path.path]
//                        else {
//                            let transViewModel = stateViewModel.transitionViewModel(
//                                transition: stateViewModel.transitions[index],
//                                index: index,
//                                target: self.viewModel.getStateViewModel(
//                                    stateName: viewModel.states[stateIndex].transitions[index].target
//                                )
//                            )
//                            viewModel.states[stateIndex].transitionViewModels.insert(transViewModel, at: index)
//                            return AnyView(TransitionView(
//                                viewModel: transViewModel,
//                                focused: isFocused(stateIndex: stateIndex, transitionIndex: index),
//                                frameWidth: geometry.size.width,
//                                frameHeight: geometry.size.height
//                            )
//                            .onTapGesture(count: 1) {
//                                editorViewModel.focusedView = ViewType.transition(stateIndex: stateIndex, transitionIndex: index)
//                            }.clipped())
//                        }
//                        return AnyView(TransitionView(
//                            viewModel: transitionViewModel,
//                            focused: isFocused(stateIndex: stateIndex, transitionIndex: index),
//                            frameWidth: geometry.size.width,
//                            frameHeight: geometry.size.height
//                        )
//                        .onTapGesture(count: 1) {
//                            editorViewModel.focusedView = ViewType.transition(stateIndex: stateIndex, transitionIndex: index)
//                        }.clipped())
//
//                    }
//                }
//                if viewModel.creatingTransition {
//                    ArrowView(
//                        point0: viewModel.tempPoint0,
//                        point1: viewModel.tempPoint1,
//                        point2: viewModel.tempPoint2,
//                        point3: viewModel.currentMouseLocation,
//                        strokeNumber: 0,
//                        colour: Color.red
//                    )
//                }
                ForEach(Array(machine.states.indices), id: \.self) { index in
                    if viewModel.viewModel(for: machine.states[index]).isText {
                        Text(machine.states[index].name)
                            .font(config.fontBody)
                            //.foregroundColor(viewModel.viewModel(for: machine[keyPath: machine.path.states[index].name.keyPath]).highlighted ? config.highlightColour : config.textColor)
                    } else {
                        StateView(machine: $machine, path: machine.path.states[index], expanded: viewModel.binding(to: machine.states[index]).expanded)
                            .coordinateSpace(name: "MAIN_VIEW")
                            .position(viewModel.viewModel(for: machine.states[index]).location)
                            .frame(
                                width: viewModel.viewModel(for: machine.states[index]).width,
                                height: viewModel.viewModel(for: machine.states[index]).height
                            )
                            .gesture(
                                DragGesture(minimumDistance: 0, coordinateSpace: .named("MAIN_VIEW"))
                                    .onChanged {
                                        self.viewModel.handleDrag(state: machine.states[index], gesture: $0, frameWidth: 10000, frameHeight: 10000)
                                    }.onEnded {
                                        self.viewModel.finishDrag(state: machine.states[index], gesture: $0, frameWidth: 10000, frameHeight: 10000)
                                    }
                            )
                    }
                }
            }
        }.background(Image("grid", bundle: Bundle.module).resizable(resizingMode: .tile))
    }
}

