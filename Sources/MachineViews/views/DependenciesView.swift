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

struct DependenciesView: View {
    
    @Binding var machines: [Ref<Machine>]
    
    @Binding var rootMachines: [MachineDependency]
    
    @Binding var currentIndex: Int
    
    @Binding var collapsed: Bool
    
    let collapseLeft: Bool
    let buttonSize: CGFloat
    let buttonWidth: CGFloat
    let buttonHeight: CGFloat
    
    let label = "Dependencies"
    
    @State var rootMachinesExpanded: Set<String> = Set()
    
    var rootMachineModels: [Ref<Machine>] {
        rootMachines.compactMap { rootMachine in  machines.first(where: { $0.value.name == rootMachine.name }) }
    }
    
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
                    }
                    Spacer()
                    Text(label.capitalized)
                        .font(config.fontTitle3)
                        .padding(.horizontal, 10)
                        .padding(collapseLeft ? .leading : .trailing, buttonWidth / 2.0 + 10.0)
                    Spacer()
                    if collapseLeft {
                        Button(action: { collapsed = true }) {
                            Image(systemName: "arrow.left.to.line.alt")
                                .font(.system(size: buttonSize, weight: .regular))
                                .frame(width: buttonWidth, height: buttonHeight)
                        }.buttonStyle(PlainButtonStyle())
                    }
                }
                ForEach(rootMachineModels, id: \.self.value) {ref in
                    VStack(alignment: .leading) {
                        HStack {
                            if rootMachinesExpanded.contains(ref.value.name) {
                                Button(action: { rootMachinesExpanded.remove(ref.value.name) }) {
                                    Image(systemName: "arrowtriangle.down.fill")
                                        .font(.system(size: 8.0, weight: .regular))
                                        .frame(width: 15.0, height: 15.0)
                                }.buttonStyle(PlainButtonStyle())
                            } else {
                                Button(action: { rootMachinesExpanded.insert(ref.value.name) }) {
                                    Image(systemName: "arrowtriangle.right.fill")
                                        .font(.system(size: 8.0, weight: .regular))
                                        .frame(width: 15.0, height: 15.0)
                                }.buttonStyle(PlainButtonStyle())
                            }
                            Button(action: {
                                let name = ref.value.name
                                guard let machineIndex = machines.firstIndex(where: { $0.value.name == name }) else {
                                    print("Cannot find machine named \(name)", stderr)
                                    return
                                }
                                currentIndex = machineIndex
                            }) {
                                Text(ref.value.name)
                                    .font(config.fontHeading)
                            }.buttonStyle(PlainButtonStyle())
                            Spacer()
                        }
                        .background(machines[currentIndex] === ref ? config.highlightColour : Color.clear)
                        if rootMachinesExpanded.contains(ref.value.name) {
                            ForEach(ref.value.dependencies, id: \.self) { dep in
                                DependencyView(
                                    machines: $machines,
                                    currentIndex: $currentIndex,
                                    dependency: Binding(get: { machines.first(where: { $0.value.name == dep.name })! }, set: {_ in })
                                )
                                .background(machines[currentIndex] === ref ? config.highlightColour : Color.clear)
                            }
                        }
                    }
                }
                Spacer()
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
                Text(label.capitalized)
                    .font(config.fontTitle2)
                    .rotationEffect(Angle(degrees: collapseLeft ? -90.0 : 90.0))
                    .frame(minWidth: 500, maxWidth: .infinity, maxHeight: 300)
                    .scaledToFit()
                Spacer()
            }
        }
    }
}
