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

public struct MenuView: View {
    
    @ObservedObject public var viewModel: ArrangementViewModel
    
    @EnvironmentObject public var config: Config
    
    public init(viewModel: ArrangementViewModel) {
        self.viewModel = viewModel
    }
    
    public var body: some View {
        HStack {
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
                Button(action: { viewModel.focusedView.machine.save() }) {
                    // Save Machine
                    VStack {
                        Image(systemName: "folder.circle")
                        Text("Save")
                            .font(config.fontBody)
                    }
                }
                Button(action: { config.alertView = .saveMachine(id: viewModel.focusedView.machine.machine.id) }) {
                    // Save-As
                    VStack {
                        Image(systemName: "folder.circle.fill")
                        Text("Save-As")
                            .font(config.fontBody)
                    }
                }
            }
            Spacer()
            VStack {
                Text(viewModel.focusedView.machine.machine.semantics.rawValue)
                    .font(config.fontBody)
                Text("Semantics")
                    .font(config.fontHeading)
            }
        }
        .padding(20.0)
    }
}
