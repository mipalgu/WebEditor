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
    
    @ObservedObject var editorViewModel: EditorViewModel
    
    @ObservedObject var viewModel: MachineViewModel
    
    @Binding var creatingTransitions: Bool
    
    @EnvironmentObject var config: Config
    
    public init(editorViewModel: EditorViewModel, viewModel: MachineViewModel, creatingTransitions: Binding<Bool>) {
        self.editorViewModel = editorViewModel
        self.viewModel = viewModel
        self._creatingTransitions = creatingTransitions
    }
    
    func isFocused(state: StateViewModel, transitionIndex: Int) -> Binding<Bool> {
        Binding(get: {
            switch editorViewModel.focusedView {
            case .transition(let stateIndex, let transIndex):
                return transIndex == transitionIndex && viewModel.states[stateIndex] === state
            default:
                return false
            }
        }, set: {
            guard let stateIndex = editorViewModel.machine.getStateIndex(viewModel: state) else {
                return
            }
            if $0 {
                editorViewModel.focusedView = ViewType.transition(stateIndex: stateIndex, transitionIndex: transitionIndex)
            }
        })
    }
    
    public var body: some View {
        GeometryReader { (geometry: GeometryProxy) in
            ZStack {
                ForEach(viewModel.states, id: \.name) { (stateViewModel: StateViewModel) -> HiddenStateView in
                    HiddenStateView(
                        viewModel: stateViewModel,
                        editorViewModel: editorViewModel,
                        machineViewModel: viewModel,
                        creatingTransitions: $creatingTransitions,
                        parentWidth: geometry.size.width,
                        parentHeight: geometry.size.height
                    )
                }
                ForEach(Array(viewModel.states.indices), id: \.self) { (stateIndex: Int) in
                    ForEach(Array(viewModel.states[stateIndex].transitions.indices), id: \.self) { (index: Int) -> AnyView in
                        AnyView(TransitionView(
                            viewModel: viewModel.states[stateIndex].transitionViewModel(
                                transition: viewModel.states[stateIndex].transitions[index],
                                index: index,
                                target: self.viewModel.getStateViewModel(
                                    stateName: viewModel.states[stateIndex].transitions[index].target
                                )
                            ),
                            focused: isFocused(state: viewModel.states[stateIndex], transitionIndex: index)
                        )
                        .onTapGesture(count: 1) {
                            editorViewModel.focusedView = ViewType.transition(stateIndex: stateIndex, transitionIndex: index)
                        })
                    }
                }
                if viewModel.creatingTransition {
                    ArrowView(
                        point0: viewModel.tempPoint0Binding,
                        point1: viewModel.tempPoint1Binding,
                        point2: viewModel.tempPoint2Binding,
                        point3: viewModel.tempPoint3Binding,
                        strokeNumber: viewModel.tempStrokeNumberBinding,
                        focused: Binding(get: { false }, set: { _ in }),
                        colour: Color.red
                    )
                }
            }
            .background(
                ZStack {
                    HStack {
                        ForEach(Array(stride(from: -geometry.size.width / 2.0 + viewModel.gridWidth, to: geometry.size.width / 2.0, by: viewModel.gridWidth)), id: \.self) {
                            Divider()
                                .coordinateSpace(name: "MAIN_VIEW")
                                .position(x: $0, y: geometry.size.height / 2.0)
                                .frame(width: 2.0, height: geometry.size.height)
                                .foregroundColor(config.stateColour)
                        }
                    }
                    VStack {
                        ForEach(
                            Array(stride(from: -geometry.size.height / 2.0 + viewModel.gridHeight, to: geometry.size.height / 2.0, by: viewModel.gridHeight)),
                            id: \.self
                        ) {
                            Divider()
                                .coordinateSpace(name: "MAIN_VIEW")
                                .position(x: geometry.size.width / 2.0, y: $0)
                                .frame(width: geometry.size.width, height: 2.0)
                                .foregroundColor(config.stateColour)
                        }
                    }
                }
                .background(
                    config.backgroundColor
                    .onTapGesture(count: 2) {
                        viewModel.newState()
                    }
                    .onTapGesture(count: 1) {
                        viewModel.removeHighlights()
                        editorViewModel.changeFocus()
                    }
                    .gesture(DragGesture(minimumDistance: 0, coordinateSpace: .named("MAIN_VIEW"))
                        .onChanged {
                            self.viewModel.moveElements(gesture: $0, frameWidth: geometry.size.width, frameHeight: geometry.size.height)
                        }.onEnded {
                            self.viewModel.finishMoveElements(gesture: $0, frameWidth: geometry.size.width, frameHeight: geometry.size.height)
                        }
                    )
                )
                .clipped()
            )
        }
    }
}

