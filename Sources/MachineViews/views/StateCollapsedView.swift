//
//  StateCollapsedview.swift
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

struct StateCollapsedView: View {
    
    @ObservedObject var editorViewModel: EditorViewModel
    
    @ObservedObject var viewModel: StateViewModel
    
    @EnvironmentObject var config: Config
    
    var body: some View {
        Ellipse()
            .strokeBorder(viewModel.highlighted ? config.highlightColour : config.borderColour, lineWidth: 2.0, antialiased: true)
            .background(Ellipse().foregroundColor(config.stateColour))
            .padding(.bottom, 2)
            .frame(width: viewModel.collapsedWidth, height: viewModel.collapsedHeight)
            .clipped()
            .shadow(color: config.shadowColour, radius: 5, x: 0, y: 5)
            .overlay(
                HStack(spacing: 0) {
                    if viewModel.isEmpty {
                        Text(viewModel.name)
                            .italic()
                            .font(config.fontTitle2)
                            .foregroundColor(config.stateTextColour)
                            .padding(.leading, viewModel.buttonDimensions)
                            .frame(
                                maxWidth: viewModel.collapsedWidth - viewModel.buttonDimensions,
                                maxHeight: viewModel.collapsedHeight
                            )
                            .clipped()
                    } else {
                        Text(viewModel.name)
                            .font(config.fontTitle2)
                            .foregroundColor(config.stateTextColour)
                            .frame(maxWidth: viewModel.collapsedWidth, maxHeight: viewModel.collapsedHeight)
                            .clipped()
                    }
                    Button(action: { viewModel.toggleExpand() }) {
                        Image(systemName: "arrowtriangle.left.fill")
                            .font(.system(size: viewModel.buttonSize, weight: .regular))
                            .frame(width: viewModel.buttonDimensions, height: viewModel.buttonDimensions)
                    }.buttonStyle(PlainButtonStyle())
                }
                .background(
                    Ellipse()
                        .strokeBorder(viewModel.highlighted ? config.highlightColour : config.borderColour, lineWidth: 2.0, antialiased: true)
                        .frame(width: viewModel.collapsedWidth - 10.0, height: viewModel.collapsedHeight - 10.0)
                        .opacity(viewModel.isAccepting ? 1.0 : 0.0)
                )
            )
            .coordinateSpace(name: "MAIN_VIEW")
            .position(viewModel.location)
            .onTapGesture(count: 2) {
                editorViewModel.changeMainView(machine: viewModel.machineId, stateIndex: viewModel.stateIndex)
            }
            .onTapGesture(count: 1) {
                editorViewModel.machines.first { viewModel.machineName == $0.name }?.removeHighlights()
                viewModel.highlighted = true
                editorViewModel.changeFocus(machine: viewModel.machineId, stateIndex: viewModel.stateIndex)
            }
            .gesture(DragGesture(minimumDistance: 0, coordinateSpace: .named("MAIN_VIEW")).onChanged {
                self.viewModel.handleCollapsedDrag(gesture: $0)
            }.onEnded {
                self.viewModel.finishCollapsedDrag(gesture: $0)
            })
            
    }
}
