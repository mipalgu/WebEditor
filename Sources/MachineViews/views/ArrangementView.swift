//
//  SwiftUIView.swift
//  
//
//  Created by Morgan McColl on 2/12/20.
//

#if canImport(TokamakShim)
import TokamakShim
#else
import SwiftUI
#endif

import Machines
import Attributes
import Utilities

struct ArrangementView: View {
    
    @ObservedObject var viewModel: ArrangementViewModel
    
    var body: some View {
        GeometryReader { (geometry: GeometryProxy) in
            ForEach(viewModel.machineViewModels, id: \.self) {
                Text($0.name)
                    .coordinateSpace(name: "MAIN_VIEW")
                    .position($0.location)
            }
        }
    }
}

