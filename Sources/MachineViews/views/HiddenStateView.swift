//
//  SwiftUIView.swift
//  
//
//  Created by Morgan McColl on 26/11/20.
//

#if canImport(TokamakShim)
import TokamakShim
#else
import SwiftUI
#endif

import Machines
import Attributes
import Utilities

struct HiddenStateView: View {
    
    @Binding var machine: Machine
    let path: Attributes.Path<Machine, Machines.State>
    @Binding var hidden: Bool
    @Binding var highlighted: Bool
    
    @EnvironmentObject var config: Config
    
    init(machine: Binding<Machine>, path: Attributes.Path<Machine, Machines.State>, hidden: Binding<Bool>, highlighted: Binding<Bool>) {
        self._machine = machine
        self.path = path
        self._hidden = hidden
        self._highlighted = highlighted
    }
    
    var body: some View {
        if !hidden {
            StateView(machine: $machine, path: path)
        } else {
            if highlighted {
                Text(machine[keyPath: path.keyPath].name).font(config.fontBody).foregroundColor(config.highlightColour)
            } else {
                Text(machine[keyPath: path.keyPath].name).font(config.fontBody)
            }
        }
    }
}
