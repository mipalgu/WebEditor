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

public struct IntegerView: View {
    
    @Binding var value: Int
    let label: String
    let onCommit: (Int) -> Void
    
    let formatter: Formatter = {
        let formatter = NumberFormatter()
        formatter.allowsFloats = false
        return formatter
    }()
    
    @EnvironmentObject var config: Config
    
    public init(value: Binding<Int>, label: String, onCommit: @escaping (Int) -> Void = { _ in }) {
        self._value = value
        self.label = label
        self.onCommit = onCommit
    }
    
    public var body: some View {
        TextField(label, value: $value, formatter: formatter, onCommit: {
            self.onCommit(value)
        })
        .font(.body)
        .background(config.fieldColor)
        .foregroundColor(config.textColor)
    }
}
