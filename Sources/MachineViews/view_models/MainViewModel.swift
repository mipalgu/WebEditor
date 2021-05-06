//
//  File.swift
//  
//
//  Created by Morgan McColl on 29/4/21.
//

import Foundation
import TokamakShim
import Attributes
import Machines

final class MainViewModel: ObservableObject, GlobalChangeNotifier {
    
    enum Root {
        
        var arrangement: ArrangementViewModel {
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
        
        var machine: MachineViewModel {
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
        
        case arrangement(ArrangementViewModel)
        case machine(MachineViewModel)
        
    }
    
    @Published var focus: URL
    
    var root: Root
    
    var viewModels: [URL: MachineViewModel]
    
    private var selections: [URL: Int] = [:]
    
    init(root: Root) {
        self.root = root
        switch root {
        case .arrangement(let arrangement):
            focus = arrangement.arrangement.filePath
            viewModels = [:]
        case .machine(let machine):
            focus = machine.machine.filePath
            self.viewModels = [machine.machine.filePath: machine]
        }
    }
    
    func selection(for url: URL) -> Binding<Int?> {
        return Binding(
            get: { self.selections[url] },
            set: { self.selections[url] = $0 }
        )
    }
    
    func binding(for url: URL) -> Binding<Machine>? {
        guard nil != machine(for: url) else {
            return nil
        }
        return Binding(get: { self.viewModels[url]!.machine }, set: { self.viewModels[url]!.machine = $0 })
    }
    
    func machine(for url: URL) -> Machine? {
        if let machine = viewModels[url]?.machine {
            return machine
        }
        guard let loadedMachine = try? Machine(filePath: url) else {
            return nil
        }
        viewModels[url] = MachineViewModel(machine: loadedMachine)
        return loadedMachine
    }
    
    func viewModel(for url: URL) -> MachineViewModel? {
        if let viewModel = viewModels[url] {
            return viewModel
        }
        guard let binding = binding(for: url) else {
            return nil
        }
        guard let plist = try? String(contentsOf: binding.wrappedValue.filePath.appendingPathComponent("Layout.plist")) else {
            let newViewModel = MachineViewModel(machine: binding.wrappedValue)
            viewModels[binding.wrappedValue.filePath] = newViewModel
            return newViewModel
        }
        let newViewModel = MachineViewModel(machine: binding.wrappedValue, plist: plist)
        viewModels[binding.wrappedValue.filePath] = newViewModel
        return newViewModel
    }
    
    func send() {
        self.objectWillChange.send()
    }
    
}
