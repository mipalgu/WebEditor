import Machines
import Attributes

#if canImport(TokamakDOM)
import TokamakDOM
#else
import SwiftUI
#endif

import MachineViews

struct WebEditor: App {
    
    #if !canImport(TokamakDOM) && canImport(SwiftUI)
    class AppDelegate: NSObject, NSApplicationDelegate {
        
        func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
            return true
        }
        
        func applicationWillFinishLaunching(_ notification: Notification) {
            NSApp.setActivationPolicy(.regular)
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
        ScrollView(.vertical, showsIndicators: true) {
            VStack {
                LineView(machine: $machine, path: machine.path.states[0].name, label: "State Name")
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
                //StateCollapsedView(viewModel: StateViewModel(machine: machine, path: Machine.path.states[0], location: CGPoint(x: 100, y: 100)))
                //StateExpandedView(viewModel: StateViewModel(machine: machine, path: Machine.path.states[0], location: CGPoint(x: 100, y: 100)))
                AttributeGroupsView(machine: $machine, path: Machine.path.attributes, label: "Attributes")
                //StateEditView(viewModel: StateViewModel(machine: machine, path: Machine.path.states[0], location: CGPoint(x: 100, y: 100)))
                //StateView(viewModel: StateViewModel(machine: machine, path: Machine.path.states[0], location: CGPoint(x: 100, y: 100), width: 400, height: 200, expanded: true))
                //StateView(viewModel: StateViewModel(machine: machine, path: Machine.path.states[1], location: CGPoint(x: 600, y: 600)))
                    
            }
        }
        .background(config.backgroundColor)
        .frame(width: CGFloat(config.width), height: CGFloat(config.height))
    }
}

// @main attribute is not supported in SwiftPM apps.
// See https://bugs.swift.org/browse/SR-12683 for more details.
WebEditor.main()
