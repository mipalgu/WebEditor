//
//  CodeViewWithDropDown.swift
//  
//
//  Created by Morgan McColl on 16/11/20.
//

import TokamakShim

import AttributeViews
import Attributes
import Utilities

struct CodeViewWithDropDown<Label: View>: View {
    
    @Binding var collapsed: Bool
    @Binding var hasErrors: Bool
    
    let label: () -> Label
    let codeView: () -> CodeView<Config, Text>
    
    @EnvironmentObject var config: Config
    
    init<Root: Modifiable>(root: Binding<Root>, path: Attributes.Path<Root, Code>, label: String, language: Language, collapsed: Binding<Bool>, notifier: GlobalChangeNotifier? = nil) where Label == Text {
        self.init(root: root, path: path, language: language, collapsed: collapsed, notifier: notifier) { Text(label.capitalized) }
    }
    
    init<Root: Modifiable>(root: Binding<Root>, path: Attributes.Path<Root, Code>, language: Language, collapsed: Binding<Bool>, notifier: GlobalChangeNotifier? = nil, label: @escaping () -> Label) {
        self.init(
            collapsed: collapsed,
            hasErrors: Binding(
                get: { !root.wrappedValue.errorBag.errors(forPath: path).isEmpty },
                set: { _ in }
            ),
            label: label
        ) {
            CodeView<Config, Text>(root: root, path: path, label: "", language: language, notifier: notifier)
        }
    }
    
    init(value: Binding<Code>, errors: Binding<[String]> = .constant([]), label: String, language: Language, collapsed: Binding<Bool>, delayEdits: Bool = false) where Label == Text {
        self.init(
            value: value,
            errors: errors,
            language: language,
            collapsed: collapsed,
            delayEdits: delayEdits,
            label: { Text(label.pretty) }
        )
    }
    
    init(value: Binding<Code>, errors: Binding<[String]> = .constant([]), language: Language, collapsed: Binding<Bool>, delayEdits: Bool = false, label: @escaping () -> Label) {
        self.init(
            collapsed: collapsed,
            hasErrors: Binding(
                get: { !errors.wrappedValue.isEmpty },
                set: { _ in }
            ),
            label: label
        ) {
            CodeView<Config, Text>(value: value, errors: errors, label: "", language: language, delayEdits: delayEdits)
        }
    }
    
    private init(collapsed: Binding<Bool>, hasErrors: Binding<Bool>, label: @escaping () -> Label, codeView: @escaping () -> CodeView<Config, Text>) {
        self._collapsed = collapsed
        self._hasErrors = hasErrors
        self.label = label
        self.codeView = codeView
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack(spacing: 0) {
                if hasErrors {
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
                codeView()
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

