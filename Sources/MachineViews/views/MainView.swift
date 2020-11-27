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
    
    @ObservedObject var viewModel: EditorViewModel
    
    @Binding var type: ViewType
    
    @EnvironmentObject var config: Config
    
    var body: some View {
        switch type {
        case .machine, .transition:
            MachineView(editorViewModel: viewModel, viewModel: viewModel.machine)
                .coordinateSpace(name: "MAIN_VIEW")
                
        case .state(let stateIndex):
            StateEditView(viewModel: viewModel.machine.states[stateIndex])
                .onTapGesture(count: 2) {
                    viewModel.changeMainView()
                    viewModel.changeFocus()
                }
        }
    }
}

