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
    
    var cfg: Config {
        let machineRef = Ref(copying: Machine.initialSwiftMachine)
        let path = URL(fileURLWithPath: "/Users/morgan/src/MiPal/GUNao/fsms/nao/SwiftMachines/Vision/PMTopLineSightings.machine")
        let machine = try? Machine(filePath: path)
        let plistPath = path.appendingPathComponent("Layout.plist")
        let pListData = try? String(contentsOf: plistPath)
        let newMachine = MachineViewModel(machine: Ref(copying: machine!), plist: pListData!)
        let view: ViewType = ViewType.machine(id: machineRef.value.id)
        let oldMachine = MachineViewModel(machine: machineRef)
        return Config(viewModel: EditorViewModel(
            machines: [oldMachine],
            mainView: view,
            focusedView: view
        ))
    }
    
    var body: some Scene {
        let config = cfg
        return WindowGroup("Web Editor") {
            WebEditorView().environmentObject(config)
        }.commands(content: {
            ToolbarCommands()
            CommandMenu("Edit") {
                Button("Delete") {
                    print("I'm deleting")
                }.keyboardShortcut(.delete)
            }
        })
    }
}

struct WebEditorView: View {
    
    @StateObject var machineRef: Ref<Machine> = Ref(copying: Machine.initialSwiftMachine)
    
    @EnvironmentObject var config: Config
    
    var body: some View {
        ContentView()
    }
    
}

struct ContentView: View {

//    #if canImport(TokamakDOM)
//    @TokamakShim.State var machine = Machine.initialSwiftMachine
//    #else
//    @SwiftUI.State var machine = Machine.initialSwiftMachine
//    #endif
    
    @EnvironmentObject var config: Config
    /*
    @ObservedObject var machineRef: Ref<Machine>
    
    @StateObject var editorViewModel: EditorViewModel*/
    
    var body: some View {
        EditorView(viewModel: config.viewModel, machineViewModel: config.viewModel.currentMachine)
        .background(config.backgroundColor)
        .frame(minWidth: CGFloat(config.width), minHeight: CGFloat(config.height))
        .onTapGesture(count: 1) {
            let mainView = config.viewModel.mainView
            switch mainView {
            case .machine:
                config.viewModel.currentMachine.removeHighlights()
                config.viewModel.changeFocus(machine: config.viewModel.currentMachine.id)
            case .state(_, let stateIndex):
                config.viewModel.changeFocus(machine: config.viewModel.currentMachine.id, stateIndex: stateIndex)
            default:
                return
            }
        }
    }
}

// @main attribute is not supported in SwiftPM apps.
// See https://bugs.swift.org/browse/SR-12683 for more details.
WebEditor.main()
