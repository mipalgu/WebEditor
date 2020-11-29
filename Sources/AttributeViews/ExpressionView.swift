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

public struct ExpressionView: View {
    
    @Binding var value: Expression
    let label: String
    let language: Language
    let onCommit: (Expression, Binding<String>) -> Void
    
    @State var error: String = ""
    
    @EnvironmentObject var config: Config
    
    public init(value: Binding<Expression>, label: String, language: Language, onCommit: @escaping (Expression, Binding<String>) -> Void = { (_, _) in }) {
        self._value = value
        self.label = label
        self.language = language
        self.onCommit = onCommit
    }
    
    public var body: some View {
        VStack(alignment: .leading) {
            TextField(label, text: $value, onCommit: {
                self.onCommit(value, $error)
            })
            .font(.body)
            .background(config.fieldColor)
            .foregroundColor(config.textColor)
            Text(error).foregroundColor(.red)
        }
    }
}
