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

public struct AttributeGroupsView: View {
    
    @ObservedObject var machine: Ref<Machine>
    let path: Attributes.Path<Machine, [AttributeGroup]>
    let label: String
    
    @EnvironmentObject var config: Config
    
    public init(machine: Ref<Machine>, path: Attributes.Path<Machine, [AttributeGroup]>, label: String) {
        self.machine = machine
        self.path = path
        self.label = label
    }
    
    public var body: some View {
        VStack {
            Text(label.capitalized)
                .font(.title3)
                .foregroundColor(config.textColor)
            TabView {
                ForEach(Array(machine[path: path].value.indices), id: \.self) { index in
                    AttributeGroupView(machine: machine, path: path[index], label: machine[path: path][index].name.value)
                        .padding(.horizontal, 10)
                        .tabItem {
                            Text(machine[path: path][index].name.value.pretty)
                        }
                }
            }
            
        }
    }
}
