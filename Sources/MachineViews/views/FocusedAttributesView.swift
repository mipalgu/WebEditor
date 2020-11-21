//
//  FocusedAttributesView.swift
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

struct FocusedAttributesView: View {
    
    @Binding var machine: Machine
    
    @Binding var viewType: ViewType
    
    var body: some View {
        switch viewType {
        case .machine:
            AttributeGroupsView(
                machine: $machine,
                path: machine.path.attributes,
                label: "\(machine.name) Attributes"
            )
        case .state(_, let stateIndex):
            AttributeGroupsView(
                machine: $machine,
                path: machine.path.states[stateIndex].attributes,
                label: "\(machine.states[stateIndex].name) Attributes")
        default:
            EmptyView()
        }
    }
}
