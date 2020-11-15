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
    
    @ObservedObject var viewModel: StateViewModel
    
    var body: some View {
        if viewModel.expanded {
            return AnyView(StateExpandedView(viewModel: viewModel))
        }
        return AnyView(StateCollapsedView(viewModel: viewModel))
    }
}
