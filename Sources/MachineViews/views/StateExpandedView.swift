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
import Utilities
import AttributeViews

struct StateExpandedView: View {
    
    @ObservedObject var editorViewModel: EditorViewModel
    
    @ObservedObject var viewModel: StateViewModel
    
    @Binding var creatingTransitions: Bool
    
    @EnvironmentObject var config: Config
    
    var createTransitionMode: Bool {
        editorViewModel.machine.createTransitionMode
    }
    
    var body: some View {
        GeometryReader{ reader in
            VStack {
                RoundedRectangle(cornerRadius: 20.0)
                .strokeBorder(viewModel.highlighted ? config.highlightColour : config.borderColour, lineWidth: 3.0, antialiased: true)
                .background(RoundedRectangle(cornerRadius: 20.0).foregroundColor(config.stateColour))
                .frame(width: viewModel.width, height: viewModel.height)
                .clipped()
                .shadow(color: config.shadowColour, radius: 10, x: 0, y: 10)
                .overlay (
                    VStack {
                        HStack {
                            LineView(machine: viewModel.$machine, path: viewModel.path.name, label: viewModel.name)
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
                            Button(action: { viewModel.toggleExpand(frameWidth: reader.size.width, frameHeight: reader.size.height) }) {
                                Image(systemName: "arrowtriangle.down.fill")
                                    .font(.system(size: viewModel.buttonSize, weight: .regular))
                                    .frame(width: viewModel.buttonDimensions, height: viewModel.buttonDimensions)
                            }.buttonStyle(PlainButtonStyle())
                        }
                        ScrollView {
                            VStack {
                                ForEach(Array(viewModel.actions.map(\.name).enumerated()), id: \.0) { (index, action) in
                                    CodeViewWithDropDown(
                                        machine: viewModel.$machine.asBinding,
                                        path: viewModel.path.actions[index].implementation,
                                        language: .swift,
                                        collapsed: viewModel.createCollapsedBinding(forAction: action)
                                    ) {
                                        viewModel.createTitleView(forAction: action, color: config.stateTextColour)
                                    }.frame(
                                        minWidth: viewModel.elementMinWidth,
                                        maxWidth: viewModel.elementMaxWidth,
                                        minHeight: viewModel.getHeightOfAction(actionName: action)
                                    )
                                    .padding(.vertical, viewModel.actionPadding)
                                    .clipped()
                                }
                            }
                        }
                    }
                    .padding(.bottom, viewModel.bottomPadding)
                    .padding(.top, viewModel.topPadding)
                    .frame(minHeight: viewModel.elementMinHeight)
                    .background(
                        RoundedRectangle(cornerRadius: 20.0)
                        .strokeBorder(viewModel.highlighted ? config.highlightColour : config.borderColour, lineWidth: 3.0, antialiased: true)
                        .frame(width: viewModel.width - 10.0, height: viewModel.height - 10.0)
                        .opacity(viewModel.isAccepting ? 1.0 : 0.0)
                    )
                )
            }.onChange(of: viewModel.isEmpty, perform: { print("change: \($0)") })
            .coordinateSpace(name: "MAIN_VIEW")
            .position(viewModel.location)
            .onTapGesture(count: 2) {
                editorViewModel.changeMainView(stateIndex: viewModel.stateIndex)
                editorViewModel.changeFocus(stateIndex: viewModel.stateIndex)
            }
            .onTapGesture(count: 1) {
                editorViewModel.machine.removeHighlights()
                viewModel.highlighted = true
                editorViewModel.changeFocus(stateIndex: viewModel.stateIndex)
            }
            .gesture(DragGesture(minimumDistance: 0, coordinateSpace: .named("MAIN_VIEW"))
                .onChanged {
                    if creatingTransitions {
                        self.editorViewModel.machine.startCreatingTransition(gesture: $0, sourceViewModel: viewModel)
                        return
                    }
                    self.viewModel.moveSelf(gesture: $0, frameWidth: reader.size.width, frameHeight: reader.size.height)
                }.onEnded {
                    if creatingTransitions {
                        self.editorViewModel.machine.finishCreatingTransition(gesture: $0, sourceViewModel: viewModel)
                        return
                    }
                    self.viewModel.finishMoveSelf(gesture: $0, frameWidth: reader.size.width, frameHeight: reader.size.height)
                }
            )
    }
    }
}
