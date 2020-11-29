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

public struct CodeView<Label: View>: View {
    
    @Binding var value: Code
    let language: Language
    let label: () -> Label
    let onCommit: (Code, Binding<String>) -> Void
    
    @State var error: String = ""
    
    @EnvironmentObject var config: Config
    
    public init(value: Binding<Code>, label: String, language: Language, onCommit: @escaping (Code, Binding<String>) -> Void = { (_, _) in }) where Label == Text {
        self.init(value: value, language: language, label: { Text(label.capitalized) }, onCommit: onCommit)
    }
    
    public init(value: Binding<Code>, language: Language, label: @escaping () -> Label, onCommit: @escaping (Code, Binding<String>) -> Void = { (_, _) in }) {
        self._value = value
        self.language = language
        self.label = label
        self.onCommit = onCommit
    }
    
    public var body: some View {
        VStack(alignment: .leading) {
            label()
            TextEditor(text: $value)
                .font(config.fontBody)
                .foregroundColor(config.textColor)
                .disableAutocorrection(true)
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
