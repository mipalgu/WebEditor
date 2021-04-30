//
//  StateCollapsedview.swift
//  
//
//  Created by Morgan McColl on 15/11/20.
//

import TokamakShim

import Utilities

struct StateCollapsedView<TitleView: View>: View {
    
    var focused: Bool = false
    
    let titleView: () -> TitleView
    
    @EnvironmentObject var config: Config
    
    var body: some View {
        ZStack {
            config.stateColour
            VStack {
                titleView()
            }.padding(15)
        }.background(Ellipse().stroke()).clipShape(Ellipse())
        .overlay(
            Ellipse()
                .stroke(focused ? config.highlightColour : config.borderColour, lineWidth: 2)
        )
    }
    
}

import Machines
import AttributeViews

struct StateCollapsedView_Previews: PreviewProvider {
    
    struct Preview: View {
        
        @State var machine: Machine = Machine.initialSwiftMachine()
        
        @State var expanded: Bool = false
        
        let config = Config()
        
        var body: some View {
            StateCollapsedView {
                StateTitleView(viewModel: StateTitleViewModel(machine: $machine, path: machine.path.states[0].name), expanded: $expanded)
            }.environmentObject(config)
        }
        
    }
    
    static var previews: some View {
        VStack {
            Preview()
        }
    }
}
