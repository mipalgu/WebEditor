//
//  ViewType.swift
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

public enum Focus {
    case arrangement(arrangement: Binding<Arrangement>)
    case machine(machine: Binding<Machine>)
    case state(state: Binding<Machines.State>)
    case transition(transition: Binding<Transition>)
}
//
//public enum DialogType {
//    case saveMachine(id: UUID)
//    case openMachine
//    case none
//}
