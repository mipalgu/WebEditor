//
//  AttributeGroupsView.swift
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

struct AttributeGroupsView: View {
    
    @Binding var machine: Machine
    let path: Attributes.Path<Machine, [AttributeGroup]>
    let label: String
    
    var body: some View {
        VStack {
            Text(label.capitalized)
            TabView() {
                ForEach(Array(machine[keyPath: path.path].indices), id: \.self) { index in
                    AttributeGroupView(machine: $machine, path: path[index], label: machine[keyPath: path.path][index].name)
                        .tabItem {
                            Text(machine[keyPath: path.path][index].name.capitalized)
                        }
                }
            }
        }
        .frame(minHeight: 720.0)
    }
}
