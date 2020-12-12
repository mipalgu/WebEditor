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
import Utilities

struct StateCollapsedView: View {
    
    @ObservedObject var editorViewModel: EditorViewModel
    
    @ObservedObject var viewModel: StateViewModel
    
    @Binding var creatingTransitions: Bool
    
    @EnvironmentObject var config: Config
    
    var createTransitionMode: Bool {
        editorViewModel.machine.createTransitionMode
    }
    
    var body: some View {
        GeometryReader { reader in
        Ellipse()
            .strokeBorder(viewModel.highlighted ? config.highlightColour : config.borderColour, lineWidth: 2.0, antialiased: true)
            .background(Ellipse().foregroundColor(config.stateColour).background(KeyEventHandling(keyDownCallback: {
                print("Key press!")
                print("Event: \($0)")
                if $0.keyCode == 59 {
                    print("Control Pressed!")
                    self.creatingTransitions = true
                }
            }, keyUpCallback: {
                if $0.keyCode == 59 {
                    self.creatingTransitions = false
                }
            })))
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
                            .padding(.leading, viewModel.buttonDimensions)
                            .frame(maxWidth: viewModel.collapsedWidth, maxHeight: viewModel.collapsedHeight)
                            .clipped()
                    }
                    Button(action: { viewModel.toggleExpand(frameWidth: reader.size.width, frameHeight: reader.size.height, externalTransitions: editorViewModel.machine.getExternalTransitionsForState(state: viewModel)) }) {
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
                editorViewModel.changeMainView(stateIndex: viewModel.stateIndex)
                editorViewModel.changeFocus(stateIndex: viewModel.stateIndex)
            }
            .onTapGesture(count: 1) {
                editorViewModel.machine.removeHighlights()
                viewModel.highlighted = true
                editorViewModel.changeFocus(stateIndex: viewModel.stateIndex)
            }
            .gesture(DragGesture(minimumDistance: 0, coordinateSpace: .named("MAIN_VIEW")).onChanged {
                if editorViewModel.machine.finishedDrag {
                    return
                }
                if viewModel.isDragging && creatingTransitions {
                    viewModel.finishMoveSelf(
                        gesture: $0,
                        frameWidth: reader.size.width,
                        frameHeight: reader.size.height,
                        collapsed: true,
                        externalTransitions: editorViewModel.machine.getExternalTransitionsForState(state: viewModel)
                    )
                    editorViewModel.machine.finishedDrag = true
                    return
                }
                if creatingTransitions {
                    self.editorViewModel.machine.startCreatingTransition(gesture: $0, sourceViewModel: viewModel)
                    return
                }
                if self.editorViewModel.machine.creatingTransition {
                    self.editorViewModel.machine.finishCreatingTransition(gesture: $0, sourceViewModel: viewModel)
                    self.editorViewModel.machine.finishedDrag = true
                    return
                }
                self.viewModel.moveSelf(
                    gesture: $0,
                    frameWidth: reader.size.width,
                    frameHeight: reader.size.height,
                    collapsed: true,
                    externalTransitions: editorViewModel.machine.getExternalTransitionsForState(state: viewModel)
                )
            }.onEnded {
                if creatingTransitions || self.editorViewModel.machine.creatingTransition {
                    self.editorViewModel.machine.finishCreatingTransition(gesture: $0, sourceViewModel: viewModel)
                    editorViewModel.machine.finishedDrag = false
                    return
                }
                self.viewModel.finishMoveSelf(
                    gesture: $0,
                    frameWidth: reader.size.width,
                    frameHeight: reader.size.height,
                    collapsed: true,
                    externalTransitions: editorViewModel.machine.getExternalTransitionsForState(state: viewModel)
                )
                editorViewModel.machine.finishedDrag = false
            })
        }
    }
}
