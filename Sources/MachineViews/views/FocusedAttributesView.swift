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
    
    let label: String
    
    @Binding var collapsed: Bool
    
    let collapseLeft: Bool
    let buttonSize: CGFloat
    let buttonWidth: CGFloat
    let buttonHeight: CGFloat
    
    var body: some View {
        switch viewType {
        case .machine:
            CollapsableAttributeGroupsView(machine: machine, path: Machine.path.attributes, label: "\(machine.value.name) Machine Attributes", collapsed: $collapsed, collapseLeft: collapseLeft, buttonSize: buttonSize, buttonWidth: buttonWidth, buttonHeight: buttonHeight)
        case .state(let stateIndex):
            CollapsableAttributeGroupsView(machine: machine, path: Machine.path.states[stateIndex].attributes, label: "\(machine.value.states[stateIndex].name) State Attributes", collapsed: $collapsed, collapseLeft: collapseLeft, buttonSize: buttonSize, buttonWidth: buttonWidth, buttonHeight: buttonHeight)
        case .transition(let path):
            CollapsableAttributeGroupsView(machine: machine, path: path.attributes, label: "Transition Attributes", collapsed: $collapsed, collapseLeft: collapseLeft, buttonSize: buttonSize, buttonWidth: buttonWidth, buttonHeight: buttonHeight)
        }
    }
}
