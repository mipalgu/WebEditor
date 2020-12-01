//
//  MenuView.swift
//  
//
//  Created by Morgan McColl on 20/11/20.
//

#if canImport(TokamakShim)
import TokamakShim
#else
import SwiftUI
#endif

import Machines
import Attributes
import Utilities

public struct MenuView: View {
    
    @State var openDialogue: Bool = false
    
    @State var saveDialogue: Bool = false
    
    @Binding public var machineViewModel: MachineViewModel?
    
    @EnvironmentObject var config: Config
    
    public init(machineViewModel: Binding<MachineViewModel?>) {
        self._machineViewModel = machineViewModel
    }
    
    public var body: some View {
        HStack {
            Button(action: {  }) {
                // New Machine
                VStack {
                    Image(systemName: "folder.fill.badge.plus")
                        //.resizable()
                        .scaledToFit()
                        //.font(.system(size: 30.0, weight: .regular))
                    Text("New")
                        .font(config.fontBody)
                }
            }
            Button(action: { config.alertView = .openMachine }) {
                // Open Machine
                VStack {
                    Image(systemName: "folder.fill")
                    Text("Open")
                        .font(config.fontBody)
                }
            }
            Button(action: { machineViewModel?.save() }) {
                // Save Machine
                VStack {
                    Image(systemName: "folder.circle")
                    Text("Save")
                        .font(config.fontBody)
                }
            }
            Button(action: { config.alertView = .saveMachine(id: machineViewModel?.machine.id ?? UUID()) }) {
                // Save-As
                VStack {
                    Image(systemName: "folder.circle.fill")
                    Text("Save-As")
                        .font(config.fontBody)
                }
            }
            Spacer()
            if let machineViewModel = machineViewModel {
                VStack {
                    Text(machineViewModel.machine.semantics.rawValue)
                        .font(config.fontBody)
                    Text("Semantics")
                        .font(config.fontHeading)
                }
            }
        }
        .padding(20.0)
    }
}
