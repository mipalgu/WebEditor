//
//  TransitionView.swift
//  
//
//  Created by Morgan McColl on 16/11/20.
//

import TokamakShim

import MetaMachines
import Attributes
import Utilities
import AttributeViews

struct TransitionView<StrokeView: View, Label: View, EditLabel: View>: View {
    
    @ObservedObject var viewModel: TransitionTracker
    
    var focused: Bool
    
    let strokeView: (Binding<Curve>) -> StrokeView
    
    let label: () -> Label
    
    let editLabel: () -> EditLabel
    
    @EnvironmentObject var config: Config
    
    init(viewModel: TransitionTracker, focused: Bool = false, strokeView: @escaping (Binding<Curve>) -> StrokeView, label: @escaping () -> Label, editLabel: @escaping () -> EditLabel) {
        self.viewModel = viewModel
        self.focused = focused
        self.strokeView = strokeView
        self.label = label
        self.editLabel = editLabel
    }
    
    var body: some View {
        ZStack {
            ArrowWithLabelView(
                curve: $viewModel.curve,
                editing: focused,
                color: focused ? config.highlightColour : config.textColor,
                strokeView: strokeView,
                label: label,
                editLabel: editLabel
            )
            if focused {
                AnchorPoint(width: 20, height: 20)
                    .position(viewModel.curve.point0)
                    .gesture(DragGesture().onChanged {
                        viewModel.curve.point0 = $0.location
                    }.onEnded {
                        viewModel.curve.point0 = $0.location
                    })
                AnchorPoint(color: .red)
                    .position(viewModel.curve.point1)
                    .gesture(DragGesture().onChanged {
                        viewModel.curve.point1 = $0.location
                    }.onEnded {
                        viewModel.curve.point1 = $0.location
                    })
                AnchorPoint(color: .blue)
                    .position(viewModel.curve.point2)
                    .gesture(DragGesture().onChanged {
                        viewModel.curve.point2 = $0.location
                    }.onEnded {
                        viewModel.curve.point2 = $0.location
                    })
                AnchorPoint(width: 20, height: 20)
                    .position(viewModel.curve.point3)
                    .gesture(DragGesture().onChanged {
                        viewModel.curve.point3 = $0.location
                    }.onEnded {
                        viewModel.curve.point3 = $0.location
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
