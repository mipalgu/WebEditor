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

import Attributes
import Utilities

public struct LineAttributeView<Root: Modifiable>: View {
    
    @ObservedObject var root: Ref<Root>
    @Binding var attribute: LineAttribute
    let path: Attributes.Path<Root, LineAttribute>?
    let label: String
    
    public init(root: Ref<Root>, attribute: Binding<LineAttribute>, path: Attributes.Path<Root, LineAttribute>?, label: String) {
        self.root = root
        self._attribute = attribute
        self.path = path
        self.label = label
    }
    
    public var body: some View {
        switch attribute.type {
        case .bool:
            BoolView(root: root, path: path?.boolValue, label: label)
        case .integer:
            IntegerView(root: root, path: path?.integerValue, label: label)
        case .float:
            FloatView(root: root, path: path?.floatValue, label: label)
        case .expression(let language):
            ExpressionView(root: root, path: path?.expressionValue, label: label, language: language)
        case .enumerated(let validValues):
            EnumeratedView(root: root, path: path?.enumeratedValue, label: label, validValues: validValues)
        case .line:
            LineView(root: root, path: path?.lineValue, label: label) {
                attribute = .line($0)
            }
        }
    }
}

