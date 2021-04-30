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

import Machines

struct StateEditActionView_Previews: PreviewProvider {
    
    struct Preview: View {
        
        @State var machine: Machine = Machine.initialSwiftMachine()
        
        let config: Config = Config()
        
        var collapsed: Bool
        
        var body: some View {
            StateEditActionView(
                viewModel: ActionViewModel(
                    machine: $machine,
                    path: machine.path.states[0].actions[0],
                    action: $machine.states[0].actions[0],
                    notifier: nil,
                    collapsed: collapsed
                )
            ).environmentObject(config)
        }
        
    }
    
    static var previews: some View {
        VStack {
            Preview(collapsed: true)
            Preview(collapsed: false)
        }
    }
}
