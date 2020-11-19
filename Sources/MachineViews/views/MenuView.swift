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
            Button(action: { openDialogue = true }) {
                Image(systemName: "folder.fill")
            }
        }
    }
}
