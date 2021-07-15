//
//  ActionView.swift
//  
//
//  Created by Morgan McColl on 30/4/21.
//

import TokamakShim
import AttributeViews
import Utilities
import GUUI

struct ActionView: View {
    
    @ObservedObject var viewModel: ActionViewModel
    
    let height: CGFloat
    
    init(action: ActionViewModel, height: CGFloat) {
        self._viewModel = ObservedObject(initialValue: action)
        self.height = height
    }
    
    var body: some View {
        CodeViewWithDropDown(
            root: $viewModel.machine,
            path: viewModel.path.implementation,
            label: viewModel.name,
            language: viewModel.language,
            expanded: $viewModel.expanded,
            minHeight: height
        )
    }
}

//struct SwiftUIView_Previews: PreviewProvider {
//    static var previews: some View {
//        SwiftUIView()
//    }
//}

import Attributes
import MetaMachines

struct ActionView_Previews: PreviewProvider {

    struct Preview: View {

        @StateObject var viewModel: ActionViewModel = ActionViewModel(machine: Ref(copying: MetaMachine.initialSwiftMachine()), stateIndex: 0, actionIndex: 0)

        var body: some View {
            ActionView(action: viewModel, height: 100.0)
        }

    }

    static var previews: some View {
        VStack {
            Preview()
        }.padding(10)
    }
}
