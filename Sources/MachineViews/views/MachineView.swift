//
//  SwiftUIView.swift
//  
//
//  Created by Morgan McColl on 24/4/21.
//

import TokamakShim
import Attributes
import Utilities
import Machines

struct MachineView: View {
    
    @ObservedObject var viewModel: MachineViewModel

    var body: some View {
        HStack {
            CanvasView(viewModel: viewModel.canvasViewModel, focus: $viewModel.focus)
            AttributesPaneView(viewModel: viewModel.attributesPaneViewModel)
        }
    }
}


//struct SwiftUIView_Previews: PreviewProvider {
//    static var previews: some View {
//        SwiftUIView()
//    }
//}
