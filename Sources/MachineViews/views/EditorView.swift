//
//  EditorView.swift
//  
//
//  Created by Morgan McColl on 20/11/20.
//

#if canImport(TokamakShim)
import TokamakShim
#else
import SwiftUI
#endif
import Machines
import Attributes

public struct EditorView: View {
    
    @ObservedObject var viewModel: EditorViewModel
    
    @ObservedObject var machineViewModel: MachineViewModel
    
    @EnvironmentObject var config: Config
    
    public init(viewModel: EditorViewModel, machineViewModel: MachineViewModel) {
        self.viewModel = viewModel
        self.machineViewModel = machineViewModel
    }
    
    public var body: some View {
        VStack {
            MenuView()
                .background(config.stateColour)
            HStack {
                MainView(editorViewModel: viewModel, machineViewModel: machineViewModel, type: $viewModel.mainView)
                FocusedAttributesView(machine: machineViewModel.machine.asBinding, viewType: $viewModel.focusedView)
            }
        }
    }
}
