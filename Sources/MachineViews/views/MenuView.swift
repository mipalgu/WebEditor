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
    
    @ObservedObject var machine: Ref<Machine>
    
    @EnvironmentObject var config: Config
    
    var body: some View {
        ZStack {
            VStack {
                Text(machine.value.name)
                    .font(config.fontTitle1)
                Text(machine.value.filePath.absoluteString)
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
                Button(action: { openDialogue = true }) {
                    // Open Machine
                    VStack {
                        Image(systemName: "folder.fill")
                        Text("Open")
                            .font(config.fontBody)
                    }
                }
                Button(action: {  }) {
                    // Save Machine
                    VStack {
                        Image(systemName: "folder.circle")
                        Text("Save")
                            .font(config.fontBody)
                    }
                }
                Button(action: { config.alertView = ViewType.machine(id: machine.value.id) }) {
                    // Save-As
                    VStack {
                        Image(systemName: "folder.circle.fill")
                        Text("Save-As")
                            .font(config.fontBody)
                    }
                }
                Spacer()
                VStack {
                    Text(machine.value.semantics.rawValue)
                        .font(config.fontBody)
                    Text("Semantics")
                        .font(config.fontHeading)
                }
            }
        }
        .padding(20.0)
    }
}
