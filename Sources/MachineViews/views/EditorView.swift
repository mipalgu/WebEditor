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
        ZStack {
            HStack {
                GeometryReader{ (reader: GeometryProxy) in
                    MainView(editorViewModel: viewModel, machineViewModel: machineViewModel, type: $viewModel.mainView)
                        .position(CGPoint(x: viewModel.leftDividerLocation + viewModel.getMainViewWidth(width: reader.size.width) / 2.0, y: reader.size.height / 2.0))
                        .frame(width: viewModel.getMainViewWidth(width: reader.size.width))
                    FocusedAttributesView(machine: machineViewModel.$machine, viewType: $viewModel.focusedView, label: "Attributes", collapsed: Binding(get: { viewModel.rightPaneCollapsed }, set: { viewModel.rightPaneCollapsed = $0 }), collapseLeft: false, buttonSize: 20.0, buttonWidth: viewModel.buttonWidth, buttonHeight: viewModel.buttonWidth)
                        .frame(width: viewModel.rightPaneWidth(width: reader.size.width))
                        .position(CGPoint(x: viewModel.rightPaneLocation(width: reader.size.width), y: reader.size.height / 2.0))
                }
            }
            .frame(minWidth: viewModel.editorMinWidth)
            DialogueView(machineViewModel: machineViewModel, editorViewModel: viewModel)
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
