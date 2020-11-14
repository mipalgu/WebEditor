import Machines
import Attributes

#if canImport(TokamakDOM)
import TokamakDOM
#else
import SwiftUI
#endif





struct WebEditor: App {
    var body: some Scene {
        WindowGroup("Web Editor") {
            ContentView()
        }
    }
}

struct ContentView: View {
    
    #if canImport(TokamakDOM)
    @TokamakShim.State var machine = Machine.initialSwiftMachine
    #else
    @SwiftUI.State var machine = Machine.initialSwiftMachine
    #endif
    
    
    var body: some View {
        VStack {
            Text("Hello, world!")
            BoolView(machine: $machine, label: "Use Custom Ringlet",path: Machine.path.attributes[2].attributes["use_custom_ringlet"].wrappedValue.lineAttribute.boolValue)
            AttributeGroupView(machine: $machine, path: Machine.path.attributes[4], label: "First Attribute")
        }.frame(minWidth: 1280, minHeight: 720)
    }
}

// @main attribute is not supported in SwiftPM apps.
// See https://bugs.swift.org/browse/SR-12683 for more details.
WebEditor.main()
