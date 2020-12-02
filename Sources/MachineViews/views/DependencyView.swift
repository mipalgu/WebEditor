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
    
    @Binding var machines: [Ref<Machine>]
    
    @Binding var currentIndex: Int
    
    @Binding var dependency: Ref<Machine>
    
    @State var collapsed: Bool = true
    
    @EnvironmentObject var config: Config
    
    var body: some View {
        VStack {
            HStack {
                if machines.count > 0 {
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
                DependencyLabelView(
                    machines: $machines,
                    currentIndex: $currentIndex,
                    name: Binding(
                        get: { dependency.value.name },
                        set: {_ in }
                    ),
                    collapsed: Binding(get: { collapsed }, set: { collapsed = $0 })
                )
                Spacer()
            }
            if !collapsed {
                if machines.count > 0 {
                    ForEach(Array(dependency.value.dependencies.indices), id: \.self) { (index: Int) -> AnyView in
                        guard let machine = machines.first(where: { $0.value.name == dependency.value.dependencies[index].name }) else {
                            return AnyView(EmptyView())
                        }
                        return AnyView(DependencyView(
                            machines: $machines,
                            currentIndex: $currentIndex,
                            dependency: Binding(get: { machine }, set: { _ in })
                        ))
                    }
                } else {
                    Text("Nothing")
                }
            }
        }
        .padding(.leading, 10)
        .clipped()
    }
}

