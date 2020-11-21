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
    
    @Binding var type: ViewType
    
    @EnvironmentObject var config: Config
    
    var body: some View {
        switch type {
        case .machine(let machine):
            MachineView(viewModel: machine)
                .coordinateSpace(name: "MAIN_VIEW")
        case .state(let state):
            StateEditView(viewModel: state)
        default:
            EmptyView()
        }
    }
}

