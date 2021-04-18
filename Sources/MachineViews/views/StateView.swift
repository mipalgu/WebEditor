//
//  StateView.swift
//  
//
//  Created by Morgan McColl on 15/11/20.
//

#if canImport(TokamakShim)
import TokamakShim
#else
import SwiftUI
#endif

import Machines
import Attributes
import AttributeViews
import Utilities

struct StateView: View {
    
    @Binding var machine: Machine
    let path: Attributes.Path<Machine, Machines.State>
    
    @Binding var expanded: Bool
    @Binding var collapsedActions: [String: Bool]
    
    init(machine: Binding<Machine>, path: Attributes.Path<Machine, Machines.State>, expanded: Binding<Bool> = .constant(false), collapsedActions: Binding<[String: Bool]> = .constant([:])) {
        self._machine = machine
        self.path = path
        self._expanded = expanded
        self._collapsedActions = collapsedActions
    }
    
    @EnvironmentObject var config: Config
    
    var body: some View {
        Group {
            if expanded {
                StateExpandedView(root: $machine, path: path, collapsedActions: $collapsedActions) {
                    StateTitleView(machine: $machine, path: path.name, expanded: $expanded)
                }
            } else {
                StateCollapsedView {
                    StateTitleView(machine: $machine, path: path.name, expanded: $expanded)
                }
            }
        }
    }
}
