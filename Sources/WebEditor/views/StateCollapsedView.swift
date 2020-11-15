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
    
    @EnvironmentObject var config: Config
    
    var body: some View {
        GeometryReader { reader in
            ZStack {
                Ellipse()
                    .strokeBorder(Color.black, lineWidth: 2.0, antialiased: true)
                    .background(config.backgroundColor)
                    .padding(.bottom, 2)
                    .frame(width: reader.size.width, height: reader.size.height)
                    .shadow(color: Color(.sRGB, red: 0, green: 0, blue: 0, opacity: 0.5), radius: 5, x: 0, y: 2)
                    .clipped()
                Text(machine[keyPath: path.path].name)
                    .font(.title2)
                    .background(Color.white)
                    .foregroundColor(Color.black)
                    .clipped()
            }
        }
        
    }
}
