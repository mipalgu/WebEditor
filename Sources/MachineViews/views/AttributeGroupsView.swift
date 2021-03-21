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
import Utilities
import AttributeViews

public struct AttributeGroupsView: View {
    
    @ObservedObject var machine: Ref<Machine>
    let path: Attributes.Path<Machine, [AttributeGroup]>
    let label: String
    
    @EnvironmentObject var config: Config
    
    @State var selection: AttributeGroup? = nil
    
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
            TabView(selection: Binding($selection)) {
                ForEach(Array(machine[path: path].value.enumerated()), id: \.1.name) { (index, group) in
                    AttributeGroupView<Config, Machine>(root: machine.asBinding, path: path[index], label: group.name)
                        .padding(.horizontal, 10)
                        .tabItem {
                            Text(group.name.pretty)
                        }
                }
                ScrollView(.vertical, showsIndicators: true) {
                    Form {
                        HStack {
                            VStack(alignment: .leading) {
                                CollectionView<Config, Machine>(
                                    root: machine.asBinding,
                                    path: Machine.path.dependencyAttributes,
                                    label: "Machine Dependencies",
                                    type: machine.value.dependencyAttributeType
                                )
                            }
                            Spacer()
                        }
                    }
                }
                .padding(.horizontal, 10)
                .tabItem {
                    Text("Dependencies")
                }
            }
            
        }
    }
}
