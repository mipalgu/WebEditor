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

struct MainView: View {
    
    @ObservedObject var editorViewModel: EditorViewModel
    
    @ObservedObject var machineViewModel: MachineViewModel
    
    @Binding var type: ViewType
    
    @EnvironmentObject var config: Config
    
    var body: some View {
        switch type {
        case .machine:
            MachineView(editorViewModel: editorViewModel, viewModel: machineViewModel)
                .coordinateSpace(name: "MAIN_VIEW")
        case .state(let stateIndex):
            StateEditView(viewModel: machineViewModel.states[stateIndex])
        default:
            EmptyView()
        }
    }
}

