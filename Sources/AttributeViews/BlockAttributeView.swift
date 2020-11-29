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
    
    @ObservedObject var machine: Ref<Machine>
    @Binding var attribute: BlockAttribute
    let path: Attributes.Path<Machine, BlockAttribute>?
    let label: String
    
    public init(machine: Ref<Machine>, attribute: Binding<BlockAttribute>, path: Attributes.Path<Machine, BlockAttribute>?, label: String) {
        self.machine = machine
        self._attribute = attribute
        self.path = path
        self.label = label
    }
    
    public var body: some View {
        switch attribute.type {
        case .code(let language):
            CodeView(machine: machine, path: path?.codeValue, label: label, language: language)
        case .text:
            TextView(machine: machine, path: path?.textValue, label: label)
        case .collection(let type):
            CollectionView(machine: machine, path: path?.collectionValue, label: label, type: type)
        case .table(let columns):
            TableView(machine: machine, path: path?.tableValue, label: label, columns: columns)
        case .complex(let fields):
            ComplexView(machine: machine, path: path?.complexValue, label: label, fields: fields)
        case .enumerableCollection(let validValues):
            EnumerableCollectionView(machine: machine, path: path?.enumerableCollectionValue, label: label, validValues: validValues)
        }
    }
}
