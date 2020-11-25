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
    
    @ObservedObject var editorViewModel: EditorViewModel
    
    @EnvironmentObject var config: Config
    
    var body: some View {
        switch config.alertView {
        case .saveMachine:
            SaveMachineView(viewModel: machineViewModel)
                .focusable()
        case .openMachine:
            OpenMachineView(editorViewModel: editorViewModel, machineURL: machineViewModel.machine.filePath, selected: .swiftfsm)
        default:
            EmptyView()
        }
    }
}
