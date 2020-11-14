//
//  SwiftUIView.swift
//  
//
//  Created by Morgan McColl on 13/11/20.
//

#if canImport(TokamakShim)
import TokamakShim
#else
import SwiftUI
#endif
import Machines
import Attributes

struct CodeView: View {
    
    @Binding var machine: Machine
    let path: Attributes.Path<Machine, Code>
    let label: String
    let language: Language
    
    var body: some View {
        VStack {
            GeometryReader { reader in
                HStack {
                    Text(label.capitalized)
                        .font(.title3)
                        .underline()
                        .background(Color.white)
                        .foregroundColor(Color.black)
                    Spacer()
                }
                .padding()
                .scaledToFit()
                TextEditor(text: Binding(get: { machine[keyPath: path.path] }, set: {
                    do {
                        try machine.modify(attribute: path, value: Code($0))
                    } catch let e {
                        print("\(e)")
                    }
                }))
                    .font(.body)
                    .padding()
                    .disableAutocorrection(true)
                    .background(Color.white)
                    .foregroundColor(Color.black)
                    .scaledToFill()
                    //.frame(width: reader.size.width, height: floor(reader.size.height * 11.0/12.0))
            }
        }
    }
}
