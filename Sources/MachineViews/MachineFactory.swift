//
//  File.swift
//  
//
//  Created by Morgan McColl on 24/11/20.
//

import Machines
import Attributes

import Foundation

public struct MachineFactory {
    
    public func createDefaultMachine(name: String, filePath: URL, semantics: Machine.Semantics) -> MachineViewModel {
        var machine = Machine.initialMachine(forSemantics: semantics)
        //machine.modify(attribute: machine.path.name, value: name)
        do {
            try machine.modify(attribute: machine.path.filePath, value: filePath)
        } catch let error {
            print(error, stderr)
        }
        let ref = Ref(copying: machine)
        return MachineViewModel(machine: ref)
    }
    
}
