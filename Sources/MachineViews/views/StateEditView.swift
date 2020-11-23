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

public struct StateEditView: View {
    
    @ObservedObject var viewModel: StateViewModel
    
    @EnvironmentObject var config: Config
    
    public init(viewModel: StateViewModel) {
        self.viewModel = viewModel
    }
    
    public var body: some View {
        GeometryReader { reader in
            ScrollView {
                VStack {
                    LineView(machine: viewModel.$machine, path: viewModel.path.name, label: viewModel.name)
                        .multilineTextAlignment(.center)
                        .font(config.fontTitle2)
                        .background(config.fieldColor)
                        .foregroundColor(config.textColor)
                        .frame(minWidth: viewModel.minEditWidth, maxHeight: viewModel.maxTitleHeight, alignment: .center)
                    ForEach(Array(viewModel.actions.enumerated()), id: \.0) { (index, action) in
                        CodeView(machine: viewModel.$machine, path: viewModel.path.actions[index].implementation, language: .swift) { () -> AnyView in
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
                        .frame(height: viewModel.getHeightOfActionForEdit(height: reader.size.height))
                        
                    }
                }
            }
            .padding(viewModel.editPadding)
        }
    }
}
