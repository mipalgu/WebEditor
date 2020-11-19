//
//  MachineView.swift
//  
//
//  Created by Morgan McColl on 16/11/20.
//

#if canImport(TokamakShim)
import TokamakShim
#else
import SwiftUI
#endif
import Machines
import Attributes

public struct MachineView: View {
    
    @ObservedObject var viewModel: MachineViewModel
    
    @EnvironmentObject var config: Config
    
    public init(viewModel: MachineViewModel) {
        self.viewModel = viewModel
    }
    
    public var body: some View {
        ForEach(viewModel.states, id: \.name) {
            StateView(viewModel: $0)
                .coordinateSpace(name: "MAIN_VIEW")
                .position($0.location)
        }
    }
}

