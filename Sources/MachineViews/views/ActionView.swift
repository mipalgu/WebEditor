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
    
    @Binding var machine: Machine
    
    @ObservedObject var viewModel: ActionViewModel
    
    init(action: ActionViewModel) {
        self._machine = action.machineBinding
        self.viewModel = action
    }
    
    var body: some View {
//        CodeViewWithDropDown(
//            value: $viewModel.implementation,
//            errors: $viewModel.errors,
//            label: viewModel.name,
//            language: viewModel.language,
//            collapsed: $viewModel.collapsed,
//            delayEdits: true
//        )
        CodeViewWithDropDown(
            root: $viewModel.machine,
            path: viewModel.path.implementation,
            label: viewModel.name,
            language: viewModel.language,
            expanded: $viewModel.expanded,
            notifier: viewModel
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
        
        @State var machine: Machine = Machine.initialSwiftMachine()
        
        var body: some View {
            SubView(machine: $machine, path: Machine.path.states[0].actions[0])
        }
        
    }
    
    struct SubView: View {
        
        @StateObject var viewModel: ActionViewModel
        
        init(machine: Binding<Machine>, path: Attributes.Path<Machine, Action>) {
            self._viewModel = StateObject(wrappedValue: ActionViewModel(machine: machine, path: path))
        }
        
        var body: some View {
            VStack {
                TextField("Something", text: .constant(""))
                Button("redraw") {
                    viewModel.objectWillChange.send()
                }
                ActionView(action: viewModel)
            }
        }
        
    }
    
    static var previews: some View {
        VStack {
            Preview()
        }
    }
}
