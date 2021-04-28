//
//  SwiftUIView.swift
//  
//
//  Created by Morgan McColl on 30/11/20.
//

import TokamakShim

import Machines
import Attributes
import Utilities

struct DependencyView: View {
    
    @Binding var expanded: Bool
    
    @Binding var focus: URL
    
    @Binding var dependency: MachineDependency
    
    @Binding var machines: [URL: Machine]
    
    @State var expandedDependencies: [URL: Bool] = [:]
    
    let padding: CGFloat
    
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
            VStack {
                Toggle(isOn: $expanded) {
                    Text(dependency.name.pretty)
                        .foregroundColor(machineBinding == nil ? .red : config.textColor)
                }
                .toggleStyle(ArrowToggleStyle())
                .onTapGesture {
                    focus = dependency.filePath
                }
                
            }.padding(.leading, 10)
            .background(focus == dependency.filePath ? config.highlightColour : Color.clear)
            if expanded, let binding = machineBinding {
                ForEach(Array(binding.wrappedValue.dependencies.enumerated()), id: \.1.filePath) { (index, dep) in
                    DependencyView(
                        expanded: Binding(get: { expandedDependencies[dep.filePath] ?? false }, set: { expandedDependencies[dep.filePath] = $0 }),
                        focus: $focus,
                        dependency: binding.dependencies[index],
                        machines: $machines,
                        padding: padding + padding
                    )
                }
            }
        }
    }
}

struct DependencyView_Previews: PreviewProvider {
    
    struct Preview: View {
        
        @State var expanded: Bool = false
        
        @State var focus: URL = Machine.initialSwiftMachine().filePath
        
        @State var dependency: MachineDependency = MachineDependency(name: "Initial Swift Machine", filePath: Machine.initialSwiftMachine().filePath)
        
        @State var machines: [URL: Machine] = [:]
        
        let config = Config()
        
        var body: some View {
            DependencyView(
                expanded: $expanded,
                focus: $focus,
                dependency: $dependency,
                machines: $machines,
                padding: 10
            ).environmentObject(config)
        }
        
    }
    
    static var previews: some View {
        VStack {
            Preview()
        }
    }
}
