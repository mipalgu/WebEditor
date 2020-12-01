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
    
    @EnvironmentObject var config: Config
    
    public init(editorViewModel: EditorViewModel, viewModel: MachineViewModel) {
        self.editorViewModel = editorViewModel
        self.viewModel = viewModel
    }
    
    public var body: some View {
        GeometryReader { (geometry: GeometryProxy) in
            ZStack {
                ForEach(viewModel.states, id: \.name) { (stateViewModel) -> HiddenStateView in
                    HiddenStateView(
                        viewModel: stateViewModel,
                        editorViewModel: editorViewModel,
                        machineViewModel: viewModel,
                        parentWidth: geometry.size.width,
                        parentHeight: geometry.size.height
                    )
                }
                ForEach(viewModel.states, id: \.name) { (stateViewModel: StateViewModel) in
                    ForEach(Array(stateViewModel.transitions.indices), id: \.self) { index in
                        TransitionView(
                            viewModel: stateViewModel.transitionViewModel(
                                transition: stateViewModel.transitions[index],
                                index: index,
                                target: self.viewModel.getStateViewModel(stateName: stateViewModel.transitions[index].target)
                            )
                        )
                    }
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

