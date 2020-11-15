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
        HStack {
            VStack {
                LineView(machine: $viewModel.machine, path: viewModel.path.name, label: viewModel.name)
                    .multilineTextAlignment(.center)
                    .font(.title2)
                    .background(config.fieldColor)
                    .foregroundColor(config.textColor)
                    .frame(minWidth: viewModel.minEditWidth, alignment: .center)
                ForEach(viewModel.actions, id: \.0) { (key, value) in
                    CodeView(machine: $viewModel.machine, path: viewModel.path.actions[key].wrappedValue, language: .swift) { () -> AnyView in
                        if viewModel.isEmpty(forAction: key) {
                            return AnyView(
                                Text(key + ":").font(.headline).underline().italic().foregroundColor(config.stateTextColour)
                            )
                        } else {
                            return AnyView(
                                Text(key + ":").font(.headline).underline().foregroundColor(config.stateTextColour)
                            )
                        }
                    }.frame(
                        minWidth: viewModel.minEditWidth,
                        minHeight: viewModel.minActionHeight
                    )
                }
            }
            //.scaledToFit()
            .padding(.horizontal, 10)
            Divider()
                .border(Color.black.opacity(0.6), width: 1)
            AttributeGroupsView(machine: $viewModel.machine, path: viewModel.path.attributes, label: "State Attributes")
                .frame(minWidth: viewModel.minDetailsWidth, maxWidth: viewModel.maxDetailsWidth)
        }
        .padding(20)
    }
}
