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
        GeometryReader { (geometry: GeometryProxy) in
            WindowGroup("Web Editor") {
                WebEditorView(
                    viewModel: ArrangementViewModel(
                        rootMachines: [Machine.initialSwiftMachine]
                    )
                ).environmentObject(config)
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
}

struct WebEditorView: View {
    
    @StateObject var viewModel: ArrangementViewModel
    
    @EnvironmentObject var config: Config
    
    var body: some View {
        VStack(alignment: .leading) {
            MenuView(viewModel: viewModel)
                .background(config.stateColour)
            HStack {
                CollapsableAttributeGroupsView(machine: machineViewModel.$machine, path: Machine.path.attributes, label: "Dependencies", collapsed: Binding(get: {viewModel.leftPaneCollapsed}, set: {viewModel.leftPaneCollapsed = $0}), collapseLeft: true, buttonSize: 20, buttonWidth: viewModel.buttonWidth, buttonHeight: viewModel.buttonWidth)
                    .frame(width: viewModel.leftPaneWidth)
                    .position(x: viewModel.leftPaneWidth / 2.0, y: reader.size.height / 2.0)
                DividerView(
                    viewModel: ,
                    parentWidth: reader.size.width,
                    parentHeight: reader.size.width
                )
                TabView {
                    ForEach(Array(viewModel.rootMachineViewModels.indices), id: \.self) { index in
                        ContentView(editorViewModel: viewModel.rootMachineViewModels[index])
                            .tabItem {
                                Text(viewModel.rootMachineViewModels[index].machine.name)
                            }.tag(index)
                    }
                }
            }
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
