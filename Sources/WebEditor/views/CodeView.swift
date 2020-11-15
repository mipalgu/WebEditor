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
    
    @EnvironmentObject var config: Config
    
    var body: some View {
        GeometryReader { reader in
            VStack {
                HStack {
                    Text(label.capitalized + ":")
                        .font(.headline)
                        .underline()
                        .foregroundColor(config.textColor)
                    Spacer()
                }
                .frame(maxHeight: floor(reader.size.height * 1.0/12.0))
                TextEditor(text: Binding(get: { machine[keyPath: path.path] }, set: {
                    do {
                        try machine.modify(attribute: path, value: Code($0))
                    } catch let e {
                        print("\(e)")
                    }
                }))
                    .font(.body)
                    .foregroundColor(config.textColor)
                    .disableAutocorrection(true)
                    .overlay(
                        RoundedRectangle(cornerRadius: 5)
                            .stroke(Color.gray.opacity(0.3), lineWidth: 2)
                    )
                    .shadow(color: Color(.sRGB, red: 0, green: 0, blue: 0, opacity: 0.5), radius: 1, x: 0, y: 2)
                    .frame(width: reader.size.width, height: floor((reader.size.height - 40) * 11.0/12.0))
            }
        }
    }
}
