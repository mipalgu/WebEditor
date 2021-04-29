//
//  File.swift
//  
//
//  Created by Morgan McColl on 29/4/21.
//

import Foundation
import TokamakShim
import Machines

final class DependenciesViewModel {
    
    var machines: [URL: Machine] = [:]
    
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
