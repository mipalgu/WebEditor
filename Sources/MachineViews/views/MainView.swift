//
//  MainView.swift
//  
//
//  Created by Morgan McColl on 21/11/20.
//

#if canImport(TokamakShim)
import TokamakShim
#else
import SwiftUI
#endif

import Machines
import Attributes
import Utilities

struct MainView: View {
    
    @ObservedObject var editorViewModel: EditorViewModel
    
    @ObservedObject var machineViewModel: MachineViewModel
    
    @Binding var type: ViewType
    
    @Binding var creatingTransitions: Bool
    
    @EnvironmentObject var config: Config
    
    var body: some View {
        switch type {
        case .machine, .transition:
            MachineView(editorViewModel: editorViewModel, viewModel: machineViewModel, creatingTransitions: $creatingTransitions)
                .coordinateSpace(name: "MAIN_VIEW")
                
        case .state(let stateIndex):
            StateEditView(viewModel: machineViewModel.states[stateIndex])
                .onTapGesture(count: 2) {
                    editorViewModel.changeMainView()
                    editorViewModel.changeFocus()
                }
                .background(KeyEventHandling(keyDownCallback: {
                    if $0.keyCode == 53 {
                        editorViewModel.changeMainView()
                        editorViewModel.changeFocus()
                    }
                }, keyUpCallback: { _ in }))
        }
    }
}

