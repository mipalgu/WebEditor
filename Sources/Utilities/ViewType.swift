//
//  File.swift
//  
//
//  Created by Morgan McColl on 24/4/21.
//

import Foundation

public enum ViewType: Hashable {
    
    public var stateIndex: Int {
        switch self {
        case .state(let stateIndex), .transition(let stateIndex, _):
            return stateIndex
        }
    }
    
    public var transitionIndex: Int {
        switch self {
        case .transition(_, let index):
            return index
        default:
            fatalError("Trying to fetch transition index on a state!")
        }
    }
    
    public var isState: Bool {
        switch self {
        case .state:
            return true
        default:
            return false
        }
    }
    
    public var isTransition: Bool {
        switch self {
        case .transition:
            return true
        case .state:
            return false
        }
    }
    
    case state(stateIndex: Int)
    case transition(stateIndex: Int, transitionIndex: Int)
}
