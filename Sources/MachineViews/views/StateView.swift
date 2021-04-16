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
    @Binding var width: CGFloat
    @Binding var height: CGFloat
    
    @State var collapsedActions: [String: Bool] = [:]
    @State var expanded: Bool
    
    @State var collapsedWidth: CGFloat
    @State var collapsedHeight: CGFloat
    @State var expandedWidth: CGFloat
    @State var expandedHeight: CGFloat
    
    init(machine: Binding<Machine>, path: Attributes.Path<Machine, Machines.State>, width: Binding<CGFloat> = .constant(300), height: Binding<CGFloat> = .constant(200), expanded: Bool = false) {
        self._machine = machine
        self.path = path
        self._width = width
        self._height = height
        self._expanded = State(initialValue: expanded)
        if expanded {
            self._collapsedWidth = State(initialValue: 150)
            self._collapsedHeight = State(initialValue: 200)
            self._expandedWidth = State(initialValue: width.wrappedValue)
            self._expandedHeight = State(initialValue: height.wrappedValue)
        } else {
            self._collapsedWidth = State(initialValue: width.wrappedValue)
            self._collapsedHeight = State(initialValue: height.wrappedValue)
            self._expandedWidth = State(initialValue: 300)
            self._expandedHeight = State(initialValue: 200)
        }
    }
    
    @EnvironmentObject var config: Config
    
    var body: some View {
        Group {
            if expanded {
                StateExpandedView(root: $machine, path: path, collapsedActions: $collapsedActions) {
                    StateTitleView(machine: $machine, path: path.name, expanded: $expanded)
                }.frame(width: max(width, 300), height: max(height, 200))
            } else {
                StateCollapsedView {
                    StateTitleView(machine: $machine, path: path.name, expanded: $expanded)
                }.frame(width: max(width, 75), height: max(height, 100))
            }
        }.onChange(of: expanded) { newValue in
            if newValue {
                collapsedWidth = width
                collapsedHeight = height
                width = expandedWidth
                height = expandedHeight
            } else {
                expandedWidth = width
                expandedHeight = height
                width = collapsedWidth
                height = collapsedHeight
            }
        }
    }
}
