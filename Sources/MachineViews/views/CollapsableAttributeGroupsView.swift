//
//  SwiftUIView.swift
//  
//
//  Created by Morgan McColl on 23/11/20.
//

#if canImport(TokamakShim)
import TokamakShim
#else
import SwiftUI
#endif
import Machines
import Attributes

struct CollapsableAttributeGroupsView: View {
    
    @Binding var machine: Machine
    
    let path: Attributes.Path<Machine, [AttributeGroup]>
    let label: String
    
    @Binding var collapsed: Bool
    
    let collapseLeft: Bool
    let buttonSize: CGFloat
    let buttonWidth: CGFloat
    let buttonHeight: CGFloat
    
    @EnvironmentObject var config: Config
    
    var body: some View {
        VStack {
            if !collapsed {
                HStack {
                    if !collapseLeft {
                        Button(action: { collapsed = true }) {
                            Image(systemName: "arrow.right.to.line.alt")
                                .font(.system(size: buttonSize, weight: .regular))
                                .frame(width: buttonWidth, height: buttonHeight)
                        }.buttonStyle(PlainButtonStyle())
                        Spacer()
                    }
                    Text(label.capitalized)
                        .font(config.fontTitle3)
                        .padding(.horizontal, 10)
                    if collapseLeft {
                        Spacer()
                        Button(action: { collapsed = true }) {
                            Image(systemName: "arrow.left.to.line.alt")
                                .font(.system(size: buttonSize, weight: .regular))
                                .frame(width: buttonWidth, height: buttonHeight)
                        }.buttonStyle(PlainButtonStyle())
                    }
                }
                TabView {
                    ForEach(Array(machine[keyPath: path.path].indices), id: \.self) { index in
                        AttributeGroupView(machine: $machine, path: path[index], label: machine[keyPath: path.path][index].name)
                            .padding(.horizontal, 10)
                            .tabItem {
                                Text(machine[keyPath: path.path][index].name.pretty)
                            }
                    }
                }
            } else {
                HStack {
                    if collapseLeft {
                            Spacer()
                            Button(action: { collapsed = false }) {
                                Image(systemName: "arrow.right.to.line.alt")
                                    .font(.system(size: buttonSize, weight: .regular))
                                    .frame(width: buttonWidth, height: buttonHeight)
                            }.buttonStyle(PlainButtonStyle())
                        
                    } else {
                        Button(action: { collapsed = false }) {
                            Image(systemName: "arrow.left.to.line.alt")
                                .font(.system(size: buttonSize, weight: .regular))
                                .frame(width: buttonWidth, height: buttonHeight)
                        }.buttonStyle(PlainButtonStyle())
                        Spacer()
                    }
                }
                .padding(.horizontal, 10)
                Spacer()
            }
        }
    }
}
