//
//  SwiftUIView.swift
//  
//
//  Created by Morgan McColl on 30/11/20.
//

#if canImport(TokamakShim)
import TokamakShim
#else
import SwiftUI
#endif

import Machines
import Attributes
import Utilities

struct DependencyView: View {
    
    @ObservedObject var viewModel: ArrangementViewModel
    
    @ObservedObject var machine: Ref<Machine>
    
    let path: Attributes.Path<Machine, MachineDependency>
    
    @State var collapsed: Bool = true
    
    @EnvironmentObject var config: Config
    
    var rootDependencies: [MachineDependency] {
        guard let index = viewModel.machineIndex(name: machine.value[keyPath: path.path].name) else {
            return []
        }
        return viewModel.allMachines[index].machine.machine.dependencies
    }
    
    var body: some View {
        VStack {
            HStack {
                if rootDependencies.count > 0 {
                    if !collapsed {
                        Button(action: { collapsed = true }) {
                            Image(systemName: "arrowtriangle.down.fill")
                                .font(.system(size: 8.0, weight: .regular))
                                .frame(width: 15.0, height: 15.0)
                        }.buttonStyle(PlainButtonStyle())
                        
                    } else {
                        Button(action: { collapsed = false }) {
                            Image(systemName: "arrowtriangle.right.fill")
                                .font(.system(size: 8.0, weight: .regular))
                                .frame(width: 15.0, height: 15.0)
                        }.buttonStyle(PlainButtonStyle())
                    }
                }
                Button(action: {
                    let name = machine.value[keyPath: path.path].name
                    guard let machineIndex = viewModel.machineIndex(name: name) else {
                        print("Cannot find machine named \(name)", stderr)
                        return
                    }
                    viewModel.currentMachineIndex = machineIndex
                }) {
                    Text(machine.value[keyPath: path.path].name)
                        .font(config.fontHeading)
                }
                Spacer()
            }
            if !collapsed {
                ForEach(Array(rootDependencies.indices), id: \.self) { (index: Int) -> AnyView in
                    guard let machine = viewModel.machine(name: machine.value[keyPath: path.path].name) else {
                        return AnyView(EmptyView())
                    }
                    return AnyView(DependencyView(
                        viewModel: viewModel,
                        machine: machine.$machine,
                        path: Machine.path.dependencies[index]
                    ))
                }
            }
        }
        .padding(.leading, 10)
        .clipped()
    }
}

