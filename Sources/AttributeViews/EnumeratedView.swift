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

public struct EnumeratedView<Root: Modifiable>: View {
    
    @ObservedObject var root: Ref<Root>
    let path: Attributes.Path<Root, String>?
    let label: String
    let validValues: Set<String>
    
    @State var value: String
    
    @EnvironmentObject var config: Config
    
    public init(root: Ref<Root>, path: Attributes.Path<Root, String>?, label: String, validValues: Set<String>, defaultValue: String? = nil) {
        self.root = root
        self.path = path
        self.label = label
        self.validValues = validValues
        self._value = State(initialValue: path.map { root[path: $0].value } ?? defaultValue ?? validValues.sorted().first ?? "")
    }
    
    public var body: some View {
        Picker(label, selection: $value) {
            ForEach(validValues.sorted(), id: \.self) {
                Text($0).tag($0)
                    .foregroundColor(config.textColor)
            }
        }.pickerStyle(InlinePickerStyle())
        .onChange(of: value) {
            guard let path = self.path else {
                return
            }
            do {
                try root.value.modify(attribute: path, value: $0)
                return
            } catch let e {
                print("\(e)")
            }
            self.value = root[path: path].value
        }
    }
}
