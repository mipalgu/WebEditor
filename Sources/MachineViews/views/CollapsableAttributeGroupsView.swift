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
import Utilities

struct CollapsableAttributeGroupsView: View {
    
    @Binding var machine: Machine
    
    let path: Attributes.Path<Machine, [AttributeGroup]>
    
    @Binding var collapsed: Bool
    
    @Binding var width: CGFloat
    
    let minWidth: CGFloat
    
    let maxWidth: CGFloat
    
    let label: String
    
    let collapseLeft: Bool = false
    
    @State var isStretching: Bool = false
    
    @State var startWidth: CGFloat = 200.0
    
    @EnvironmentObject var config: Config
    
    var body: some View {
        HStack {
            if !collapseLeft && !collapsed {
                Divider()
                    .foregroundColor(Color.blue)
                    .background(Color.blue)
                    .frame(width: 15)
                    .gesture(
                        DragGesture(minimumDistance: 0, coordinateSpace: .named("MAIN_VIEW"))
                            .onChanged {
                                if !isStretching {
                                    isStretching = true
                                    startWidth = width
                                }
                                width = max(min(startWidth - $0.translation.width, maxWidth), minWidth)
                            }.onEnded { _ in
                                isStretching = false
                            }
                    )
            }
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
                    AttributeGroupsView(machine: $machine, path: path, label: label)
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
            if collapseLeft && !collapsed {
                Divider()
                    .background(Color.blue)
                    .foregroundColor(Color.gray)
                    .frame(width: 15)
                    .gesture(
                        DragGesture(minimumDistance: 0, coordinateSpace: .named("MAIN_VIEW"))
                            .onChanged {
                                if !isStretching {
                                    isStretching = true
                                    startWidth = width
                                }
                                width = max(min(startWidth - $0.translation.width, maxWidth), minWidth)
                            }.onEnded { _ in
                                isStretching = false
                            }
                    )
            }
        }
    }
}
