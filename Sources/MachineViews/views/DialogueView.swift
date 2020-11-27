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
    
    @ObservedObject var viewModel: EditorViewModel
    
    @EnvironmentObject var config: Config
    
    var body: some View {
        switch viewModel.dialogueType {
        case .save:
            SaveMachineView(viewModel: viewModel)
                .focusable()
        case .open:
            OpenMachineView(viewModel: viewModel, machineURL: viewModel.machine.machine.filePath, selected: .swiftfsm)
        default:
            EmptyView()
        }
    }
}
