//
//  EditorView.swift
//  
//
//  Created by Morgan McColl on 20/11/20.
//

#if canImport(TokamakShim)
import TokamakShim
#else
import SwiftUI
#endif
import Machines
import Attributes

struct EditorView: View {
    
    @EnvironmentObject var config: Config
    
    var body: some View {
        HStack {
            config.leftPane
            config.mainView
            config.rightPane
        }
    }
}
