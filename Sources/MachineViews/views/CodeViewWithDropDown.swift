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
    
    @Binding var expanded: Bool
    @Binding var hasErrors: Bool
    
    let label: () -> Label
    let codeView: () -> CodeView<Config, Text>
    
    @EnvironmentObject var config: Config
    
    init<Root: Modifiable>(root: Binding<Root>, path: Attributes.Path<Root, Code>, label: String, language: Language, expanded: Binding<Bool>, notifier: GlobalChangeNotifier? = nil) where Label == Text {
        self.init(root: root, path: path, language: language, expanded: expanded, notifier: notifier) { Text(label.capitalized) }
    }
    
    init<Root: Modifiable>(root: Binding<Root>, path: Attributes.Path<Root, Code>, language: Language, expanded: Binding<Bool>, notifier: GlobalChangeNotifier? = nil, label: @escaping () -> Label) {
        self.init(
            expanded: expanded,
            hasErrors: Binding(
                get: { !root.wrappedValue.errorBag.errors(forPath: path).isEmpty },
                set: { _ in }
            ),
            label: label
        ) {
            CodeView<Config, Text>(root: root, path: path, label: "", language: language, notifier: notifier)
        }
    }
    
    init(value: Binding<Code>, errors: Binding<[String]> = .constant([]), label: String, language: Language, expanded: Binding<Bool>, delayEdits: Bool = false) where Label == Text {
        self.init(
            value: value,
            errors: errors,
            language: language,
            expanded: expanded,
            delayEdits: delayEdits,
            label: { Text(label.pretty) }
        )
    }
    
    init(value: Binding<Code>, errors: Binding<[String]> = .constant([]), language: Language, expanded: Binding<Bool>, delayEdits: Bool = false, label: @escaping () -> Label) {
        self.init(
            expanded: expanded,
            hasErrors: Binding(
                get: { !errors.wrappedValue.isEmpty },
                set: { _ in }
            ),
            label: label
        ) {
            CodeView<Config, Text>(value: value, errors: errors, label: "", language: language, delayEdits: delayEdits)
        }
    }
    
    private init(expanded: Binding<Bool>, hasErrors: Binding<Bool>, label: @escaping () -> Label, codeView: @escaping () -> CodeView<Config, Text>) {
        self._expanded = expanded
        self._hasErrors = hasErrors
        self.label = label
        self.codeView = codeView
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            DisclosureGroup(isExpanded: $expanded, content: {
                codeView().padding(.top, -10)
            }) {
                HStack(spacing: 0) {
                    if hasErrors {
                        Text("*").foregroundColor(.red)
                    }
                    label()
                }.frame(alignment: .leading)
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
        
        @State var expanded: Bool = true
        
        var body: some View {
            CodeViewWithDropDown(
                root: $modifiable,
                path: path,
                label: "Root",
                language: .swift,
                expanded: $expanded
            ).environmentObject(config)
        }
        
    }
    
    struct Binding_Preview: View {
        
        @State var value: Code = "print(\"Hello World!\")"
        @State var errors: [String] = ["An error", "A second error"]
        @State var expanded: Bool = true
        
        let config = Config()
        
        var body: some View {
            CodeViewWithDropDown(
                value: $value,
                errors: $errors,
                label: "Binding",
                language: .swift,
                expanded: $expanded
            ).environmentObject(config)
        }
        
    }
    
    static var previews: some View {
        VStack {
            Root_Preview()
            Binding_Preview()
        }.padding(10)
    }
}

