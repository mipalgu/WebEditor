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
    
    enum Root: Equatable {
        
        var arrangement: Arrangement {
            get {
                switch self {
                case .arrangement(let arrangement):
                    return arrangement
                default:
                    fatalError("Attempting to fetch arrangment from \(self)")
                }
            } set {
                self = .arrangement(newValue)
            }
        }
        
        var machine: Machine {
            get {
                switch self {
                case .machine(let machine):
                    return machine
                default:
                    fatalError("Attempting to fetch machine from \(self)")
                }
            } set {
                self = .machine(newValue)
            }
        }
        
        case arrangement(Arrangement)
        case machine(Machine)
        
    }
    
    @State var focus: URL
    
    @State var viewModels: [URL: MachineViewModel] = [:]
    
    @State var machines: [URL: Machine] = [:]
    
    @State var root: Root
    
    public init(arrangement: Arrangement) {
        self._focus = State(initialValue: arrangement.filePath)
        self._root = State(initialValue: .arrangement(arrangement))
    }
    
    public init(machine: Machine) {
        self._focus = State(initialValue: machine.filePath)
        self._root = State(initialValue: .machine(machine))
        guard let plist = try? String(contentsOf: machine.filePath.appendingPathComponent("Layout.plist")) else {
            viewModels[machine.filePath] = MachineViewModel(machine: $root.machine)
            return
        }
        viewModels[machine.filePath] = MachineViewModel(machine: $root.machine, plist: plist)
    }
    
    @EnvironmentObject var config: Config
    
    @StateObject var viewModel: DependenciesViewModel = DependenciesViewModel()
    
    private func viewModel(from plist: String, with binding: Binding<Machine>) -> MachineViewModel {
        let newViewModel = MachineViewModel(machine: binding, plist: plist)
        viewModels[binding.wrappedValue.filePath] = newViewModel
        return newViewModel
    }
    
    private func viewModel(with binding: Binding<Machine>) -> MachineViewModel {
        let newViewModel = MachineViewModel(machine: binding)
        viewModels[binding.wrappedValue.filePath] = newViewModel
        return newViewModel
    }
    
    public var body: some View {
        VStack(alignment: .leading) {
            HStack {
                switch root {
                case .arrangement:
                    DependenciesView(
                        focus: $focus,
                        name: .constant(root.arrangement.name),
                        url: $root.arrangement.filePath,
                        dependencies: $root.arrangement.dependencies,
                        machines: $machines
                    )
                case .machine:
                    DependenciesView(
                        focus: $focus,
                        name: .constant(root.machine.name),
                        url: $root.machine.filePath,
                        dependencies: $root.machine.dependencies,
                        machines: $machines
                    )
                }
                switch root {
                case .arrangement(let arrangement):
                    if focus == arrangement.filePath {
                        ArrangementView(arrangement: $root.arrangement, selection: viewModel.selection(for: focus))
                    } else if let binding = viewModel.binding(for: focus) {
                        if let machineViewModel = viewModels[binding.wrappedValue.filePath] {
                            MachineView(viewModel: machineViewModel, selection: viewModel.selection(for: focus))
                        } else if let plist = try? String(contentsOf: binding.wrappedValue.filePath.appendingPathComponent("Layout.plist")) {
                            MachineView(viewModel: viewModel(from: plist, with: binding), selection: viewModel.selection(for: focus))
                        } else {
                            MachineView(viewModel: viewModel(with: binding), selection: viewModel.selection(for: focus))
                        }
                        
                    }
                case .machine(let rootMachine):
                    if focus == rootMachine.filePath {
                        if let machineViewModel = viewModels[rootMachine.filePath] {
                            MachineView(viewModel: machineViewModel, selection: viewModel.selection(for: focus))
                        } else if let plist = try? String(contentsOf: rootMachine.filePath.appendingPathComponent("Layout.plist")) {
                            MachineView(viewModel: viewModel(from: plist, with: $root.machine), selection: viewModel.selection(for: focus))
                        } else {
                            MachineView(viewModel: viewModel(with: $root.machine), selection: viewModel.selection(for: focus))
                        }
                    } else if let binding = viewModel.binding(for: focus) {
                        if let machineViewModel = viewModels[binding.wrappedValue.filePath] {
                            MachineView(viewModel: machineViewModel, selection: viewModel.selection(for: focus))
                        } else if let plist = try? String(contentsOf: binding.wrappedValue.filePath.appendingPathComponent("Layout.plist")) {
                            MachineView(viewModel: viewModel(from: plist, with: binding), selection: viewModel.selection(for: focus))
                        } else {
                            MachineView(viewModel: viewModel(with: binding), selection: viewModel.selection(for: focus))
                        }
                    }
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

