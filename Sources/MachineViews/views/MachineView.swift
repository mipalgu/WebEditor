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

public struct MachineView: View {
    
    @Binding var machine: Machine
    
    @Binding var creatingTransitions: Bool
    
    @EnvironmentObject var config: Config
    
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
                ForEach(Array(machine.states.indices), id: \.self) {
                    HiddenStateView(
                        machine: $machine,
                        path: machine.path.states[$0],
                        viewModel: StateViewModel2(
                            machine: $machine,
                            path: machine.path.states[$0]
                        ),
                        hidden: .constant(false),
                        highlighted: .constant(false)
                    )
                }
            }
            .background(
                GridView(
                    width: geometry.size.width,
                    height: geometry.size.height,
                    coordinateSpace: "MAIN_VIEW",
                    backgroundColor: config.backgroundColor,
                    foregroundColor: config.stateColour
                )
            )
        }
    }
}

