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
        CodeView(
            root: $viewModel.machine,
            path: viewModel.path.implementation,
            label: viewModel.name,
            language: viewModel.language
        )
    }
}

import Machines

//struct StateEditActionView_Previews: PreviewProvider {
//    
//    struct Preview: View {
//        
//        @State var machine: Machine = Machine.initialSwiftMachine()
//        
//        let config: Config = Config()
//        
//        var expanded: Bool
//        
//        var body: some View {
//            StateEditActionView(
//                viewModel: ActionViewModel(
//                    machine: $machine,
//                    path: machine.path.states[0].actions[0],
//                    notifier: nil,
//                    expanded: expanded
//                )
//            ).environmentObject(config)
//        }
//        
//    }
//    
//    static var previews: some View {
//        VStack {
//            Preview(expanded: false)
//            Preview(expanded: true)
//        }
//    }
//}
