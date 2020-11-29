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

public struct BlockAttributeView: View{
    
    @Binding var attribute: BlockAttribute
    let label: String
    let onCommit: (BlockAttribute, Binding<String>) -> Void
    
    public init(attribute: Binding<BlockAttribute>, label: String, onCommit: @escaping (BlockAttribute, Binding<String>) -> Void = { (_, _) in }) {
        self._attribute = attribute
        self.label = label
        self.onCommit = onCommit
    }
    
    public var body: some View {
        switch attribute.type {
        case .code(let language):
            CodeView(value: $attribute.codeValue, label: label, language: language) {
                self.onCommit(.code($0, language: language), $1)
            }
        case .text:
            TextView(value: $attribute.textValue, label: label) {
                self.onCommit(.text($0), $1)
            }
        case .collection:
            EmptyView()
            //CollectionView(machine: machine, path: path?.collectionValue, label: label, type: type)
        case .table(let columns):
            TableView(value: $attribute.tableValue, label: label, columns: columns) {
                self.onCommit(.table($0, columns: columns), $1)
            }
        case .complex(let fields):
            ComplexView(value: $attribute.complexValue, label: label, fields: fields) {
                self.onCommit(.complex($0, layout: fields), $1)
            }
        case .enumerableCollection(let validValues):
            EnumerableCollectionView(value: $attribute.enumerableCollectionValue, label: label, validValues: validValues) {
                self.onCommit(.enumerableCollection($0, validValues: validValues), $1)
            }
        }
    }
}
