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
                    HStack {
                        LineView(machine: $viewModel.machine, path: viewModel.path.name, label: viewModel.name)
                            .multilineTextAlignment(.center)
                            .font(config.fontTitle2)
                            .background(config.fieldColor)
                            .padding(.leading, viewModel.buttonDimensions)
                            .frame(
                                minWidth: viewModel.minTitleWidth - viewModel.buttonDimensions,
                                maxWidth: viewModel.maxTitleWidth - viewModel.buttonDimensions,
                                minHeight: viewModel.minTitleHeight,
                                maxHeight: viewModel.maxTitleHeight
                            )
                            .clipped()
                        Button(action: { viewModel.toggleExpand() }) {
                            Image(systemName: "arrowtriangle.down.fill")
                                .font(.system(size: viewModel.buttonSize, weight: .regular))
                                .frame(width: viewModel.buttonDimensions, height: viewModel.buttonDimensions)
                        }.buttonStyle(PlainButtonStyle())
                    }
                    ScrollView {
                        ForEach(Array(viewModel.actions.map(\.name).enumerated()), id: \.0) { (index, action) in
                            CodeView(machine: $viewModel.machine, path: viewModel.path.actions[index].implementation, language: .swift) { () -> AnyView in
                                if viewModel.isEmpty(forAction: action) {
                                    return AnyView(
                                        Text(action + ":").font(.headline).underline().italic().foregroundColor(config.stateTextColour)
                                    )
                                } else {
                                    return AnyView(
                                        Text(action + ":").font(.headline).underline().foregroundColor(config.stateTextColour)
                                    )
                                }
                            }.frame(
                                minWidth: viewModel.elementMinWidth,
                                maxWidth: viewModel.elementMaxWidth
                            )
                        }
                    }.frame(maxWidth: viewModel.elementMaxWidth, maxHeight: viewModel.actionsMaxHeight)
                }
                .padding(.bottom, viewModel.bottomPadding)
                .padding(.top, viewModel.topPadding)
                .frame(minHeight: viewModel.elementMinHeight, maxHeight: viewModel.elementMaxHeight)
            }
        }.onChange(of: viewModel.isEmpty, perform: { print("change: \($0)") })
    }
}
