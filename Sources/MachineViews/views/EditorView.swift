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
            MenuView(machine: machineViewModel.$machine.asBinding)
                .background(config.stateColour)
            HStack {
                GeometryReader{ reader in
                    MainView(editorViewModel: viewModel, machineViewModel: machineViewModel, type: $viewModel.mainView)
                        .frame(width: viewModel.mainViewWidth)
                    Divider()
                        .frame(width: viewModel.dividerWidth, height: reader.size.height)
                        .background(config.borderColour)
                        .position(x: viewModel.rightDividerLocation, y: reader.size.height / 2.0)
                        .gesture(DragGesture(minimumDistance: 0.0)
                            .onChanged({ viewModel.dragRightDividor(width: reader.size.width, gesture: $0) })
                            .onEnded({ viewModel.finishDraggingRight(width: reader.size.width, gesture: $0) })
                        )
                    FocusedAttributesView(machine: machineViewModel.$machine.asBinding, viewType: $viewModel.focusedView)
                        .frame(width: viewModel.rightPaneWidth(width: reader.size.width))
                        .position(CGPoint(x: viewModel.rightPaneLocation(width: reader.size.width), y: reader.size.height / 2.0))
                }
            }
        }
    }
}
