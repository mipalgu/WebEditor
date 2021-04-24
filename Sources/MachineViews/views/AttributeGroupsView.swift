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
import GUUI

public struct AttributeGroupsView: View {
    
    class Temp {
        
        var idCache = IDCache<AttributeGroup>()
        
    }
    
    @Binding var machine: Machine
    let path: Attributes.Path<Machine, [AttributeGroup]>
    let label: String
    
    let temp = Temp()
    
//    @EnvironmentObject var config: Config
    
    @State var selection: AttributeGroup? = nil
    
    public init(machine: Binding<Machine>, path: Attributes.Path<Machine, [AttributeGroup]>, label: String) {
        self._machine = machine
        self.path = path
        self.label = label
    }
    
    var groups: [Row<AttributeGroup>] {
        machine[keyPath: path.path].enumerated().map {
            Row(id: temp.idCache.id(for: $1), index: $0, data: $1)
        }
    }
    
    public var body: some View {
        VStack {
            Text(label.capitalized)
                .font(.title3)
//                .foregroundColor(config.textColor)
            TabView(selection: Binding($selection)) {
                ForEach(groups, id: \.self) { row in
                    AttributeGroupView<Config>(root: $machine, path: path[row.index], label: row.data.name)
                        .padding(.horizontal, 10)
                        .tabItem {
                            Text(row.data.name.pretty)
                        }
                }
                ScrollView(.vertical, showsIndicators: true) {
                    Form {
                        HStack {
                            VStack(alignment: .leading) {
                                CollectionView<Config>(
                                    root: $machine,
                                    path: Machine.path.dependencyAttributes,
                                    label: "Machine Dependencies",
                                    type: machine.dependencyAttributeType
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
