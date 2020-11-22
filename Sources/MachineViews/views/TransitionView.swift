//
//  TransitionView.swift
//  
//
//  Created by Morgan McColl on 16/11/20.
//

#if canImport(TokamakShim)
import TokamakShim
#else
import SwiftUI
#endif
import Machines
import Attributes

struct TransitionView: View {
    
    @ObservedObject viewModel: TransitionViewModel
    
    @EnvironmentObject var config: Config
    
    var body: some View {
        Path {
            
        }
    }
}
