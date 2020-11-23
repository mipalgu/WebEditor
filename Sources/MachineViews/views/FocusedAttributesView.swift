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
    
    @ObservedObject var machine: Ref<Machine>
    
    @Binding var viewType: ViewType
    
    var body: some View {
        switch viewType {
        case .machine:
            AttributeGroupsView(
                machine: machine,
                path: Machine.path.attributes,
                label: "\(machine.value.name) Machine Attributes"
            )
        case .state(_, let stateIndex):
            AttributeGroupsView(
                machine: machine,
                path: Machine.path.states[stateIndex].attributes,
                label: "\(machine.value.states[stateIndex].name) State Attributes"
            )
        default:
            EmptyView()
        }
    }
}
