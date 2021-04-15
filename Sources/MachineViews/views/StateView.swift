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

struct StateView: View {
    
    @ObservedObject var editorViewModel: EditorViewModel
    
    @StateObject var viewModel: StateViewModel
    
    @Binding var creatingTransitions: Bool
    
    @State var collapsedActions: [String: Bool] = [:]
    
    init(editorViewModel: EditorViewModel, viewModel: StateViewModel, creatingTransitions: Binding<Bool>) {
        self.editorViewModel = editorViewModel
        self._viewModel = StateObject(wrappedValue: viewModel)
        self._creatingTransitions = creatingTransitions
    }
    
    var body: some View {
        if viewModel.expanded {
            StateExpandedView(root: viewModel.$machine.asBinding, path: viewModel.path, collapsedActions: $collapsedActions)
            //return AnyView(StateExpandedView(editorViewModel: editorViewModel, viewModel: viewModel, creatingTransitions: $creatingTransitions)).clipped()
        } else {
            StateCollapsedView(editorViewModel: editorViewModel, viewModel: viewModel, creatingTransitions: $creatingTransitions).clipped()
        }
    }
}
