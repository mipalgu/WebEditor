//
//  StateExpandedView.swift
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

struct StateExpandedView: View {
    
    @Binding var machine: Machine
    let path: Attributes.Path<Machine, Machines.State>
    
    var body: some View {
        ZStack {
            GeometryReader { reader in
                RoundedRectangle(cornerRadius: 20.0)
                    .strokeBorder(Color.black, lineWidth: 3.0, antialiased: true)
                    .background(RoundedRectangle(cornerRadius: 20.0).foregroundColor(Color.white))
                    .frame(width: reader.size.width, height: reader.size.height)
                    .clipped()
                VStack {
                    Text(machine[keyPath: path.path].name)
                        .font(.title2)
                        .foregroundColor(Color.black)
                        .frame(maxHeight: reader.size.height / 12.0)
                        .clipped()
                    ForEach(Array(machine[keyPath: path.path].actions), id: \.0) { (action, _) in
                        ScrollView {
                            CodeView(machine: $machine, path: path.actions[action].wrappedValue, label: action, language: .swift)
                                .frame(width: reader.size.width, height: (floor(reader.size.height * 11.0 / 12.0)) / CGFloat(machine[keyPath: path.path].actions.count))
                        }
                    }
                }
            }
        }
        .shadow(color: Color(.sRGB, red: 0, green: 0, blue: 0, opacity: 0.5), radius: 10, x: 0, y: 2)
    }
}
