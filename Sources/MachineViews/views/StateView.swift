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
    
    @ObservedObject var viewModel: StateViewModel
    
    public init(viewModel: StateViewModel) {
        self.viewModel = viewModel
    }
    
    public var body: some View {
        if viewModel.expanded {
            return AnyView(StateExpandedView(viewModel: viewModel))
        }
        return AnyView(StateCollapsedView(viewModel: viewModel))
    }
}
