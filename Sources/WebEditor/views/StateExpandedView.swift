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
    
    @EnvironmentObject var config: Config
    
    var body: some View {
        GeometryReader { reader in
            ZStack {
                RoundedRectangle(cornerRadius: 20.0)
                    .strokeBorder(Color.black, lineWidth: 3.0, antialiased: true)
                    .background(RoundedRectangle(cornerRadius: 20.0).foregroundColor(Color.white))
                    .frame(width: reader.size.width, height: reader.size.height)
                    .clipped()
                VStack {
                    TextField(machine[keyPath: path.path].name, text: Binding(get: { String(machine[keyPath: path.path].name) }, set: {
                        do {
                            try machine.modify(attribute: path.name, value: StateName($0))
                        } catch let e {
                            print("\(e)")
                        }
                    }))
                        .multilineTextAlignment(.center)
                        .font(.title2)
                        .background(config.fieldColor)
                        .foregroundColor(config.textColor)
                    .padding(.horizontal, 10)
                        .padding(.top, 20)
                        .frame(maxHeight: reader.size.height / 12.0)
                        .clipped()
                    ForEach(Array(machine[keyPath: path.path].actions.sorted { $0.0 < $1.0 }), id: \.0) { (action, _) in
                        CodeView(machine: $machine, path: path.actions[action].wrappedValue, label: action, language: .swift)
                            .padding(.horizontal, 10)
                            .frame(width: reader.size.width, height: (floor((reader.size.height) * 11.0 / 12.0)) / CGFloat(machine[keyPath: path.path].actions.count))
                    }
                }
            }
        }
        .shadow(color: Color(.sRGB, red: 0, green: 0, blue: 0, opacity: 0.5), radius: 20, x: 0, y: 20)
    }
}
