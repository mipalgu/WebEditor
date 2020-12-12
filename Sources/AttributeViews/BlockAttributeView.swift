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
    
    let root: Ref<Root>
    @ObservedObject var attribute: Ref<BlockAttribute>
    let subView: () -> AnyView
    
    public init(root: Ref<Root>, path: Attributes.Path<Root, BlockAttribute>, label: String) {
        self.root = root
        self.attribute = root[path: path]
        self.subView = {
            switch root[path: path].value.type {
            case .code(let language):
                return AnyView(CodeView(root: root, path: path.codeValue, label: label, language: language))
            case .text:
                return AnyView(TextView(root: root, path: path.textValue, label: label))
            case .collection(let type):
                return AnyView(CollectionView(root: root, path: path.collectionValue, label: label, type: type))
            case .table(let columns):
                return AnyView(TableView(root: root, path: path.tableValue, label: label, columns: columns))
            case .complex(let fields):
                return AnyView(ComplexView(root: root, path: path.complexValue, label: label, fields: fields))
            case .enumerableCollection(let validValues):
                return AnyView(EnumerableCollectionView(root: root, path: path.enumerableCollectionValue, label: label, validValues: validValues))
            }
        }
    }
    
    init(root: Ref<Root>, attribute: Ref<BlockAttribute>, label: String) {
        self.root = root
        self.attribute = attribute
        self.subView = {
            switch attribute.value.type {
            case .code(let language):
                return AnyView(CodeView(value: attribute.codeValue, label: label, language: language))
            case .text:
                return AnyView(TextView(value: attribute.textValue, label: label))
            case .collection(let type):
                return AnyView(CollectionView(root: root, value: attribute.collectionValue, label: label, type: type))
            case .table(let columns):
                return AnyView(TableView(root: root, value: attribute.tableValue, label: label, columns: columns))
            case .complex(let fields):
                return AnyView(ComplexView(root: root, value: attribute.complexValue, label: label, fields: fields))
            case .enumerableCollection(let validValues):
                return AnyView(EnumerableCollectionView(value: attribute.enumerableCollectionValue, label: label, validValues: validValues))
            }
        }
    }
    
    public var body: some View {
        subView()
    }
}
