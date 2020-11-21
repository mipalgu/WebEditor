//
//  EditorView.swift
//  
//
//  Created by Morgan McColl on 20/11/20.
//

#if canImport(TokamakShim)
import TokamakShim
#else
import SwiftUI
#endif
import Machines
import Attributes

public struct EditorView: View {
    
    @ObservedObject var viewModel: EditorViewModel
    
    @EnvironmentObject var config: Config
    
    public init(viewModel: EditorViewModel) {
        self.viewModel = viewModel
    }
    
    public var body: some View {
        HStack {
            MainView(type: $viewModel.mainView)
            FocusedAttributesView(viewType: $viewModel.focusedView)
        }
    }
}
