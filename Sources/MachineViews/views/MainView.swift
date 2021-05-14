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
    @State var sideBarCollapsed: Bool = false
    
    var subView: AnyView {
        switch viewModel.root {
        case .arrangement(let arrangementViewModel):
            if viewModel.focus == arrangementViewModel.arrangement.filePath {
                return AnyView(ArrangementView(viewModel: arrangementViewModel))
            }
            fallthrough
        default:
            guard let machineViewModel = viewModel.viewModel(for: viewModel.focus) else {
                return AnyView(EmptyView())
            }
            return AnyView(MachineView(viewModel: machineViewModel))
        }
    }

    public var body: some View {
        HStack {
            VStack {
                if !sideBarCollapsed {
                    DependenciesView(root: viewModel.root, viewModel: viewModel.dependenciesViewModel, focus: $viewModel.focus)
                }
            }.transition(.move(edge: .leading)).animation(.interactiveSpring())
            subView
        }.toolbar {
            ToolbarItem(placement: ToolbarItemPlacement.navigation) {
                HoverButton(action: {
                    sideBarCollapsed.toggle()
                }, label: {
                    Image(systemName: "sidebar.leading").font(.system(size: 16, weight: .regular))
                })
            }
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

