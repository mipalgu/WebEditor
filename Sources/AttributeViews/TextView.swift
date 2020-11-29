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
import Utilities

public struct TextView: View {
    
    @Binding var value: String
    let label: String
    let onCommit: (String, Binding<String>) -> Void
    
    @State var error: String = ""
    
    @EnvironmentObject var config: Config
    
    public init(value: Binding<String>, label: String, onCommit: @escaping (String, Binding<String>) -> Void = { (_, _) in }) {
        self._value = value
        self.label = label
        self.onCommit = onCommit
    }
    
    public var body: some View {
        VStack(alignment: .leading) {
            Text(label.capitalized)
                .font(.headline)
                .foregroundColor(config.textColor)
            TextEditor(text: $value)
                .font(.body)
                .foregroundColor(config.textColor)
                .disableAutocorrection(false)
                .overlay(
                    RoundedRectangle(cornerRadius: 5)
                        .stroke(Color.gray.opacity(0.3), lineWidth: 2)
                )
                .frame(minHeight: 80)
                .onChange(of: value) {
                    self.onCommit($0, $error)
                }
            Text(error).foregroundColor(.red)
        }
    }
}
