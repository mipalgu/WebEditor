//
//  StateView.swift
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
import AttributeViews
import Utilities

struct StateView: View {
    
    @ObservedObject var editorViewModel: EditorViewModel
    
    @StateObject var viewModel: StateViewModel
    
    @Binding var creatingTransitions: Bool
    
    @State var collapsedActions: [String: Bool] = [:]
    
    @State var expandedWidth: CGFloat = 300
    @State var expandedHeight: CGFloat = 200
    
    @State var collapsedWidth: CGFloat = 75
    @State var collapsedHeight: CGFloat = 100
    
    @EnvironmentObject var config: Config
    
    init(editorViewModel: EditorViewModel, viewModel: StateViewModel, creatingTransitions: Binding<Bool>) {
        self.editorViewModel = editorViewModel
        self._viewModel = StateObject(wrappedValue: viewModel)
        self._creatingTransitions = creatingTransitions
    }
    
    var body: some View {
        if viewModel.expanded {
            StateExpandedView(root: viewModel.$machine.asBinding, path: viewModel.path, collapsedActions: $collapsedActions) {
                StateTitleView(machine: viewModel.$machine.asBinding, path: viewModel.path.name, expanded: $viewModel.expanded)
            }.frame(width: max(expandedWidth, 75), height: max(expandedHeight, 100))
        } else {
            StateCollapsedView(editorViewModel: editorViewModel, viewModel: viewModel, creatingTransitions: $creatingTransitions)
        }
    }
}
