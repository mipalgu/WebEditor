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

struct DependencyLabelView: View {
    
    @ObservedObject var viewModel: ArrangementViewModel
    
    @Binding var name: String
    
    @Binding var collapsed: Bool
    
    @EnvironmentObject var config: Config
    
    var body: some View {
        HStack {
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
            Button(action: {
                guard let machineIndex = viewModel.machineIndex(name: name) else {
                    print("Cannot find machine named \(name)", stderr)
                    return
                }
                viewModel.currentMachineIndex = machineIndex
            }) {
                Text(name)
                    .font(config.fontHeading)
            }
            Spacer()
        }
    }
}
