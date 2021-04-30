//
//  ActionView.swift
//  
//
//  Created by Morgan McColl on 30/4/21.
//

import TokamakShim

struct ActionView: View {
    
    @ObservedObject var viewModel: ActionViewModel
    
    init(action: ActionViewModel) {
        self.viewModel = action
    }
    
    var body: some View {
        CodeViewWithDropDown(
            value: $viewModel.implementation,
            errors: $viewModel.errors,
            label: viewModel.name,
            language: viewModel.language,
            collapsed: $viewModel.collapsed
        )
    }
}

//struct SwiftUIView_Previews: PreviewProvider {
//    static var previews: some View {
//        SwiftUIView()
//    }
//}
