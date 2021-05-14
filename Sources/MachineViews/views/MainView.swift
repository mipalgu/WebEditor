//
//  MainView.swift
//  
//
//  Created by Morgan McColl on 21/11/20.
//

import TokamakShim

import Machines
import Attributes
import Utilities

public struct MainView: View {
    
    @StateObject var viewModel: MainViewModel
    
    @EnvironmentObject var config: Config
    
    public init(arrangement: Arrangement) {
        self.init(viewModel: MainViewModel(root: .arrangement(ArrangementViewModel(arrangement: arrangement))))
    }
    
    public init(machine: Machine) {
        self.init(viewModel: MainViewModel(root: .machine(MachineViewModel(machine: machine))))
    }
    
    private init(viewModel: MainViewModel) {
        self._viewModel = StateObject(wrappedValue: viewModel)
    }

    public var body: some View {
        HStack {
            DependenciesView(root: viewModel.root, viewModel: viewModel.dependenciesViewModel, focus: $viewModel.focus)
            viewModel.subView
        }.navigationTitle(viewModel.focus.path)
    }
    
}

struct MainView_Previews: PreviewProvider {
    
    struct Preview: View {
        
        let config = Config()
        
        var body: some View {
            MainView(machine: Machine.initialSwiftMachine()).environmentObject(config)
        }
        
    }
    
    static var previews: some View {
        VStack {
            Preview()
        }
    }
}

