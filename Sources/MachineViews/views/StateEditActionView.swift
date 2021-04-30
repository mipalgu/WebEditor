//
//  StateEditActionView.swift
//  
//
//  Created by Morgan McColl on 30/4/21.
//

import TokamakShim
import AttributeViews
import Utilities

struct StateEditActionView: View {
    
    @ObservedObject var viewModel: ActionViewModel
    
    @EnvironmentObject var config: Config
    
    var body: some View {
        CodeView<Config, Text>(
            value: $viewModel.implementation,
            errors: $viewModel.errors,
            label: viewModel.name,
            language: viewModel.language
        )
    }
}

//struct SwiftUIView_Previews: PreviewProvider {
//    static var previews: some View {
//        SwiftUIView()
//    }
//}
