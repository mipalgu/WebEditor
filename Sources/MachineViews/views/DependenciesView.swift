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
    
    @ObservedObject var viewModel: ArrangementViewModel
    
    @Binding var collapsed: Bool
    
    let collapseLeft: Bool
    let buttonSize: CGFloat
    let buttonWidth: CGFloat
    let buttonHeight: CGFloat
    
    let label = "Dependencies"
    
    @State var rootMachinesExpanded: Set<String> = Set()
    
    @EnvironmentObject var config: Config
    
    var body: some View {
        GeometryReader { (geometry: GeometryProxy) in
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
                    ForEach(viewModel.rootMachineViewModels.map { $0.machine.$machine }, id: \.self.value) {ref in
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
                                    guard let machineIndex = viewModel.machineIndex(name: name) else {
                                        print("Cannot find machine named \(name)", stderr)
                                        return
                                    }
                                    viewModel.currentMachineIndex = machineIndex
                                }) {
                                    Text(ref.value.name)
                                        .font(config.fontHeading)
                                }.buttonStyle(PlainButtonStyle())
                                Spacer()
                            }
                            .background(viewModel.currentMachine.machine.$machine === ref ? config.highlightColour : Color.clear)
                            if rootMachinesExpanded.contains(ref.value.name) {
                                ForEach(Array(ref.value.dependencies.indices), id: \.self) {
                                    DependencyView(
                                        viewModel: viewModel,
                                        machine: ref,
                                        path: ref.value.path.dependencies[$0]
                                    )
                                    .background(viewModel.currentMachine.machine.$machine === ref ? config.highlightColour : Color.clear)
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
                    if collapseLeft {
                        Text(label.capitalized)
                            .font(config.fontTitle2)
                            .rotationEffect(Angle(degrees: -90.0))
                            .frame(minWidth: 500, maxWidth: .infinity, maxHeight: 300)
                            .scaledToFit()
                    } else {
                        Text(label.capitalized)
                            .font(config.fontTitle2)
                            .rotationEffect(Angle(degrees: 90.0))
                            .frame(minWidth: 500, maxWidth: .infinity, maxHeight: 300)
                            .scaledToFit()
                    }
                    Spacer()
                }
            }
        }
    }
}
