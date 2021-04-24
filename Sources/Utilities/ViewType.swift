//
//  File.swift
//  
//
//  Created by Morgan McColl on 24/4/21.
//

import Foundation

public enum ViewType: Hashable {
    case state(stateIndex: Int)
    case transition(stateIndex: Int, transitionIndex: Int)
}
