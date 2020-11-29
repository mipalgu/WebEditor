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

public struct EnumeratedView: View {
    
    @Binding var value: String
    let label: String
    let validValues: Set<String>
    let onCommit: (String) -> Void
    
    @EnvironmentObject var config: Config
    
    public init(value: Binding<String>, label: String, validValues: Set<String>, onCommit: @escaping (String) -> Void = { _ in }) {
        self._value = value
        self.label = label
        self.validValues = validValues
        self.onCommit = onCommit
    }
    
    public var body: some View {
        Picker(label, selection: $value) {
            ForEach(validValues.sorted(), id: \.self) {
                Text($0).tag($0)
                    .foregroundColor(config.textColor)
            }
        }.pickerStyle(InlinePickerStyle())
        .onChange(of: value, perform: self.onCommit)
    }
}
