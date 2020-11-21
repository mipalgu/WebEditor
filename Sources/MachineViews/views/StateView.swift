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

public struct StateView: View {
    
    @ObservedObject var editorViewModel: EditorViewModel
    
    @StateObject var viewModel: StateViewModel
    
    public init(editorViewModel: EditorViewModel, viewModel: StateViewModel) {
        self.editorViewModel = editorViewModel
        self._viewModel = StateObject(wrappedValue: viewModel)
    }
    
    public var body: some View {
        if viewModel.expanded {
            return AnyView(StateExpandedView(editorViewModel: editorViewModel, viewModel: viewModel))
        }
        return AnyView(StateCollapsedView(editorViewModel: editorViewModel, viewModel: viewModel))
    }
}
