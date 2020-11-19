//
//  MenuView.swift
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

struct MenuView: View {
    
    @State var openDialogue: Bool = false
    
    var body: some View {
        HStack {
            Button(action: {  }) {
                // New Machine
                Image(systemName: "folder.fill.badge.plus")
            }
            Button(action: { openDialogue = true }) {
                // Open Machine
                Image(systemName: "folder.fill")
            }
            Button(action: {  }) {
                // Save Machine
                Image(systemName: "folder.circle")
            }
            Button(action: {  }) {
                // Save-As
                Image(systemName: "folder.circle.fill")
            }
        }
    }
}