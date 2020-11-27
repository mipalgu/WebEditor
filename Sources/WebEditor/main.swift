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
    
    var config: Config = Config()
    
    @StateObject var appViewModel = AppViewModel(
        viewModels: [
            EditorViewModel(machine: MachineViewModel(machine: Ref(copying: Machine.initialSwiftMachine))),
            EditorViewModel(machine: MachineViewModel(machine: Ref(copying: Machine.initialSwiftMachine)))
        ]
    )
    
    var body: some Scene {
        WindowGroup("Web Editor") {
            ForEach(Array(appViewModel.viewModels.indices), id: \.self) { index in
                WebEditorView(viewModel: appViewModel.viewModels[index]).environmentObject(config)
            }
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
    
    @StateObject var viewModel: EditorViewModel
    
    @EnvironmentObject var config: Config
    
    var body: some View {
        ContentView(editorViewModel: viewModel)
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
    @ObservedObject var machineRef: Ref<Machine>*/
    
    @StateObject var editorViewModel: EditorViewModel
    
    var body: some View {
        EditorView(viewModel: editorViewModel, machineViewModel: editorViewModel.currentMachine)
            .background(config.backgroundColor)
            .frame(minWidth: CGFloat(config.width), minHeight: CGFloat(config.height))
            .onTapGesture(count: 1) {
                let mainView = editorViewModel.mainView
                switch mainView {
                case .machine:
                    editorViewModel.currentMachine.removeHighlights()
                    editorViewModel.changeFocus()
                case .state(let stateIndex):
                    editorViewModel.changeFocus(stateIndex: stateIndex)
                default:
                    return
                }
            }
    }
}

// @main attribute is not supported in SwiftPM apps.
// See https://bugs.swift.org/browse/SR-12683 for more details.
WebEditor.main()
