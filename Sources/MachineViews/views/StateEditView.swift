//
//  SwiftUIView.swift
//  
//
//  Created by Morgan McColl on 14/11/20.
//

import TokamakShim

import Machines
import Attributes
import Utilities
import AttributeViews

struct StateEditView: View {
    
    var titleViewModel: StateTitleViewModel
    var actionViewModels: [ActionViewModel]
    
    @EnvironmentObject var config: Config
    
    var body: some View {
        GeometryReader { geometry in
            ScrollView {
                VStack(alignment: .leading) {
                    StateEditTitleView(viewModel: titleViewModel)
                    ForEach(actionViewModels, id: \.id) {
                        StateEditActionView(viewModel: $0)
                        .frame(minHeight: max(geometry.size.height / 3 - 25, 50))
                    }
                }.padding(10)
            }.frame(height: geometry.size.height)
        }
    }
}

struct StateEditView_Previews: PreviewProvider {
    
    struct Preview: View {
        
        @State var machine: Machine = Machine.initialSwiftMachine()
        
        let path = Machine.path.states[0]
        
        let config = Config()
        
        var body: some View {
            StateEditView(titleViewModel: StateTitleViewModel(machine: $machine, path: machine.path.states[0].name, cache: ViewCache(machine: $machine)), actionViewModels: machine.states[0].actions.indices.map {
                ActionViewModel(machine: $machine, path: machine.path.states[0].actions[$0])
            }).environmentObject(config)
        }
        
    }
    
    static var previews: some View {
        VStack {
            Preview()
        }
    }
}
