//
//  StateExpandedView.swift
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

struct StateExpandedView: View {
    
    @ObservedObject var viewModel: StateViewModel
    
    @EnvironmentObject var config: Config
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20.0)
                .strokeBorder(Color.black, lineWidth: 3.0, antialiased: true)
                .background(RoundedRectangle(cornerRadius: 20.0).foregroundColor(Color.white))
                .frame(width: CGFloat(viewModel.width), height: CGFloat(viewModel.height))
                .clipped()
            VStack {
                TextField(viewModel.name, text: Binding(get: { String(viewModel.name) }, set: {
                    do {
                        try viewModel.machine.modify(attribute: viewModel.path.name, value: StateName($0))
                    } catch let e {
                        print("\(e)")
                    }
                }))
                    .multilineTextAlignment(.center)
                    .font(.title2)
                    .background(config.fieldColor)
                    .foregroundColor(config.textColor)
                    .padding(.horizontal, 10)
                    .frame(width: CGFloat(viewModel.titleWidth), height: CGFloat(viewModel.titleHeight))
                    .clipped()
                ForEach(Array(viewModel.actions), id: \.0) { (action, _) in
                    CodeView(machine: $viewModel.machine, path: viewModel.path.actions[action].wrappedValue, label: action, language: .swift)
                        .padding(.horizontal, 10)
                        .frame(width: CGFloat(viewModel.width), height: CGFloat(viewModel.actionHeight))
                }
            }
        }
        .shadow(color: Color(.sRGB, red: 0, green: 0, blue: 0, opacity: 0.5), radius: 20, x: 0, y: 20)
    }
}
