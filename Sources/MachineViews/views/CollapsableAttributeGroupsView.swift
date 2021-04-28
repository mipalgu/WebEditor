//
//  SwiftUIView.swift
//  
//
//  Created by Morgan McColl on 23/11/20.
//

import TokamakShim

import Machines
import Attributes
import Utilities

import AttributeViews

struct CollapsableAttributeGroupsView: View {
    
    @Binding var machine: Machine
    
    let path: Attributes.Path<Machine, [AttributeGroup]>
    
    @Binding var collapsed: Bool
    
    let label: String
    
    let collapseLeft: Bool = false
    
    @State var selection: AttributeGroup? = nil
    
    @EnvironmentObject var config: Config
    
    var body: some View {
            VStack {
            if !collapsed {
                HStack {
                    if !collapseLeft {
                        Button(action: { collapsed = true }) {
                            Image(systemName: "arrow.right.to.line.alt")
                                .font(.system(size: 20, weight: .regular))
                                .frame(width: 30, height: 30)
                        }.buttonStyle(PlainButtonStyle())
                    }
                    Spacer()
                    Text(label.capitalized)
                        .font(config.fontTitle3)
                        .padding(.horizontal, 10)
                        .padding(collapseLeft ? .leading : .trailing, 25.0)
                    Spacer()
                    if collapseLeft {
                        
                        Button(action: { collapsed = true }) {
                            Image(systemName: "arrow.left.to.line.alt")
                                .font(.system(size: 20, weight: .regular))
                                .frame(width: 30, height: 30)
                        }.buttonStyle(PlainButtonStyle())
                    }
                }
                AttributeGroupsView(root: $machine, path: path, label: label, selection: $selection) {
                    ScrollView(.vertical, showsIndicators: true) {
                        Form {
                            HStack {
                                VStack(alignment: .leading) {
                                    CollectionView<Config>(
                                        root: $machine,
                                        path: Machine.path.dependencyAttributes,
                                        label: "Dependencies",
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
//                    .transition(.move(edge: .trailing))
            } else {
                HStack {
                    if collapseLeft {
                            Spacer()
                            Button(action: { collapsed = false }) {
                                Image(systemName: "arrow.right.to.line.alt")
                                    .font(.system(size: 20, weight: .regular))
                                    .frame(width: 30, height: 30)
                            }.buttonStyle(PlainButtonStyle())
                        
                    } else {
                        Button(action: { collapsed = false }) {
                            Image(systemName: "arrow.left.to.line.alt")
                                .font(.system(size: 20, weight: .regular))
                                .frame(width: 30, height: 30)
                        }.buttonStyle(PlainButtonStyle())
                        Spacer()
                    }
                }
                .padding(.horizontal, 10)
                Spacer()
                if collapseLeft {
                    Text(label.capitalized)
                        .font(config.fontTitle2)
                        .rotationEffect(Angle(degrees: -90.0))
                        .frame(minWidth: 500, maxWidth: .infinity, maxHeight: 50)
                        .scaledToFit()
                } else {
                    Text(label.capitalized)
                        .font(config.fontTitle2)
                        .rotationEffect(Angle(degrees: 90.0))
                        .frame(minWidth: 500, maxWidth: .infinity, maxHeight: 50)
                        .scaledToFit()
                }
                Spacer()
            }
        }
    }
}
