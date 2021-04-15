//
//  CodeViewWithDropDown.swift
//  
//
//  Created by Morgan McColl on 16/11/20.
//

#if canImport(TokamakShim)
import TokamakShim
#else
import SwiftUI
#endif

import Attributes
import Utilities

struct CodeViewWithDropDown<Label: View>: View {
    
    @Binding var value: Code
    @Binding var errors: [String]
    let language: Language
    let label: () -> Label
    
    @Binding var collapsed: Bool
    
    @EnvironmentObject var config: Config
    
    init<Root: Modifiable>(root: Binding<Root>, path: Attributes.Path<Root, Code>, label: String, language: Language, collapsed: Binding<Bool>) where Label == Text {
        self.init(root: root, path: path, language: language, collapsed: collapsed) { Text(label.capitalized) }
    }
    
    init<Root: Modifiable>(root: Binding<Root>, path: Attributes.Path<Root, Code>, language: Language, collapsed: Binding<Bool>, label: @escaping () -> Label) {
        self.init(
            value: Binding(
                get: { root.wrappedValue[keyPath: path.keyPath] },
                set: {
                    _ = try? root.wrappedValue.modify(attribute: path, value: $0)
                }
            ),
            errors: Binding(
                get: { root.wrappedValue.errorBag.errors(forPath: path).map(\.message) },
                set: { _ in }
            ),
            language: language,
            collapsed: collapsed,
            label: label
        )
    }
    
    init(value: Binding<Code>, errors: Binding<[String]> = .constant([]), label: String, language: Language, collapsed: Binding<Bool>) where Label == Text {
        self.init(
            value: value,
            errors: errors,
            language: language,
            collapsed: collapsed,
            label: { Text(label.pretty) }
        )
    }
    
    init(value: Binding<Code>, errors: Binding<[String]> = .constant([]), language: Language, collapsed: Binding<Bool>, label: @escaping () -> Label) {
        self._value = value
        self._errors = errors
        self.language = language
        self._collapsed = collapsed
        self.label = label
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack(spacing: 0) {
                if !errors.isEmpty {
                    Text("*").foregroundColor(.red)
                }
                label()
                Button(action: { collapsed = !collapsed }) {
                    Image(systemName: collapsed ? "arrowtriangle.right.fill" : "arrowtriangle.down.fill")
                        .font(.system(size: 8.0, weight: .regular))
                        .frame(width: 12.0, height: 12.0)
                }.buttonStyle(PlainButtonStyle())
                Spacer()
            }
            if !collapsed {
                ForEach(errors, id: \.self) { error in
                    Text(error).foregroundColor(.red)
                }
                TextEditor(text: $value)
                    .font(config.fontBody)
                    .foregroundColor(config.textColor)
                    .disableAutocorrection(true)
                    .overlay(
                        RoundedRectangle(cornerRadius: 5)
                            .stroke(Color.gray.opacity(0.3), lineWidth: 2)
                    )
                    .frame(minHeight: 80)
            }
        }
    }
    
}

struct CodeViewWithDropDown_Previews: PreviewProvider {
    
    struct Root_Preview: View {
        
        @State var modifiable: EmptyModifiable = EmptyModifiable(attributes: [
            AttributeGroup(
                name: "Fields", fields: [Field(name: "code", type: .code(language: .swift))], attributes: ["code": .code("print(\"Hello World!\")", language: .swift)], metaData: [:])
        ])
        
        let path = EmptyModifiable.path.attributes[0].attributes["code"].wrappedValue.codeValue
        
        let config = Config()
        
        @State var collapsed: Bool = false
        
        var body: some View {
            CodeViewWithDropDown(
                root: $modifiable,
                path: path,
                label: "Root",
                language: .swift,
                collapsed: $collapsed
            ).environmentObject(config)
        }
        
    }
    
    struct Binding_Preview: View {
        
        @State var value: Code = "print(\"Hello World!\")"
        @State var errors: [String] = ["An error", "A second error"]
        @State var collapsed: Bool = false
        
        let config = Config()
        
        var body: some View {
            CodeViewWithDropDown(
                value: $value,
                errors: $errors,
                label: "Binding",
                language: .swift,
                collapsed: $collapsed
            ).environmentObject(config)
        }
        
    }
    
    static var previews: some View {
        VStack {
            Root_Preview()
            Binding_Preview()
        }
    }
}

