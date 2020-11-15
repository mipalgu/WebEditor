import Machines
import Attributes

#if canImport(TokamakDOM)
import TokamakDOM
#else
import SwiftUI
#endif

struct WebEditor: App {
    
    #if !canImport(TokamakDOM) && canImport(SwiftUI)
    class AppDelegate: NSObject, NSApplicationDelegate {
        
        func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
            return true
        }
        
    }
    
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate: AppDelegate
    #endif
    
    var body: some Scene {
        WindowGroup("Web Editor") {
            ContentView().environmentObject(Config())
        }
    }
}

struct ContentView: View {
    
    #if canImport(TokamakDOM)
    @TokamakShim.State var machine = Machine.initialSwiftMachine
    #else
    @SwiftUI.State var machine = Machine.initialSwiftMachine
    #endif
    
    @EnvironmentObject var config: Config
    
    var body: some View {
        ScrollView {
            VStack {
                /*HStack {
                    StateEditView(machine: $machine, path: Machine.path.states[0])
                        .frame(minWidth: 900)
                    ScrollView(.horizontal, showsIndicators: true) {
                        AttributeGroupsView(machine: $machine, path: Machine.path.states[0].attributes, label: "All Attributes")
                            .frame(minWidth: 500)
                    }
                }*/
                //CodeView(machine: $machine, path: Machine.path.states[0].actions["main"].wrappedValue, label: "OnEntry", language: .swift)
                //    .scaledToFit()
                //StateCollapsedView(machine: $machine, path: Machine.path.states[0])
                StateExpandedView(machine: $machine, path: Machine.path.states[1])
                //StateEditView(machine: $machine, path: Machine.path.states[0])
                    
            }
            .frame(minWidth: 1650, minHeight: 720)
            .background(config.backgroundColor)
            .padding([.all], 50)
        }
        .background(config.backgroundColor)
        
    }
}

// @main attribute is not supported in SwiftPM apps.
// See https://bugs.swift.org/browse/SR-12683 for more details.
WebEditor.main()
