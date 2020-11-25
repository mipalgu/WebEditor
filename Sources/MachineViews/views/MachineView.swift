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

public struct MachineView: View {
    
    @ObservedObject var editorViewModel: EditorViewModel
    
    @ObservedObject var viewModel: MachineViewModel
    
    @EnvironmentObject var config: Config
    
    public init(editorViewModel: EditorViewModel, viewModel: MachineViewModel) {
        self.editorViewModel = editorViewModel
        self.viewModel = viewModel
    }
    
    public var body: some View {
        ZStack {
            ForEach(viewModel.states, id: \.name) { (stateViewModel) -> AnyView in
                AnyView(StateView(editorViewModel: editorViewModel, viewModel: stateViewModel)
                    .contextMenu {
                        Button(action: {
                            viewModel.deleteState(stateViewModel: stateViewModel)
                        }) {
                            Text("Delete")
                                .font(config.fontBody)
                        }
                        .keyboardShortcut(.delete)
                    })
            }
            ForEach(viewModel.states, id: \.name) { (stateViewModel: StateViewModel) in
                ForEach(stateViewModel.transitions.indices, id: \.self) { (index: Int) in
                    TransitionView(
                        viewModel: stateViewModel.transitionViewModel(
                            transition: stateViewModel.transitions[index],
                            index: index,
                            target: viewModel.getStateViewModel(stateName: stateViewModel.transitions[index].target)
                        )
                    )
                }
            }
        }
        .background(
            GeometryReader { reader in
                ZStack {
                    HStack {
                        ForEach(Array(stride(from: -reader.size.width / 2.0 + viewModel.gridWidth, to: reader.size.width / 2.0, by: viewModel.gridWidth)), id: \.self) {
                            Divider()
                                .coordinateSpace(name: "MAIN_VIEW")
                                .position(x: $0, y: reader.size.height / 2.0)
                                .frame(width: 2.0, height: reader.size.height)
                                .foregroundColor(config.stateColour)
                        }
                    }
                    VStack {
                        ForEach(
                            Array(stride(from: -reader.size.height / 2.0 + viewModel.gridHeight, to: reader.size.height / 2.0, by: viewModel.gridHeight)),
                            id: \.self
                        ) {
                            Divider()
                                .coordinateSpace(name: "MAIN_VIEW")
                                .position(x: reader.size.width / 2.0, y: $0)
                                .frame(width: reader.size.width, height: 2.0)
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
                        editorViewModel.changeFocus(machine: viewModel.id)
                    }
                    .gesture(DragGesture(minimumDistance: 0, coordinateSpace: .named("MAIN_VIEW"))
                        .onChanged {
                            self.viewModel.handleDrag(gesture: $0, frameWidth: reader.size.width, frameHeight: reader.size.height)
                        }.onEnded {
                            self.viewModel.finishDrag(gesture: $0, frameWidth: reader.size.width, frameHeight: reader.size.height)
                        }
                    )
                )
            }
            .clipped()
        )
    }
}

