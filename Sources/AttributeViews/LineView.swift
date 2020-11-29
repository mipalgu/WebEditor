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

public struct LineView: View {
    
    @Binding var value: String
    let label: String
    let onCommit: (String) -> Void
    
    @EnvironmentObject var config: Config
    
    @State var error: String? = nil
    
    public init(value: Binding<String>, label: String, defaultValue: String = "", onCommit: @escaping (String) -> Void = { _ in }) {
        self._value = value
        self.label = label
        self.onCommit = onCommit
    }
    
    public var body: some View {
        VStack(alignment: .leading) {
            TextField(label, text: $value, onCommit: {
                self.onCommit(value)
            })
            .background(config.fieldColor)
            .foregroundColor(config.textColor)
            if let error = self.error {
                Text(error).foregroundColor(.red)
            }
        }
    }
}

//struct LineView_Preview: PreviewProvider {
//    
//    static let machine: Ref<Machine> = Ref(copying: Machine.initialSwiftMachine)
//    
//    static var previews: some View {
//        LineView(
//            machine: machine,
//            path: Machine.path.states[0].name,
//            label: "State 0"
//        ).environmentObject(Config())
//    }
//    
//}
