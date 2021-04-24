//
//  MainView.swift
//  
//
//  Created by Morgan McColl on 21/11/20.
//

#if canImport(TokamakShim)
import TokamakShim
#else
import SwiftUI
#endif

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
    
    @State var viewModels: [URL: MachineViewModel2] = [:]
    
    @State var machines: [URL: Machine] = [:]
    
    @State var root: Root
    
    public init(arrangement: Arrangement) {
        self._focus = State(initialValue: arrangement.filePath)
        self._root = State(initialValue: .arrangement(arrangement))
    }
    
    public init(machine: Machine) {
        self._focus = State(initialValue: machine.filePath)
        self._root = State(initialValue: .machine(machine))
    }
    
    @EnvironmentObject var config: Config
    
    func machine(for url: URL) -> Machine? {
        if let machine = machines[url] {
            return machine
        }
        guard let loadedMachine = try? Machine(filePath: url) else {
            return nil
        }
        machines[url] = loadedMachine
        return loadedMachine
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
                        dependencies: $root.arrangement.rootMachines,
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
                        EmptyView() // Arrangement view.
                    } else if machines[focus] != nil {
                        MachineView(machine: Binding(get: { machines[focus]!}, set: { machines[focus] = $0}))
                    }
                case .machine(let rootMachine):
                    if focus == rootMachine.filePath {
                        MachineView(machine: $root.machine)
                    } else if machine(for: focus) != nil {
                        MachineView(machine: Binding(get: { machines[focus]!}, set: { machines[focus] = $0}))
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

