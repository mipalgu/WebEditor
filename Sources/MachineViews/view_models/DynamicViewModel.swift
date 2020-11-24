//
//  DynamicViewModel.swift
//  
//
//  Created by Morgan McColl on 22/11/20.
//

#if canImport(TokamakShim)
import TokamakShim
#else
import SwiftUI
#endif

protocol DynamicViewModel: ObservableObject, _Moveable, _Collapsable, _BoundedSize, MoveAndStretchFromDrag, _DragableCollapsable, DragableCollapsable {}
