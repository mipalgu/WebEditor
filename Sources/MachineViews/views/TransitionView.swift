//
//  TransitionView.swift
//  
//
//  Created by Morgan McColl on 16/11/20.
//

#if canImport(TokamakShim)
import TokamakShim
#else
import SwiftUI
#endif

import Machines
import Attributes
import Utilities
import AttributeViews

struct TransitionView: View {
    
    @Binding var machine: Machine
    
    var stateIndex: Int
    
    var transitionIndex: Int
    
    @Binding var curve: Curve
    
    let strokeNumber: UInt8
    
    var focused: Bool
    
    @EnvironmentObject var config: Config
    
    var transition: Transition? {
        get {
            guard stateIndex < machine.states.count && transitionIndex < machine.states[stateIndex].transitions.count else {
                return nil
            }
            return machine.states[stateIndex].transitions[transitionIndex]
        } set {
            guard let newValue = newValue, stateIndex < machine.states.count && transitionIndex < machine.states[stateIndex].transitions.count else {
                return
            }
            machine.states[stateIndex].transitions[transitionIndex] = newValue
        }
    }
    
    var path: Attributes.Path<Machine, Transition> {
        machine.path.states[stateIndex].transitions[transitionIndex]
    }
    
    var body: some View {
        ZStack {
            ArrowWithLabelView(
                curve: $curve,
                strokeNumber: strokeNumber,
                editing: focused,
                color: focused ? config.highlightColour : config.textColor,
                label: { Text(transition?.condition ?? "") } ,
                editLabel: { LineView<Config>(
                    value: Binding(
                        get: { transition?.condition ?? "" },
                        set: { _ = try? machine.modify(attribute: path.condition, value: Optional($0)) }
                    ),
                    errors: Binding(
                        get: { machine.errorBag.errors(includingDescendantsForPath: path.condition).map(\.message) },
                        set: { _ in }
                    ),
                    label: ""
                ) }
            )
            if focused {
                AnchorPoint(width: 20, height: 20)
                    .position(curve.point0)
                    .gesture(DragGesture().onChanged {
                        self.curve.point0 = $0.location
                    }.onEnded {
                        curve.point0 = $0.location
                    })
                AnchorPoint(color: .red)
                    .position(curve.point1)
                    .gesture(DragGesture().onChanged {
                        curve.point1 = $0.location
                    }.onEnded {
                        curve.point1 = $0.location
                    })
                AnchorPoint(color: .blue)
                    .position(curve.point2)
                    .gesture(DragGesture().onChanged {
                        curve.point2 = $0.location
                    }.onEnded {
                        curve.point2 = $0.location
                    })
                AnchorPoint(width: 20, height: 20)
                    .position(curve.point3)
                    .gesture(DragGesture().onChanged {
                        curve.point3 = $0.location
                    }.onEnded {
                        curve.point3 = $0.location
                    })
            }
        }
    }
}

//struct TransitionView_Previews: PreviewProvider {
//    
//    struct Focused_Preview: View {
//        
//        @State var point0: CGPoint = CGPoint(x: 50, y: 50)
//        @State var point1: CGPoint = CGPoint(x: 100, y: 100)
//        @State var point2: CGPoint = CGPoint(x: 150, y: 100)
//        @State var point3: CGPoint = CGPoint(x: 150, y: 50)
//        @State var strokeNumber: UInt8 = 2
//        @State var label: String = "true"
//        @State var focused: Bool = true
//        
//        let config = Config()
//        
//        var body: some View {
//            TransitionView(
//                machine: Machi
//                point0: $point0,
//                point1: $point1,
//                point2: $point2,
//                point3: $point3,
//                strokeNumber: strokeNumber,
//                focused: $focused
//            ).environmentObject(config)
//        }
//        
//    }
//    
//    struct Unfocused_Preview: View {
//        
//        @State var point0: CGPoint = CGPoint(x: 50, y: 50)
//        @State var point1: CGPoint = CGPoint(x: 100, y: 100)
//        @State var point2: CGPoint = CGPoint(x: 150, y: 100)
//        @State var point3: CGPoint = CGPoint(x: 150, y: 50)
//        @State var strokeNumber: UInt8 = 2
//        @State var label: String = "true"
//        @State var focused: Bool = false
//        
//        let config = Config()
//        
//        var body: some View {
//            TransitionView(
//                point0: $point0,
//                point1: $point1,
//                point2: $point2,
//                point3: $point3,
//                strokeNumber: $strokeNumber,
//                label: $label,
//                focused: $focused
//            ).environmentObject(config)
//        }
//        
//    }
//    
//    static var previews: some View {
//        VStack {
//            Focused_Preview()
//            Unfocused_Preview()
//        }
//    }
//}
