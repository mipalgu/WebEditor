//
//  StateCollapsedview.swift
//  
//
//  Created by Morgan McColl on 15/11/20.
//

#if canImport(TokamakShim)
import TokamakShim
#else
import SwiftUI
#endif
import Machines
import Attributes

struct StateCollapsedView: View {
    
    @Binding var machine: Machine
    let path: Attributes.Path<Machine, Machines.State>
    
    var body: some View {
        ZStack {
            Ellipse()
                .strokeBorder(Color.black, lineWidth: 2.0, antialiased: true)
                .shadow(color: Color(.sRGB, red: 0, green: 0, blue: 0, opacity: 0.5), radius: 1, x: 0, y: 2)
                .background(Ellipse().foregroundColor(Color.white))
                .padding(.bottom, 2)
                .frame(width: 100, height: 50)
                .clipped()
            Text(machine[keyPath: path.path].name)
                .font(.title2)
                .background(Color.white)
                .foregroundColor(Color.black)
                .clipped()
        }
    }
}
