//
//  SwiftUIView.swift
//  
//
//  Created by Morgan McColl on 14/11/20.
//

#if canImport(TokamakShim)
import TokamakShim
#else
import SwiftUI
#endif

import Machines
import Attributes
import Utilities
import AttributeViews

struct StateEditView: View {
    
    @ObservedObject var viewModel: StateViewModel
    
    @EnvironmentObject var config: Config
    
    init(viewModel: StateViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        GeometryReader { reader in
            ScrollView {
                VStack(alignment: .leading) {
                    LineView(value: viewModel.$machine[bindingTo: viewModel.path.name], label: viewModel.name)
                        .multilineTextAlignment(.center)
                        .font(config.fontTitle2)
                        .background(config.fieldColor)
                        .foregroundColor(config.textColor)
                        .frame(minWidth: min(viewModel.minEditWidth - 2.0 * viewModel.editPadding, reader.size.width - 2.0 * viewModel.editPadding), maxWidth: reader.size.width - 2.0 * viewModel.editPadding, maxHeight: viewModel.maxTitleHeight, alignment: .center)
                    ForEach(Array(viewModel.actions.enumerated()), id: \.0) { (index, action) in
                        CodeView(value: viewModel.$machine[bindingTo: viewModel.path.actions[index].implementation], language: .swift) { () -> AnyView in
                            if viewModel.isEmpty(forAction: action.name) {
                                return AnyView(
                                    Text(action.name + ":").font(config.fontHeading).underline().italic().foregroundColor(config.stateTextColour)
                                )
                            } else {
                                return AnyView(
                                    Text(action.name + ":").font(config.fontHeading).underline().foregroundColor(config.stateTextColour)
                                )
                            }
                        }
                        .padding(.top, viewModel.editActionPadding)
                        .padding(.horizontal, 0)
                        .frame(width: reader.size.width - 2.0 * viewModel.editPadding, height: viewModel.getHeightOfActionForEdit(height: reader.size.height))
                        
                    }
                }
            }
            .padding(viewModel.editPadding)
        }
    }
}
