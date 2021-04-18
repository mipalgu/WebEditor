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
    @Binding var collapsedWidth: CGFloat
    @Binding var collapsedHeight: CGFloat
    @Binding var expandedWidth: CGFloat
    @Binding var expandedHeight: CGFloat
    @Binding var collapsedActions: [String: Bool]
    
    init(machine: Binding<Machine>, path: Attributes.Path<Machine, Machines.State>, expanded: Binding<Bool> = .constant(false), collapsedWidth: Binding<CGFloat> = .constant(150), collapseHeight: Binding<CGFloat> = .constant(200), expandedWidth: Binding<CGFloat> = .constant(300), expandedHeight: Binding<CGFloat> = .constant(200), collapsedActions: Binding<[String: Bool]> = .constant([:])) {
        self._machine = machine
        self.path = path
        self._expanded = expanded
        self._collapsedWidth = collapsedWidth
        self._collapsedHeight = collapseHeight
        self._expandedWidth = expandedWidth
        self._expandedHeight = expandedHeight
        self._collapsedActions = collapsedActions
    }
    
    @EnvironmentObject var config: Config
    
    var body: some View {
        Group {
            if expanded {
                StateExpandedView(root: $machine, path: path, collapsedActions: $collapsedActions) {
                    StateTitleView(machine: $machine, path: path.name, expanded: $expanded)
                }.frame(width: max(expandedWidth, 300), height: max(expandedHeight, 200))
            } else {
                StateCollapsedView {
                    StateTitleView(machine: $machine, path: path.name, expanded: $expanded)
                }.frame(width: max(collapsedWidth, 75), height: max(collapsedHeight, 100))
            }
        }
    }
}
