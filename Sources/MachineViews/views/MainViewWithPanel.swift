//
//  SwiftUIView.swift
//  
//
//  Created by Morgan McColl on 28/11/20.
//

#if canImport(TokamakShim)
import TokamakShim
#else
import SwiftUI
#endif
import Machines
import Attributes

struct MainViewWithPanel: View {
    
    @ObservedObject var viewModel: EditorViewModel
    
    @EnvironmentObject var config: Config
    
    var body: some View {
        GeometryReader { (geometry: GeometryProxy) in
            HStack {
                MainView(viewModel: viewModel, type: viewModel.mainViewBinding)
                    .frame(width: viewModel.getMainViewWidth(width: geometry.size.width))
                DividerView(
                    viewModel: viewModel.dividerViewModel,
                    parentWidth: geometry.size.width,
                    parentHeight: geometry.size.height
                )
                .coordinateSpace(name: "MAIN_VIEW")
                .position(viewModel.getDividerLocation(width: geometry.size.width, height: geometry.size.height))
                FocusedAttributesView(
                    machine: viewModel.machine.$machine,
                    viewType: viewModel.focusedViewBinding,
                    label: viewModel.panelLabel,
                    collapsed: viewModel.collapsedBinding,
                    collapseLeft: false,
                    buttonSize: viewModel.buttonSize,
                    buttonWidth: viewModel.buttonWidth,
                    buttonHeight: viewModel.buttonWidth
                )
                    .frame(width: viewModel.paneWidth(width: geometry.size.width))
                    .coordinateSpace(name: "MAIN_VIEW")
                    .position(viewModel.paneLocation(width: geometry.size.width, height: geometry.size.height))
            }
        }
    }
}
