//
//  SwiftUIView.swift
//  
//
//  Created by Morgan McColl on 25/11/20.
//

#if canImport(TokamakShim)
import TokamakShim
#else
import SwiftUI
#endif
import Machines
import Attributes

struct SaveMachineView: View {
    
    @ObservedObject var viewModel: EditorViewModel
    
    @EnvironmentObject var config: Config
    
    var body: some View {
        Form {
            TextField("File Path", text: Binding(get: { viewModel.machine.machine.filePath.absoluteString } , set: {
                let url = URL(fileURLWithPath: $0)
                do {
                    try viewModel.machine.machine.modify(attribute: viewModel.machine.path.filePath, value: url)
                } catch let error {
                    print(error, stderr)
                }
            }))
            HStack {
                Spacer()
                Button(action: {
                    viewModel.machine.save()
                    viewModel.dialogueType = .none
                }, label: {
                    Text("Save")
                })
            }
        }
    }
}

