//
//  StateCollapsedview.swift
//  
//
//  Created by Morgan McColl on 15/11/20.
//

#if canImport(TokamakShim)
import TokamakShim
#else
import SwiftUI
#endif

import Machines
import Attributes
import Utilities

struct StateCollapsedView<TitleView: View>: View {
    
    let titleView: () -> TitleView
    
    @EnvironmentObject var config: Config
    
    var body: some View {
        Group {
            VStack {
                titleView()
            }.padding(15).background(config.stateColour)
        }.clipShape(Ellipse())
    }
    
}
