//
//  SwiftUIView.swift
//  
//
//  Created by Morgan McColl on 24/4/21.
//

import TokamakShim
import Attributes
import Utilities
import Machines

struct MachineView: View {
    
    @Binding var machine: Machine
    
    @State var focus: Focus = .machine
    
    @State var attributesCollapsed: Bool = false
    
    @Binding var selection: AttributeGroup?
    
    var path: Attributes.Path<Machine, [AttributeGroup]> {
        switch focus {
            case .machine:
                return machine.path.attributes
            case .state(let stateIndex):
                return machine.path.states[stateIndex].attributes
            case .transition(let stateIndex, let transitionIndex):
                return machine.path.states[stateIndex].transitions[transitionIndex].attributes
        }
    }
    
    var label: String {
        switch focus {
        case .machine:
            return "Machine: \(machine.name)"
        case .state(let stateIndex):
            return "State: \(machine.states[stateIndex].name)"
        case .transition(let stateIndex, let transitionIndex):
            return "State \(machine.states[stateIndex].name) Transition \(transitionIndex)"
        }
    }
    
    var body: some View {
        HStack {
            CanvasView(machine: $machine, focus: $focus)
            CollapsableAttributeGroupsView(machine: $machine, path: path, collapsed: $attributesCollapsed, label: label, selection: $selection)
                .frame(width: !attributesCollapsed ? 500 : 50.0)
        }
    }
}


//struct SwiftUIView_Previews: PreviewProvider {
//    static var previews: some View {
//        SwiftUIView()
//    }
//}
