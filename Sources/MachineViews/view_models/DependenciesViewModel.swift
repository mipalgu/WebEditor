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
    
    private var selections: [URL: AttributeGroup] = [:]
    
    func selection(for url: URL) -> Binding<AttributeGroup?> {
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
    
}
