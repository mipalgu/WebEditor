//
//  SwiftUIView.swift
//  
//
//  Created by Morgan McColl on 24/4/21.
//

#if canImport(TokamakShim)
import TokamakShim
#else
import SwiftUI
#endif
import Machines

struct MachineView: View {
    
    @Binding var machine: Machine
    
    @State var focus: Focus
    
    var path: Machines.Path {
        switch focus {
            case .machine(focusedMachine): return focusedMachine.path
            case .state(state): return machine.path.states[machine.states.firstIndex(where: { $0 == state })!]
            default: return machine.path
        }
    }
    
    var body: some View {
        HStack {
            switch focus {
                case .machine(machine): CanvasView(machine: machine)
                case .state(state): StateEditView()
                default: EmptyView()
            }
            CollapsableAttributeGroupsView(machine: $machine, path: path)
        }
    }
}

//struct SwiftUIView_Previews: PreviewProvider {
//    static var previews: some View {
//        SwiftUIView()
//    }
//}
