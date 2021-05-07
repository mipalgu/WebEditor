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
    
    @State var dependenciesWidth: CGFloat = 200
    
    public init(arrangement: Arrangement) {
        self.init(viewModel: MainViewModel(root: .arrangement(ArrangementViewModel(arrangement: arrangement))))
    }
    
    public init(machine: Machine) {
        self.init(viewModel: MainViewModel(root: .machine(MachineViewModel(machine: machine))))
    }
    
    private init(viewModel: MainViewModel) {
        self._viewModel = StateObject(wrappedValue: viewModel)
    }
    
    @EnvironmentObject var config: Config
    
    @StateObject var viewModel: MainViewModel

    public var body: some View {
        VStack(alignment: .leading) {
            HStack {
                DependenciesView(root: viewModel.root, viewModel: viewModel.dependenciesViewModel, focus: $viewModel.focus)
                switch viewModel.root {
                case .arrangement(let arrangementViewModel):
                    if viewModel.focus == arrangementViewModel.arrangement.filePath {
                        ArrangementView(viewModel: arrangementViewModel)
                    } else {
                        MachineView(viewModel: viewModel.viewModel(for: viewModel.focus)!)
                    }
                case .machine:
                    MachineView(viewModel: viewModel.viewModel(for: viewModel.focus)!)
                }
            }
        }
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

