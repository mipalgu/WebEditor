//
//  StateView.swift
//  
//
//  Created by Morgan McColl on 15/11/20.
//

import TokamakShim

import MetaMachines
import Attributes
import AttributeViews
import Utilities
import GUUI

struct StateView: View {
    
    @ObservedObject var viewModel: StateViewModel

    let focused: Bool
    
    init(viewModel: StateViewModel, focused: Bool = false) {
        self.viewModel = viewModel
        self.focused = focused
    }
    
    @EnvironmentObject var config: Config
    
    var body: some View {
        if viewModel.expanded {
            StateExpandedView(viewModel: viewModel.actionsViewModel, focused: focused) {
                StateTitleView(viewModel: viewModel, editable: true)
            }
        } else {
            StateCollapsedView(focused: focused) {
                StateTitleView(viewModel: viewModel, editable: focused)
            }
        }
    }
}

struct StateView_Previews: PreviewProvider {
    
    struct Expanded_Preview: View {
        
        @StateObject var viewModel = StateViewModel(machine: Ref(copying: MetaMachine.initialSwiftMachine), index: 0)
        
        
        @State var expanded: Bool = true
        
        let config = Config()
        
        var body: some View {
            StateView(viewModel: viewModel).environmentObject(config)
        }
        
    }
    
    struct Collapsed_Preview: View {
        
        @StateObject var viewModel = StateViewModel(machine: Ref(copying: MetaMachine.initialSwiftMachine), index: 0)
        
        @State var expanded: Bool = false
        
        let config = Config()
        
        var body: some View {
            StateView(viewModel: viewModel).environmentObject(config)
        }
        
    }
    
    static var previews: some View {
        VStack {
            Collapsed_Preview().frame(width: 200, height: 100)
            Expanded_Preview().frame(minHeight: 400)
        }
    }
}
