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
            Form {
                TabView {
                    ForEach(Array(machine[path: path].value.indices), id: \.self) { index in
                        AttributeGroupView(group: machine[bindingTo: path[index]], label: machine[path: path][index].name.value)
                            .padding(.horizontal, 10)
                            .tabItem {
                                Text(machine[path: path][index].name.value.pretty)
                            }
                    }
                    ScrollView(.vertical, showsIndicators: true) {
                        HStack {
                            VStack(alignment: .leading) {
                                CollectionView(
                                    machine: machine,
                                    path: Machine.path.dependencyAttributes,
                                    label: "Machine Dependencies",
                                    type: machine.value.dependencyAttributeType
                                )
                            }
                            Spacer()
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
}
