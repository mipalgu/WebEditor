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
    @Binding var expanded: Bool
    @Binding var collapsedWidth: CGFloat
    @Binding var collapsedHeight: CGFloat
    @Binding var expandedWidth: CGFloat
    @Binding var expandedHeight: CGFloat
    @Binding var collapsedActions: [String: Bool]
    
    @EnvironmentObject var config: Config
    
    init(machine: Binding<Machine>, path: Attributes.Path<Machine, Machines.State>, hidden: Binding<Bool> = .constant(false), highlighted: Binding<Bool> = .constant(false), expanded: Binding<Bool> = .constant(false), collapsedWidth: Binding<CGFloat> = .constant(150), collapseHeight: Binding<CGFloat> = .constant(200), expandedWidth: Binding<CGFloat> = .constant(300), expandedHeight: Binding<CGFloat> = .constant(200), collapsedActions: Binding<[String: Bool]> = .constant([:])) {
        self._machine = machine
        self.path = path
        self._hidden = hidden
        self._highlighted = highlighted
        self._expanded = expanded
        self._collapsedWidth = collapsedWidth
        self._collapsedHeight = collapseHeight
        self._expandedWidth = expandedWidth
        self._expandedHeight = expandedHeight
        self._collapsedActions = collapsedActions
    }
    
    var body: some View {
        if !hidden {
            StateView(
                machine: $machine,
                path: path,
                expanded: $expanded,
                collapsedWidth: $collapsedWidth,
                collapseHeight: $collapsedHeight,
                expandedWidth: $expandedWidth,
                expandedHeight: $expandedHeight,
                collapsedActions: $collapsedActions
            )
        } else {
            if highlighted {
                Text(machine[keyPath: path.keyPath].name).font(config.fontBody).foregroundColor(config.highlightColour)
            } else {
                Text(machine[keyPath: path.keyPath].name).font(config.fontBody)
            }
        }
    }
}
