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

import Attributes
import Utilities

public struct EnumerableCollectionView: View {
    
    @ObservedObject var value: Ref<Set<String>>
    @StateObject var viewModel: AttributeViewModel<Set<String>>
    let label: String
    let validValues: Set<String>
    
    @EnvironmentObject var config: Config
    
    public init<Root: Modifiable>(root: Ref<Root>, path: Attributes.Path<Root, Set<String>>, label: String, validValues: Set<String>) {
        self.init(value: root[path: path], viewModel: AttributeViewModel(root: root, path: path), label: label, validValues: validValues)
    }
    
    init(value: Ref<Set<String>>, label: String, validValues: Set<String>) {
        self.init(value: value, viewModel: AttributeViewModel(reference: value), label: label, validValues: validValues)
    }
    
    init(value: Ref<Set<String>>, viewModel: AttributeViewModel<Set<String>>, label: String, validValues: Set<String>) {
        self.value = value
        self._viewModel = StateObject(wrappedValue: viewModel)
        self.label = label
        self.validValues = validValues
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
                            get: { viewModel.value.contains(value) },
                            set: { (isChecked) in
                                if isChecked {
                                    viewModel.value.insert(value)
                                } else {
                                    viewModel.value.remove(value)
                                }
                            }
                        ))
                    }
                }
            }
        }.onChange(of: value.value) {
            viewModel.value = $0
        }.onChange(of: viewModel.value) { _ in
            viewModel.sendModification()
        }
    }
}
