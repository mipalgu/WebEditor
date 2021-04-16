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
    
    @State var collapsedActions: [String: Bool] = [:]
    
    @State var expandedWidth: CGFloat = 300
    @State var expandedHeight: CGFloat = 200
    
    @State var collapsedWidth: CGFloat = 150
    @State var collapsedHeight: CGFloat = 200
    
    @State var expanded: Bool = false
    
    @EnvironmentObject var config: Config
    
    var body: some View {
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
