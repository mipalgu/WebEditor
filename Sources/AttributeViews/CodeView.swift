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

public struct CodeView<Root: Modifiable, Label: View>: View {
    
    @ObservedObject var root: Ref<Root>
    let path: Attributes.Path<Root, Code>?
    let language: Language
    let label: () -> Label
    
    @State var value: String
    
    @EnvironmentObject var config: Config
    
    public init(root: Ref<Root>, path: Attributes.Path<Root, Code>?, label: String, language: Language, defaultValue: Code = "") where Label == Text {
        self.init(root: root, path: path, language: language, defaultValue: defaultValue) { Text(label.capitalized) }
    }
    
    public init(root: Ref<Root>, path: Attributes.Path<Root, Code>?, language: Language, defaultValue: Code = "", label: @escaping () -> Label) {
        self.root = root
        self.path = path
        self.language = language
        self.label = label
        self._value = State(initialValue: path.map { String(root[path: $0].value) } ?? String(defaultValue))
    }
    
    public var body: some View {
        VStack(alignment: .leading) {
            label()
            TextEditor(text: $value)
                .font(config.fontBody)
                .foregroundColor(config.textColor)
                .disableAutocorrection(true)
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
                        try root.value.modify(attribute: path, value: Code($0))
                        return
                    } catch let e {
                        print("\(e)")
                    }
                    self.value = String(root[path: path].value)
                }
        }
    }
}
