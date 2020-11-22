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
            ForEach(viewModel.states, id: \.name) {
                StateView(editorViewModel: editorViewModel, viewModel: $0)
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
    }
}

