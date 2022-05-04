//
//  MainView.swift
//  
//
//  Created by Morgan McColl on 21/11/20.
//

import TokamakShim

import MetaMachines
import Attributes
import Utilities
import GUUI

public struct MainView: View {
    
    @StateObject var viewModel: MainViewModel
    
    var config: Config = Config()
    
//    public init(arrangementRef: ArrangementRef) {
//        self.init(viewModel: MainViewModel(root: .arrangement(ArrangementViewModel(arrangementRef: arrangementRef))))
//    }
    
    public init(machineRef: Ref<GUIMachine>) {
        self.init(viewModel: MainViewModel(root: .machine(MachineViewModel(machineRef: machineRef))))
    }
    
    private init(viewModel: MainViewModel) {
        self._viewModel = StateObject(wrappedValue: viewModel)
    }

    public var body: some View {
        HStack {
            //DependenciesView(root: viewModel.root, viewModel: viewModel.dependenciesViewModel, focus: $viewModel.focus)
            viewModel.subView.environmentObject(config)
        }.navigationTitle(viewModel.focus.pretty)
    }
    
}

struct MainView_Previews: PreviewProvider {
    
    struct Preview: View {
        
        var body: some View {
            MainView(
                machineRef: Ref(
                    copying: GUIMachine(
                        machine: MetaMachine.initialSwiftMachine,
                        layout: nil
                    )
                )
            )
        }
        
    }
    
    static var previews: some View {
        VStack {
            Preview()
        }
    }
}

