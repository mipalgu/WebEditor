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
    
    var subView: AnyView {
        switch viewModel.root {
        case .arrangement(let arrangementViewModel):
            if viewModel.focus == arrangementViewModel.arrangement.filePath {
                return AnyView(ArrangementView(viewModel: arrangementViewModel) {
                    DependenciesView(root: viewModel.root, viewModel: viewModel.dependenciesViewModel, focus: $viewModel.focus)
                })
            }
            fallthrough
        default:
            guard let machineViewModel = viewModel.viewModel(for: viewModel.focus) else {
                return AnyView(EmptyView())
            }
            return AnyView(MachineView(viewModel: machineViewModel) {
                DependenciesView(root: viewModel.root, viewModel: viewModel.dependenciesViewModel, focus: $viewModel.focus)
            })
        }
    }

    public var body: some View {
        subView
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

