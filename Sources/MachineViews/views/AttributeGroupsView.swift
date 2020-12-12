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
    
    let machine: Ref<Machine>
    @ObservedObject var groups: Ref<[AttributeGroup]>
    let path: Attributes.Path<Machine, [AttributeGroup]>
    let label: String
    
    @EnvironmentObject var config: Config
    
    @State var selection: AttributeGroup? = nil
    
    public init(machine: Ref<Machine>, path: Attributes.Path<Machine, [AttributeGroup]>, label: String) {
        self.machine = machine
        self.groups = machine[path: path]
        self.path = path
        self.label = label
    }
    
    public var body: some View {
        VStack {
            Text(label.capitalized)
                .font(.title3)
                .foregroundColor(config.textColor)
            TabView(selection: Binding($selection)) {
                ForEach(Array(Array(groups.value.indices).map { groups[$0] }.enumerated()), id: \.1.id) { (index, element) in
                    AttributeGroupView(root: machine, path: path[index], label: element.name.value)
                        .padding(.horizontal, 10)
                        .tabItem {
                            Text(element.name.value.pretty)
                        }
                }
                ScrollView(.vertical, showsIndicators: true) {
                    Form {
                        HStack {
                            VStack(alignment: .leading) {
                                CollectionView(
                                    root: machine,
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
