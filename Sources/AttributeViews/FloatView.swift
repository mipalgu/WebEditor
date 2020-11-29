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

public struct FloatView: View {

    @Binding var value: Double
    let label: String
    let onCommit: (Double) -> Void
    
    let formatter: Formatter = {
        let formatter = NumberFormatter()
        formatter.allowsFloats = true
        return formatter
    }()
    
    @EnvironmentObject var config: Config
    
    public init(value: Binding<Double>, label: String, onCommit: @escaping (Double) -> Void = { _ in }) {
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
