//
//  SwiftUIView.swift
//  
//
//  Created by Morgan McColl on 30/11/20.
//

#if canImport(TokamakShim)
import TokamakShim
#else
import SwiftUI
#endif

import Machines
import Attributes
import Utilities

struct DependencyView: View {
    
    @Binding var expanded: Bool
    
    @Binding var focus: Dependency
    
    @Binding var dependency: MachineDependency
    
    @Binding var machines: [URL: Machine]
    
    @State var expandedDependencies: [URL: Bool] = [:]
    
    @EnvironmentObject var config: Config
    
    func machine(for url: URL) -> Machine? {
        if let machine = machines[url] {
            return machine
        }
        guard let loadedMachine = try? Machine(filePath: url) else {
            return nil
        }
        machines[url] = loadedMachine
        return loadedMachine
    }
    
    var machineBinding: Binding<Machine>? {
        Binding(Binding(get: { machine(for: dependency.filePath) }, set: { machines[dependency.filePath] = $0 }))
    }
    
    var body: some View {
        VStack {
            Toggle(isOn: $expanded) {
                Text(dependency.name.pretty).foregroundColor(machineBinding == nil ? .red : config.fieldColor)
            }
            .toggleStyle(ArrowToggleStyle())
            .onTapGesture {
                focus = .machine(dependency.filePath)
            }
            if expanded, let binding = machineBinding {
                ForEach(Array(binding.wrappedValue.dependencies.enumerated()), id: \.1.filePath) { (index, dep) in
                    DependencyView(
                        expanded: Binding(get: { expandedDependencies[dep.filePath] ?? false }, set: { expandedDependencies[dep.filePath] = $0 }),
                        focus: $focus,
                        dependency: binding.dependencies[index],
                        machines: $machines
                    )
                }
            }
        }
        .padding(.leading, 10)
        .clipped()
    }
}

struct DependencyView_Previews: PreviewProvider {
    
    struct Preview: View {
        
        @State var expanded: Bool = false
        
        @State var focus: Dependency = .machine(URL(fileURLWithPath: "/Users/callum/src/MiPal/GUNao/fsms/nao/SwiftMachines/SoccerPlayer/Player.machine"))
        
        @State var dependency: MachineDependency = MachineDependency(name: "Initial Swift Machine", filePath: URL(fileURLWithPath: "/Users/callum/src/MiPal/GUNao/fsms/nao/SwiftMachines/SoccerPlayer/Player.machine"))
        
        @State var machines: [URL: Machine] = [:]
        
        let config = Config()
        
        var body: some View {
            DependencyView(
                expanded: $expanded,
                focus: $focus,
                dependency: $dependency,
                machines: $machines
            ).environmentObject(config)
        }
        
    }
    
    static var previews: some View {
        VStack {
            Preview()
        }
    }
}
