//
//  StateExpandedView.swift
//  
//
//  Created by Morgan McColl on 15/11/20.
//

import TokamakShim

import Machines
import Attributes
import Utilities
import AttributeViews
import GUUI

struct StateExpandedView<TitleView: View>: View {
    
    var actions: [ActionViewModel]
    let titleView: () -> TitleView
    let codeView: (Int) -> ActionView
    var focused: Bool = false
    
//    init<Root: Modifiable>(root: Binding<Root>, path: Attributes.Path<Root, Machines.State>, collapsedActions: Binding<[String: Bool]>, focused: Bool = false, titleView: @escaping () -> TitleView) {
//        self.init(
//            state: Binding(
//                get: { root.wrappedValue[keyPath: path.keyPath] },
//                set: {
//                    _ = try? root.wrappedValue.modify(attribute: path, value: $0)
//                }
//            ),
//            collapsedActions: collapsedActions,
//            titleView: titleView,
//            focused: focused,
//            codeView: {
//                ActionView(action: actions[$0], collapsed: <#T##Binding<Bool>#>)
//            }
//        )
//    }
    
    init(actions: [ActionViewModel], focused: Bool = false, titleView: @escaping () -> TitleView) {
        self.init(
            actions: actions,
            titleView: titleView,
            focused: focused,
            codeView: {
                ActionView(action: actions[$0])
            }
        )
    }
    
    private init(actions: [ActionViewModel], titleView: @escaping () -> TitleView, focused: Bool = false, codeView: @escaping (Int) -> ActionView) {
        self.actions = actions
        self.titleView = titleView
        self.codeView = codeView
        self.focused = focused
    }
    
    @EnvironmentObject var config: Config
    
    fileprivate class Cache {
        var actionCache: IDCache<Action> = IDCache()
    }
    
    fileprivate var cache = Cache()
    
    var body: some View {
        Group {
            VStack {
                titleView()
                ScrollView {
                    VStack(spacing: 0) {
                        ForEach(Array(actions.indices), id: \.self) {
                            codeView($0)
                        }
                    }
                }
            }.padding(10).background(config.stateColour)
        }
        .clipShape(RoundedRectangle(cornerRadius: 20.0))
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(focused ? config.highlightColour : config.borderColour, lineWidth: 2)
        )
        
    }
}

struct StateExpandedView_Previews: PreviewProvider {
    
//    struct Root_Preview: View {
//
//        @State var modifiable: EmptyModifiable = EmptyModifiable(attributes: [
//            AttributeGroup(
//                name: "Fields", fields: [Field(name: "float", type: .float)], attributes: ["float": .float(0.1)], metaData: [:])
//        ])
//
//        let path = EmptyModifiable.path.attributes[0].attributes["float"].wrappedValue.floatValue
//
//        let config = DefaultAttributeViewsConfig()
//
//        var body: some View {
//            FloatView<DefaultAttributeViewsConfig>(
//                root: $modifiable,
//                path: path,
//                label: "Root"
//            ).environmentObject(config)
//        }
//
//    }
    
    struct Binding_Preview: View {
        
        @State var machine: Machine = Machine.initialSwiftMachine()
//
//        @State var value: Machines.State = Machines.State(
//            name: "Initial",
//            actions: [
//                Action(name: "OnEntry", implementation: "let a = 2", language: .swift),
//                Action(name: "OnExit", implementation: "let b = 3", language: .swift),
//                Action(name: "Main", implementation: "let c = 4", language: .swift),
//                Action(name: "OnSuspend", implementation: "let d = 5", language: .swift),
//                Action(name: "OnResume", implementation: "let e = 6", language: .swift)
//            ],
//            transitions: []
//        )
        
        @State var titleErrors: [String] = ["An error", "A second error"]
        
        @State var actionErrors: [[String]] = Array(repeating: [], count: 5)
        
        @State var collapsedActions: [String: Bool] = [:]
        
        let config = Config()
        
        var body: some View {
            StateExpandedView(
                actions: machine.states[0].actions.indices.map {
                    ActionViewModel(
                        machine: $machine,
                        path: machine.path.states[0].actions[$0]
                    )
                },
                focused: false
            ) {
                LineView<Config>(
                    value: $machine.states[0].name,
                    errors: $titleErrors,
                    label: "State Name"
                )
            }.environmentObject(config)
        }
        
    }
    
    static var previews: some View {
        VStack {
            //Root_Preview()
            Binding_Preview()
        }
    }
}
