//
//  TransitionView.swift
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

struct TransitionView: View {
    
    @Binding var machine: Machine
    let path: Attributes.Path<Machine, Transition>
    @Binding var point0: CGPoint
    @Binding var point1: CGPoint
    @Binding var point2: CGPoint
    @Binding var point3: CGPoint
    
    @EnvironmentObject var config: Config
    
    var body: some View {
        Text("Not yet implemented.")
    }
}
