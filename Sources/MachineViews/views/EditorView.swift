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
    
    var machineViewModel: MachineViewModel {
        viewModel.machine
    }
    
    @EnvironmentObject var config: Config
    
    public init(viewModel: EditorViewModel) {
        self.viewModel = viewModel
    }
    
    public var body: some View {
        ZStack {
            MainViewWithPanel(viewModel: viewModel)
            DialogueView(viewModel: viewModel)
                .padding(10)
                .background(
                    RoundedRectangle(cornerRadius: 20.0)
                        .background(config.backgroundColor)
                        .foregroundColor(config.backgroundColor)
                        .border(config.borderColour, width: 3.0)
                        .shadow(color: config.shadowColour, radius: 10, x: 0, y: 10)
                )
                .frame(minWidth: 400.0, maxWidth: 1000.0)
        }
    }
}
