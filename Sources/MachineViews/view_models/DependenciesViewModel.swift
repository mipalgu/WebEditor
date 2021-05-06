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

final class DependenciesViewModel: ObservableObject {
    
    @Published var machines: [URL: Machine] = [:]
    
    var viewModels: [URL: MachineViewModel] = [:]
    
    private var selections: [URL: Int] = [:]
    
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
        return Binding(get: { self.machines[url]! }, set: { self.machines[url] = $0 })
    }
    
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
    
    func viewModel(for url: URL) -> MachineViewModel? {
        if let viewModel = viewModels[url] {
            return viewModel
        }
        guard let binding = binding(for: url) else {
            return nil
        }
        guard let plist = try? String(contentsOf: binding.wrappedValue.filePath.appendingPathComponent("Layout.plist")) else {
            let newViewModel = MachineViewModel(machine: binding)
            viewModels[binding.wrappedValue.filePath] = newViewModel
            return newViewModel
        }
        let newViewModel = MachineViewModel(machine: binding, plist: plist)
        viewModels[binding.wrappedValue.filePath] = newViewModel
        return newViewModel
    }
    
}
