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

public enum ViewType {
    case machine
    case state(stateIndex: Int)
    case transition(stateIndex: Int, transitionIndex: Int)
}

public enum DialogType {
    case saveMachine(id: UUID)
    case openMachine
    case none
}
