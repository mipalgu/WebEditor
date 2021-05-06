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
//                switch viewModel.root {
//                case .arrangement:
//                    DependenciesView(
//                        focus: $viewModel.focus,
//                        name: .constant(viewModel.root.arrangement.name),
//                        url: $viewModel.root.arrangement.filePath,
//                        dependencies: $viewModel.root.arrangement.dependencies,
//                        machines: $machines,
//                        width: $dependenciesWidth
//                    )
//                case .machine:
//                    DependenciesView(
//                        focus: $viewModel.focus,
//                        name: .constant(viewModel.root.machine.name),
//                        url: $viewModel.root.machine.filePath,
//                        dependencies: $viewModel.root.machine.dependencies,
//                        machines: $machines,
//                        width: $dependenciesWidth
//                    )
//                }
                switch viewModel.root {
                case .arrangement(let arrangementViewModel):
                    if viewModel.focus == arrangementViewModel.arrangement.filePath {
                        ArrangementView(viewModel: arrangementViewModel, selection: viewModel.selection(for: viewModel.focus))
                    } else {
                        MachineView(viewModel: viewModel.viewModel(for: viewModel.focus)!, selection: viewModel.selection(for: viewModel.focus))
                    }
                case .machine:
                    MachineView(viewModel: viewModel.viewModel(for: viewModel.focus)!, selection: viewModel.selection(for: viewModel.focus))
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

