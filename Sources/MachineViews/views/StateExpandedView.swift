//
//  StateExpandedView.swift
//  
//
//  Created by Morgan McColl on 15/11/20.
//

#if canImport(TokamakShim)
import TokamakShim
#else
import SwiftUI
#endif
import Machines
import Attributes

struct StateExpandedView: View {
    
    @ObservedObject var viewModel: StateViewModel
    
    @EnvironmentObject var config: Config
    
    var body: some View {
        VStack {
            ZStack {
                RoundedRectangle(cornerRadius: 20.0)
                    .strokeBorder(config.borderColour, lineWidth: 3.0, antialiased: true)
                    .background(RoundedRectangle(cornerRadius: 20.0).foregroundColor(config.stateColour))
                    .frame(width: viewModel.width, height: viewModel.height)
                    .clipped()
                    .shadow(color: config.shadowColour, radius: 10, x: 0, y: 10)
                VStack {
                    LineView(machine: $viewModel.machine, path: viewModel.path.name, label: viewModel.name)
                        .multilineTextAlignment(.center)
                        .font(.title2)
                        .background(config.fieldColor)
                        .frame(minWidth: viewModel.elementMinWidth, maxWidth: viewModel.elementMaxWidth, minHeight: viewModel.minTitleHeight)
                        .clipped()
                    ForEach(Array(viewModel.actions), id: \.0) { (action, _) in
                        CodeView(machine: $viewModel.machine, path: viewModel.path.actions[action].wrappedValue, language: .swift) { () -> AnyView in
                            if viewModel.isEmpty(forAction: action) {
                                return AnyView(Text(action.capitalized + ":")
                                    .font(.headline)
                                    .underline()
                                    .italic()
                                    .foregroundColor(config.stateTextColour))
                            } else {
                                return AnyView(Text(action.capitalized + ":")
                                    .font(.headline)
                                    .underline()
                                    .foregroundColor(config.stateTextColour))
                            }
                        }.frame(
                            minWidth: viewModel.elementMinWidth,
                            maxWidth: viewModel.elementMaxWidth,
                            minHeight: viewModel.minActionHeight,
                            maxHeight: viewModel.maxActionHeight
                        )
                    }
                }
                .padding(.bottom, viewModel.bottomPadding)
                .padding(.top, viewModel.topPadding)
                .frame(minHeight: viewModel.elementMinHeight, maxHeight: viewModel.elementMaxHeight)
            }
        }.onChange(of: viewModel.isEmpty, perform: { print("change: \($0)") })
    }
}
