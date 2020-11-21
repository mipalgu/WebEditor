//
//  EnumerableCollectionView.swift
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

struct EnumerableCollectionView: View {
    
    @Binding var machine: Machine
    let path: Attributes.Path<Machine, Set<String>>
    let label: String
    let validValues: Set<String>
    
    @EnvironmentObject var config: Config
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(label + ":").font(config.fontHeading).fontWeight(.bold)
            if validValues.isEmpty {
                HStack {
                    Spacer()
                    Text("There are currently no values.")
                    Spacer()
                }
            } else {
                ForEach(Array(validValues.sorted()), id: \.self) { value in
                    Toggle(value, isOn: Binding(
                        get: { machine[keyPath: path.path].contains(value) },
                        set: { (isChecked) in
                            if isChecked {
                                machine[keyPath: path.path].insert(value)
                                return
                            }
                            machine[keyPath: path.path].remove(value)
                            return
                        }
                    ))
                }
            }
        }
    }
}
