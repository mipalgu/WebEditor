//
//  StateEditTitleView.swift
//  
//
//  Created by Morgan McColl on 30/4/21.
//

import TokamakShim
import AttributeViews
import Utilities

struct StateEditTitleView: View {
    
    @ObservedObject var viewModel: StateTitleViewModel
    
    @EnvironmentObject var config: Config
    
    var body: some View {
        LineView<Config>(value: $viewModel.name, errors: $viewModel.errors, label: "Enter State Name...")
            .multilineTextAlignment(.center)
            .font(config.fontTitle2)
            .background(config.fieldColor)
            .foregroundColor(config.textColor)
    }
}

//struct SwiftUIView_Previews: PreviewProvider {
//    static var previews: some View {
//        SwiftUIView()
//    }
//}
