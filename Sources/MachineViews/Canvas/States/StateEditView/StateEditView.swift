//
//  SwiftUIView.swift
//  
//
//  Created by Morgan McColl on 14/11/20.
//

import TokamakShim

import MetaMachines
import Attributes
import Utilities
import AttributeViews

struct StateEditView: View {
    
    @ObservedObject var viewModel: StateViewModel
    
    @EnvironmentObject var config: Config
    
    var body: some View {
        GeometryReader { geometry in
            ScrollView {
                VStack(alignment: .leading) {
                    LineView(viewModel: viewModel.nameViewModel)
                        .multilineTextAlignment(.center)
                        .font(config.fontTitle2)
                        .background(config.fieldColor)
                        .foregroundColor(config.textColor)
                    ForEach(viewModel.actions, id: \.self) { action in
                        StateEditActionView(viewModel: viewModel.viewModel(forAction: action))
                            .frame(minHeight: max(geometry.size.height / CGFloat(viewModel.actions.count) - 25, 50))
                    }
                }.padding(10)
            }.frame(height: geometry.size.height)
        }
    }
}

//struct StateEditView_Previews: PreviewProvider {
//    
//    struct Preview: View {
//        
//        @State var machine: MetaMachine = MetaMachine.initialSwiftMachine()
//        
//        let path = Machine.path.states[0]
//        
//        let config = Config()
//        
//        var body: some View {
//            StateEditView(titleViewModel: StateTitleViewModel(machine: $machine, path: machine.path.states[0].name, cache: ViewCache(machine: $machine)), actionViewModels: machine.states[0].actions.indices.map {
//                ActionViewModel(machine: $machine, path: machine.path.states[0].actions[$0])
//            }).environmentObject(config)
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
