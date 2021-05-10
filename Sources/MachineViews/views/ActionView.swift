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
        VStack {
            Text(viewModel.implementation)
            CodeViewWithDropDown(
                root: $viewModel.machine,
                path: viewModel.path.implementation,
                label: viewModel.name,
                language: viewModel.language,
                expanded: $viewModel.expanded
            )
        }
    }
}

//struct SwiftUIView_Previews: PreviewProvider {
//    static var previews: some View {
//        SwiftUIView()
//    }
//}

//import Attributes
//import Machines
//
//struct ActionView_Previews: PreviewProvider {
//    
//    struct Preview: View {
//        
//        @State var machine: Machine = Machine.initialSwiftMachine()
//        
//        var body: some View {
//            SubView(machine: $machine, path: Machine.path.states[0].actions[0])
//        }
//        
//    }
//    
//    struct SubView: View {
//        
//        @StateObject var viewModel: ActionViewModel
//        
//        init(machine: Binding<Machine>, path: Attributes.Path<Machine, Action>) {
//            self._viewModel = StateObject(wrappedValue: ActionViewModel(machine: machine, path: path))
//        }
//        
//        var body: some View {
//            VStack {
//                TextField("Something", text: .constant(""))
//                Button("redraw") {
//                    viewModel.objectWillChange.send()
//                }
//                ActionView(action: viewModel)
//            }
//        }
//        
//    }
//    
//    static var previews: some View {
//        VStack {
//            Preview()
//        }
//    }
//}
