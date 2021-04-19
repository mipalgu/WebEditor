//
//  StateCollapsedview.swift
//  
//
//  Created by Morgan McColl on 15/11/20.
//

#if canImport(TokamakShim)
import TokamakShim
#else
import SwiftUI
#endif

import Utilities

struct StateCollapsedView<TitleView: View>: View {
    
    let titleView: () -> TitleView
    
    @EnvironmentObject var config: Config
    
    var body: some View {
        ZStack {
            config.stateColour
            VStack {
                titleView()
            }.padding(15)
        }.clipShape(Ellipse())
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
                StateTitleView(machine: $machine, path: Machine.path.states[0].name, expanded: $expanded)
            }.environmentObject(config)
        }
        
    }
    
    static var previews: some View {
        VStack {
            Preview()
        }
    }
}
