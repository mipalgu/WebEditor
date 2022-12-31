//
//  ViewType.swift
//  
//
//  Created by Morgan McColl on 21/11/20.
//

import GUUI
import MetaMachines
import Attributes

public enum Focus: Hashable {
    case machine
    case state(stateIndex: Int)
    case transition(stateIndex: Int, transitionIndex: Int)
}
//
public enum DialogType {
    case saveMachine(id: UUID)
    case openMachine
    case none
}

extension Focus: Equatable {}
