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
            WebEditorView().environmentObject(Config())
        }
    }
}

struct WebEditorView: View {
    
    @StateObject var machineRef: Ref<Machine> = Ref(copying: Machine.initialSwiftMachine)
    
    @EnvironmentObject var config: Config
    
    var body: some View {
        ContentView(machineRef: machineRef)
    }
    
}

struct ContentView: View {

//    #if canImport(TokamakDOM)
//    @TokamakShim.State var machine = Machine.initialSwiftMachine
//    #else
//    @SwiftUI.State var machine = Machine.initialSwiftMachine
//    #endif
    
    @EnvironmentObject var config: Config
    
    @ObservedObject var machineRef: Ref<Machine>
    
    @StateObject var editorViewModel: EditorViewModel
    
    init(machineRef: Ref<Machine>) {
        self.machineRef = machineRef
        let path = URL(fileURLWithPath: "/Users/morgan/src/MiPal/GUNao/fsms/nao/SwiftMachines/Vision/PMTopLineSightings.machine")
        let machine = try? Machine(filePath: path)
        let plistPath = path.appendingPathComponent("Layout.plist")
        let pListData = try? String(contentsOf: plistPath)
        let newMachine = MachineViewModel(machine: Ref(copying: machine!), plist: pListData!)
        let view: ViewType = ViewType.machine(id: machineRef.value.id)
        let oldMachine = MachineViewModel(machine: machineRef)
        self._editorViewModel = StateObject(wrappedValue: EditorViewModel(
            machines: [oldMachine],
            mainView: view,
            focusedView: view
        ))
    }
    
    var body: some View {
        VStack {
            //LineView(machine: $machine, path: machine.path.states[0].name, label: "State Name")
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
            //AttributeGroupsView(machine: machineRef.asBinding, path: Machine.path.attributes, label: "Attributes")
            //StateEditView(viewModel: StateViewModel(machine: machineRef, path: Machine.path.states[0], location: CGPoint(x: 100, y: 100)))
            //StateView(viewModel: StateViewModel(machine: machineRef, path: Machine.path.states[1], location: CGPoint(x: 600, y: 600)))
            //StateView(viewModel: StateViewModel(machine: machineRef, path: Machine.path.states[1], location: CGPoint(x: 100, y: 100), width: 300, height: 100, expanded: true))
            EditorView(viewModel: editorViewModel, machineViewModel: editorViewModel.machines[0])
        }
        .background(config.backgroundColor)
        .frame(minWidth: CGFloat(config.width), minHeight: CGFloat(config.height))
        .onTapGesture(count: 1) {
            let mainView = editorViewModel.mainView
            switch mainView {
            case .machine:
                editorViewModel.currentMachine.removeHighlights()
                editorViewModel.changeFocus(machine: editorViewModel.currentMachine.id)
            case .state(_, let stateIndex):
                editorViewModel.changeFocus(machine: editorViewModel.currentMachine.id, stateIndex: stateIndex)
            default:
                return
            }
        }
    }
}

// @main attribute is not supported in SwiftPM apps.
// See https://bugs.swift.org/browse/SR-12683 for more details.
WebEditor.main()
