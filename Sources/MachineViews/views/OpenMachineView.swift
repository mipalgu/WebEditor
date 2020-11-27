//
//  SwiftUIView.swift
//  
//
//  Created by Morgan McColl on 26/11/20.
//

#if canImport(TokamakShim)
import TokamakShim
#else
import SwiftUI
#endif
import Machines
import Attributes

import Foundation

struct OpenMachineView: View {
    
    @ObservedObject var viewModel: EditorViewModel
    
    @State var machineURL: URL
    
    @State var selected: Machine.Semantics
    
    @State var validValues = Machine.Semantics.allCases
    
    @EnvironmentObject var config: Config
    
    var body: some View {
        VStack {
            Text("Open Machine")
                .font(config.fontTitle3)
            Section {
                TextField("Open Machine", text: Binding(get: { machineURL.absoluteString }, set: {
                    machineURL = URL(fileURLWithPath: $0)
                }))
                .background(config.fieldColor)
            }
            Section {
                HStack {
                    Spacer()
                    Button(action: { viewModel.dialogueType = .none }) {
                        Text("Close")
                    }
//                    Button(action: {
//                        print("Before open: \(editorViewModel.machines)")
//                        print("Current UUID: \(editorViewModel.currentMachine.id)")
//                        if let machine = editorViewModel.machines.first(where: { $0.machine.filePath == machineURL }) {
//                            config.alertView = .none
//                            editorViewModel.changeMainView(machine: machine.id)
//                            return
//                        }
//                        do {
//                            let newMachine = try Machine(filePath: machineURL)
//                            let layoutPath = machineURL.appendingPathComponent("Layout.plist")
//                            let plistData = try String(contentsOf: layoutPath, encoding: .utf8)
//                            let viewModel = MachineViewModel(machine: Ref(copying: newMachine), plist: plistData)
//                            editorViewModel.machines.append(viewModel)
//                            config.alertView = .none
//                            editorViewModel.changeMainView(machine: viewModel.machine.id)
//                            print("UUID: \(viewModel.machine.id)")
//                            print("After open: \(editorViewModel.machines)")
//                            print("New states: \(viewModel.states.map { $0.name })")
//                        } catch let error {
//                            print(error, stderr)
//                        }
//                    }) {
//                        Text("Open")
//                    }
//                    .padding(.leading, 10)
                }
            }
        }
        .background(config.backgroundColor)
    }
}
