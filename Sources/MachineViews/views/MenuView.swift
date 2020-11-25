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

struct MenuView: View {
    
    @State var openDialogue: Bool = false
    
    @State var saveDialogue: Bool = false
    
    @ObservedObject var machineViewModel: MachineViewModel
    
    @EnvironmentObject var config: Config
    
    var body: some View {
        ZStack {
            VStack {
                Text(machineViewModel.machine.name)
                    .font(config.fontTitle1)
                Text(machineViewModel.machine.filePath.absoluteString)
                    .font(config.fontHeading)
            }
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
                Button(action: { config.alertView = ViewType.openMachine }) {
                    // Open Machine
                    VStack {
                        Image(systemName: "folder.fill")
                        Text("Open")
                            .font(config.fontBody)
                    }
                }
                Button(action: { machineViewModel.save() }) {
                    // Save Machine
                    VStack {
                        Image(systemName: "folder.circle")
                        Text("Save")
                            .font(config.fontBody)
                    }
                }
                Button(action: { config.alertView = ViewType.machine(id: machineViewModel.machine.id) }) {
                    // Save-As
                    VStack {
                        Image(systemName: "folder.circle.fill")
                        Text("Save-As")
                            .font(config.fontBody)
                    }
                }
                Spacer()
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
