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
    
    let machines: Binding<[URL: Machine]>
    
    @State var expandedDependencies: [URL: Bool] = [:]
    
    let padding: CGFloat
    
    @EnvironmentObject var config: Config
    
    func machine(for url: URL) -> Machine? {
        if let machine = machines.wrappedValue[url] {
            return machine
        }
        guard let loadedMachine = try? Machine(filePath: url) else {
            return nil
        }
        machines.wrappedValue[url] = loadedMachine
        return loadedMachine
    }
    
    var machineBinding: Binding<Machine>? {
        Binding(Binding(get: { machine(for: dependency.filePath) }, set: { machines.wrappedValue[dependency.filePath] = $0 }))
    }
    
    var body: some View {
        VStack {
            HStack {
                if let machineBinding = machineBinding, !machineBinding.wrappedValue.dependencies.isEmpty {
                    Toggle(isOn: $expanded) {
                        Text(dependency.name.pretty).foregroundColor(config.textColor)
                    }
                    .toggleStyle(ArrowToggleStyle(side: .left))
                    .onTapGesture {
                        focus = dependency.filePath
                    }
                } else {
                    Text(dependency.name.pretty)
                        .foregroundColor(.red)
                        .onTapGesture {
                            focus = dependency.filePath
                        }
                }
                Spacer()
            }.padding(.leading, 10)
            .background(focus == dependency.filePath ? config.highlightColour : Color.clear)
            if expanded, let binding = machineBinding {
                VStack {
                    ForEach(Array(binding.wrappedValue.dependencies.enumerated()), id: \.1.filePath) { (index, dep) in
                        DependencyView(
                            expanded: Binding(get: { expandedDependencies[dep.filePath] ?? false }, set: { expandedDependencies[dep.filePath] = $0 }),
                            focus: $focus,
                            dependency: binding.dependencies[index],
                            machines: machines,
                            padding: padding + padding
                        )
                    }
                }.padding(.leading, 10)
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
