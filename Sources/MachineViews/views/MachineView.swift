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
        ForEach(viewModel.states, id: \.name) {
            StateView(editorViewModel: editorViewModel, viewModel: $0)
                .coordinateSpace(name: "MAIN_VIEW")
                .position($0.location)
        }
    }
}

