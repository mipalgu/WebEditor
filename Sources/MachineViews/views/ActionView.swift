//
//  ActionView.swift
//  
//
//  Created by Morgan McColl on 30/4/21.
//

import TokamakShim
import AttributeViews
import Utilities

struct ActionView: View {
    
    @ObservedObject var viewModel: ActionViewModel
    
    init(action: ActionViewModel) {
        self._viewModel = ObservedObject(initialValue: action)
    }
    
    var body: some View {
        CodeViewWithDropDown(
            root: $viewModel.machine,
            path: viewModel.path.implementation,
            label: viewModel.name,
            language: viewModel.language,
            expanded: $viewModel.expanded
        )
    }
}

//struct SwiftUIView_Previews: PreviewProvider {
//    static var previews: some View {
//        SwiftUIView()
//    }
//}

import Attributes
import Machines

struct ActionView_Previews: PreviewProvider {

    struct Preview: View {

        @StateObject var viewModel: ActionViewModel = ActionViewModel(machine: Ref(copying: Machine.initialSwiftMachine()), stateIndex: 0, actionIndex: 0)

        var body: some View {
            ActionView(action: viewModel)
        }

    }

    static var previews: some View {
        VStack {
            Preview()
        }.padding(10)
    }
}
