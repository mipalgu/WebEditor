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

struct StateEditView: View {
    
    @ObservedObject var viewModel: StateViewModel
    
    @EnvironmentObject var config: Config
    
    var body: some View {
        HStack {
            VStack {
                TextField(viewModel.name, text: Binding(get: { viewModel.name }, set: {
                    do {
                        try viewModel.machine.modify(attribute: viewModel.path.name, value: StateName($0))
                    } catch let e {
                        print("\(e)")
                    }
                }))
                .multilineTextAlignment(.center)
                .font(.title2)
                .background(config.fieldColor)
                .foregroundColor(config.textColor)
                .frame(width: CGFloat(config.width - viewModel.detailsWidth), height: CGFloat(viewModel.titleHeight), alignment: .center)
                ForEach(viewModel.actions, id: \.0) { (key, value) in
                    CodeView(machine: $viewModel.machine, path: viewModel.path.actions[key].wrappedValue, label: key, language: .swift)
                        .frame(
                            width: CGFloat(config.width - viewModel.detailsWidth),
                            height: CGFloat(viewModel.editActionHeight(frameHeight: config.height))
                        )
                        //.frame(height: reader.size.height / CGFloat(state.actions.count))
                }
            }
            .scaledToFit()
            .padding(.horizontal, 10)
            Divider()
                .border(Color.black.opacity(0.6), width: 1)
                .frame(height: CGFloat(config.height))
            AttributeGroupsView(machine: $viewModel.machine, path: viewModel.path.attributes, label: "State Attributes")
                .frame(width: CGFloat(viewModel.detailsWidth), height: CGFloat(config.height))
        }
        .padding(20)
    }
}
