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
    
    let machines: Binding<[URL: Machine]>
    
    @Binding var width: CGFloat
    
    @EnvironmentObject var config: Config
    
    @State var expanded: Bool = false
    
    @State var expandedDependencies: [URL: Bool] = [:]
    
    let padding: CGFloat = 10
    
    var body: some View {
        VStack {
            VStack {
                HStack {
                    Toggle(isOn: $expanded) {
                        Text(name.pretty)
                    }
                    .toggleStyle(ArrowToggleStyle(side: .left))
                    .onTapGesture {
                        focus = url
                    }
                    Spacer()
                }.padding(.leading, padding)
            }.background(focus == url ? config.highlightColour : Color.clear)
            if expanded {
                VStack {
                    ForEach(Array(dependencies.enumerated()), id: \.1) { (index, dep) in
                        DependencyView(
                            expanded: Binding(get: { expandedDependencies[dep.filePath] ?? false }, set: { expandedDependencies[dep.filePath] = $0 }),
                            focus: $focus,
                            dependency: $dependencies[index],
                            machines: machines,
                            padding: padding + padding
                        )
                    }
                }.padding(.leading, padding)
            }
            Spacer()
        }.frame(width: width, alignment: .leading)
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
                machines: $machines,
                width: .constant(200)
            ).environmentObject(config)
        }
        
    }
    
    static var previews: some View {
        VStack {
            Preview()
        }
    }
}
