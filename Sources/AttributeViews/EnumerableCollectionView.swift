//
//  EnumerableCollectionView.swift
//  
//
//  Created by Morgan McColl on 16/11/20.
//

#if canImport(TokamakShim)
import TokamakShim
#else
import SwiftUI
#endif

import Machines
import Attributes
import Utilities

public struct EnumerableCollectionView: View {
    
    @Binding var value: Set<String>
    let label: String
    let validValues: Set<String>
    let onCommit: (Set<String>) -> Void
    
    @EnvironmentObject var config: Config
    
    public init(value: Binding<Set<String>>, label: String, validValues: Set<String>, onCommit: @escaping (Set<String>) -> Void = { _ in }) {
        self._value = value
        self.label = label
        self.validValues = validValues
        self.onCommit = onCommit
    }
    
    public var body: some View {
        VStack(alignment: .leading) {
            Text(label + ":").font(config.fontHeading).fontWeight(.bold)
            if validValues.isEmpty {
                HStack {
                    Spacer()
                    Text("There are currently no values.")
                    Spacer()
                }
            } else {
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 100, maximum: .infinity), spacing: 10, alignment: .topLeading)]) {
                    ForEach(Array(validValues.sorted()), id: \.self) { value in
                        Toggle(value, isOn: Binding(
                            get: { self.value.contains(value) },
                            set: { (isChecked) in
                                if isChecked {
                                    self.value.insert(value)
                                } else {
                                    self.value.remove(value)
                                }
                            }
                        ))
                    }
                }
            }
        }.onChange(of: value, perform: self.onCommit)
    }
}
