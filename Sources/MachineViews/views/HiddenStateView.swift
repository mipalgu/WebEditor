//
//  SwiftUIView.swift
//  
//
//  Created by Morgan McColl on 26/11/20.
//

#if canImport(TokamakShim)
import TokamakShim
#else
import SwiftUI
#endif

import Machines
import Attributes
import Utilities

struct HiddenStateView: View {
    
    @ObservedObject var viewModel: StateViewModel
    
    @ObservedObject var editorViewModel: EditorViewModel
    
    @ObservedObject var machineViewModel: MachineViewModel
    
    @Binding var creatingTransitions: Bool
    
    var parentWidth: CGFloat
    
    var parentHeight: CGFloat
    
    @EnvironmentObject var config: Config
    
    var point: Binding<CGPoint> {
        Binding(get: { () -> CGPoint in viewModel.location }, set: {(_) -> Void in return})
    }
    
    var label: Binding<String> {
        Binding(get: { () -> String in viewModel.name }, set: {(_) -> Void in return})
    }
    
    var body: some View {
        if !viewModel.isHidden(frameWidth: parentWidth, frameHeight: parentHeight) {
            StateView(machine: $viewModel.machine, path: viewModel.path)
                .contextMenu {
                    Button(action: {
                        machineViewModel.deleteState(stateViewModel: viewModel)
                    }) {
                        Text("Delete")
                            .font(config.fontBody)
                    }
                    .keyboardShortcut(.delete)
                }
                .coordinateSpace(name: "MAIN_VIEW")
        } else {
            if viewModel.highlighted {
                BoundedLabelView(pointOffScreen: point, label: label, frameWidth: parentWidth, frameHeight: parentHeight)
                    .coordinateSpace(name: "MAIN_VIEW")
                    .foregroundColor(config.highlightColour)
            } else {
                BoundedLabelView(pointOffScreen: point, label: label, frameWidth: parentWidth, frameHeight: parentHeight)
                    .coordinateSpace(name: "MAIN_VIEW")
            }
        }
    }
}
