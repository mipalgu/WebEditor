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
            RoundedRectangle(cornerRadius: 20.0)
                .strokeBorder(Color.black, lineWidth: 3.0, antialiased: true)
                .background(RoundedRectangle(cornerRadius: 20.0).foregroundColor(Color.white))
                .frame(width: 200, height: 100)
                .padding(200.0)
                .clipped()
            VStack {
                Text(machine[keyPath: path.path].name)
                    .font(.title)
                    .clipped()
                ForEach(Array(machine[keyPath: path.path].actions), id: \.0) { (action, _) in
                    ScrollView {
                        CodeView(machine: $machine, path: path.actions[action].wrappedValue, label: action, language: .swift)
                    }.frame(width: 200, height: 100.0 / CGFloat(machine[keyPath: path.path].actions.count))
                }
            }
        }
    }
}
