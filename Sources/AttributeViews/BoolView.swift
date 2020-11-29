//
//  LineBoolView.swift
//  TokamakApp
//
//  Created by Morgan McColl on 12/11/20.
//

#if canImport(TokamakShim)
import TokamakShim
#else
import SwiftUI
#endif

import Machines
import Attributes
import Utilities

public struct BoolView: View {

    @Binding var value: Bool
    let label: String
    let onCommit: (Bool) -> Void
    
    public init(value: Binding<Bool>, label: String, onCommit: @escaping (Bool) -> Void = { _ in }) {
        self._value = value
        self.label = label
        self.onCommit = onCommit
    }
    
    @EnvironmentObject var config: Config
    
    public var body: some View {
        Toggle(label, isOn: $value)
            .animation(.easeOut)
            .font(.body)
            .foregroundColor(config.textColor)
            .onChange(of: value, perform: self.onCommit)
    }
}

