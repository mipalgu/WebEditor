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

struct EnumerableCollectionView: View {
    
    @ObservedObject var machine: Ref<Machine>
    let path: Attributes.Path<Machine, Set<String>>?
    let label: String
    let validValues: Set<String>
    
    @State var value: Set<String>
    
    @EnvironmentObject var config: Config
    
    init(machine: Ref<Machine>, path: Attributes.Path<Machine, Set<String>>?, label: String, validValues: Set<String>, defaultValue: Set<String> = []) {
        self.machine = machine
        self.path = path
        self.label = label
        self.validValues = validValues
        self._value = State(initialValue: path.map { machine[path: $0].value } ?? defaultValue)
    }
    
    var body: some View {
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
        }.onChange(of: value) {
            guard let path = self.path else {
                return
            }
            do {
                try machine.value.modify(attribute: path, value: $0)
                return
            } catch let e {
                print("\(e)")
            }
            self.value = machine[path: path].value
        }
    }
}
