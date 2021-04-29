//
//  SwiftUIView.swift
//
//
//  Created by Morgan McColl on 23/11/20.
//

import TokamakShim

import Machines
import Attributes
import Utilities

struct DependenciesView: View {
    
    @Binding var focus: URL
    
    @Binding var name: String
    
    @Binding var url: URL
    
    @Binding var dependencies: [MachineDependency]
    
    @Binding var machines: [URL: Machine]
    
    @EnvironmentObject var config: Config
    
    @State var expanded: Bool = false
    
    @State var expandedDependencies: [URL: Bool] = [:]
    
    let padding: CGFloat = 10
    
    var body: some View {
        VStack {
            VStack {
                VStack {
                    Toggle(isOn: $expanded) {
                        Text(name.pretty)
                    }
                    .toggleStyle(ArrowToggleStyle())
                    .onTapGesture {
                        focus = url
                    }
                }.padding(.leading, padding)
            }.background(focus == url ? config.highlightColour : Color.clear)
            if expanded {
                ForEach(Array(dependencies.enumerated()), id: \.1) { (index, dep) in
                    DependencyView(
                        expanded: Binding(get: { expandedDependencies[dep.filePath] ?? false }, set: { expandedDependencies[dep.filePath] = $0 }),
                        focus: $focus,
                        dependency: $dependencies[index],
                        machines: $machines,
                        padding: padding + padding
                    )
                }
            }
            Spacer()
        }
    }
    
}

struct Dependencies_Previews: PreviewProvider {
    
    struct Preview: View {
        
        @State var focus: URL = Machine.initialSwiftMachine().filePath
        
        @State var name: String = "Initial Swift Machine"
        
        @State var url: URL = Machine.initialSwiftMachine().filePath
        
        @State var dependencies: [MachineDependency] = Machine.initialSwiftMachine().dependencies
        
        @State var machines: [URL: Machine] = [:]
        
        let config = Config()
        
        var body: some View {
            DependenciesView(
                focus: $focus,
                name: $name,
                url: $url,
                dependencies: $dependencies,
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
