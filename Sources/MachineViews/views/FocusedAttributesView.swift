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
    
    @Binding var viewType: ViewType
    
    var body: some View {
        switch viewType {
        case .machine(let machine):
            AttributeGroupsView(
                machine: machine.machine.asBinding,
                path: machine.machine.value.path.attributes,
                label: "\(machine.name) Attributes"
            )
        case .state(let state):
            AttributeGroupsView(
                machine: state.machine.asBinding,
                path: state.path.attributes,
                label: "\(state.name) Attributes")
        default:
            EmptyView()
        }
    }
}
