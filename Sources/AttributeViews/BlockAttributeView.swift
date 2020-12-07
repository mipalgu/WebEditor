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

public struct BlockAttributeView<Root: Modifiable>: View{
    
    @ObservedObject var root: Ref<Root>
    @Binding var attribute: BlockAttribute
    let path: Attributes.Path<Root, BlockAttribute>?
    let label: String
    
    public init(root: Ref<Root>, attribute: Binding<BlockAttribute>, path: Attributes.Path<Root, BlockAttribute>?, label: String) {
        self.root = root
        self._attribute = attribute
        self.path = path
        self.label = label
    }
    
    public var body: some View {
        switch attribute.type {
        case .code(let language):
            CodeView(root: root, path: path?.codeValue, label: label, language: language)
        case .text:
            TextView(root: root, path: path?.textValue, label: label)
        case .collection(let type):
            CollectionView(root: root, path: path?.collectionValue, label: label, type: type)
        case .table(let columns):
            TableView(root: root, path: path?.tableValue, label: label, columns: columns)
        case .complex(let fields):
            ComplexView(root: root, path: path?.complexValue, label: label, fields: fields)
        case .enumerableCollection(let validValues):
            EnumerableCollectionView(root: root, path: path?.enumerableCollectionValue, label: label, validValues: validValues)
        }
    }
}
