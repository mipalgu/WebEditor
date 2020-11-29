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

public struct LineAttributeView: View {
    
    @Binding var attribute: LineAttribute
    let label: String
    let onCommit: (LineAttribute, Binding<String>) -> Void
    
    public init(attribute: Binding<LineAttribute>, label: String, onCommit: @escaping (LineAttribute, Binding<String>) -> Void = { (_, _) in }) {
        self._attribute = attribute
        self.label = label
        self.onCommit = onCommit
    }
    
    public var body: some View {
        switch attribute.type {
        case .bool:
            BoolView(value: $attribute.boolValue, label: label) {
                self.onCommit(.bool($0), $1)
            }
        case .integer:
            IntegerView(value: $attribute.integerValue, label: label) {
                self.onCommit(.integer($0), $1)
            }
        case .float:
            FloatView(value: $attribute.floatValue, label: label) {
                self.onCommit(.float($0), $1)
            }
        case .expression(let language):
            ExpressionView(value: $attribute.expressionValue, label: label, language: language) {
                self.onCommit(.expression($0, language: language), $1)
            }
        case .enumerated(let validValues):
            EnumeratedView(value: $attribute.enumeratedValue, label: label, validValues: validValues) {
                self.onCommit(.enumerated($0, validValues: validValues), $1)
            }
        case .line:
            LineView(value: $attribute.lineValue, label: label) {
                self.onCommit(.line($0), $1)
            }
        }
    }
}

