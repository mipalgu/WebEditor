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
import Utilities

struct HiddenStateView: View {
    
    @Binding var machine: Machine
    let path: Attributes.Path<Machine, Machines.State>
    
    @ObservedObject var viewModel: StateViewModel2
    @Binding var hidden: Bool
    @Binding var highlighted: Bool
    
    @EnvironmentObject var config: Config
    
    init(machine: Binding<Machine>, path: Attributes.Path<Machine, Machines.State>, viewModel: StateViewModel2, hidden: Binding<Bool>, highlighted: Binding<Bool>) {
        self._machine = machine
        self.path = path
        self.viewModel = viewModel
        self._hidden = hidden
        self._highlighted = highlighted
    }
    
    var body: some View {
        if !hidden {
            StateView(machine: $machine, path: path)
                .gesture(DragGesture(minimumDistance: 0, coordinateSpace: .named("MAIN_VIEW"))
                    .onChanged {
                        self.viewModel.handleDrag(gesture: $0, frameWidth: 10000, frameHeight: 10000)
                    }.onEnded {
                        self.viewModel.finishDrag(gesture: $0, frameWidth: 10000, frameHeight: 10000)
                    }
                )
        } else {
            if highlighted {
                Text(machine[keyPath: path.keyPath].name).font(config.fontBody).foregroundColor(config.highlightColour)
            } else {
                Text(machine[keyPath: path.keyPath].name).font(config.fontBody)
            }
        }
    }
}
