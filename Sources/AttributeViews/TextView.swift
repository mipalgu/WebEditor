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

public struct TextView<Root: Modifiable>: View {
    
    @ObservedObject var root: Ref<Root>
    let path: Attributes.Path<Root, String>?
    let label: String
    
    @State var value: String
    
    @EnvironmentObject var config: Config
    
    public init(root: Ref<Root>, path: Attributes.Path<Root, String>?, label: String, defaultValue: String = "") {
        self.root = root
        self.path = path
        self.label = label
        self._value = State(initialValue: path.map { root[path: $0].value } ?? defaultValue)
    }
    
    public var body: some View {
        VStack(alignment: .leading) {
            Text(label.capitalized)
                .font(.headline)
                .foregroundColor(config.textColor)
            TextEditor(text: $value)
                .font(.body)
                .foregroundColor(config.textColor)
                .disableAutocorrection(false)
                .overlay(
                    RoundedRectangle(cornerRadius: 5)
                        .stroke(Color.gray.opacity(0.3), lineWidth: 2)
                )
                .frame(minHeight: 80)
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
}
