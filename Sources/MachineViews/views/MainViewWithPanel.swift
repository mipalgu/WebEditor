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
    
    var width: CGFloat
    
    var height: CGFloat
    
    @EnvironmentObject var config: Config
    
    var body: some View {
        HStack {
            MainView(viewModel: viewModel, type: viewModel.mainViewBinding)
                .frame(width: viewModel.getMainViewWidth(width: width))
            DividerView(
                viewModel: viewModel.dividerViewModel,
                parentWidth: width,
                parentHeight: height
            )
                .coordinateSpace(name: "MAIN_VIEW")
                .position(viewModel.getDividerLocation(width: width, height: height))
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
                .frame(width: viewModel.paneWidth(width: width))
                .coordinateSpace(name: "MAIN_VIEW")
                .position(viewModel.paneLocation(width: width, height: height))
        }
    }
}
