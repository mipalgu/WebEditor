//
//  SwiftUIView.swift
//  
//
//  Created by Morgan McColl on 25/11/20.
//

#if canImport(TokamakShim)
import TokamakShim
#else
import SwiftUI
#endif
import Machines
import Attributes

struct DialogueView: View {
    
    @ObservedObject var machineViewModel: MachineViewModel
    
    @EnvironmentObject var config: Config
    
    var body: some View {
        switch config.alertView {
        case .machine:
            SaveMachineView(viewModel: machineViewModel)
                .focusable()
        default:
            EmptyView()
        }
    }
}
