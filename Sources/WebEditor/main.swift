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
    
    var body: some Scene {
        WindowGroup("Web Editor") {
            WebEditorView().environmentObject(config)
        }.commands(content: {
            CommandGroup(replacing: .pasteboard) {
                Button("Cut") {
                    print("I'm cutting")
                }.keyboardShortcut("x", modifiers: .command)
                Button("Copy") {
                    print("I'm copying")
                }.keyboardShortcut("c", modifiers: .command)
                Button("Paste") {
                    print("I'm pasting")
                }.keyboardShortcut("v", modifiers: .command)
                Button("Delete") {
                    print("I'm deleting")
                }.keyboardShortcut(.delete)
                Button("Select All") {
                    print("I'm selecting all")
                }.keyboardShortcut("a", modifiers: .command)
            }
        })
    }
}

struct WebEditorView: View {
    
    @StateObject var viewModel: ArrangementViewModel = ArrangementViewModel(rootMachines: [Machine.initialSwiftMachine])
    
    @EnvironmentObject var config: Config
    
    var body: some View {
        VStack(alignment: .leading) {
            MenuView(machineViewModel: viewModel.currentMachine.machine)
                .background(config.stateColour)
            TabView(selection: Binding(get: { viewModel.currentMachineIndex }, set: { viewModel.currentMachineIndex = $0 })) {
                ForEach(Array(viewModel.rootMachineViewModels.indices), id: \.self) { index in
                    ContentView(editorViewModel: viewModel.rootMachineViewModels[index])
                        .tabItem {
                            Text(viewModel.rootMachineViewModels[index].machine.name)
                                .font(config.fontHeading)
                        }.tag(index)
                }
            }.background(config.backgroundColor)
        }
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
