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
        VStack {
            LineView(machine: viewModel.$machine.asBinding, path: viewModel.path.name, label: viewModel.name)
                .multilineTextAlignment(.center)
                .font(config.fontTitle2)
                .background(config.fieldColor)
                .foregroundColor(config.textColor)
                .frame(minWidth: viewModel.minEditWidth, alignment: .center)
            ForEach(Array(viewModel.actions.enumerated()), id: \.0) { (index, action) in
                CodeView(machine: viewModel.$machine.asBinding, path: viewModel.path.actions[index].implementation, language: .swift) { () -> AnyView in
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
                .padding(.top, 20)
                .frame(
                    minWidth: viewModel.minEditWidth
                )
                .scaledToFit()
            }
        }
        .padding(10)
        //.frame(maxHeight: .infinity)
            /*Divider()
                .border(Color.black.opacity(0.6), width: 1)
            AttributeGroupsView(machine: $viewModel.machine, path: viewModel.path.attributes, label: "State Attributes")
                .frame(minWidth: viewModel.minDetailsWidth, maxWidth: viewModel.maxDetailsWidth)*/
    }
}
