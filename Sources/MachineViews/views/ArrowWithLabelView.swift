//
//  SwiftUIView.swift
//  
//
//  Created by Morgan McColl on 2/12/20.
//

#if canImport(TokamakShim)
import TokamakShim
#else
import SwiftUI
#endif

import Utilities

struct ArrowWithLabelView<LabelView: View, EditLabelView: View>: View {
    
    @Binding var curve: Curve
    
    let strokeNumber: UInt8
    
    var editing: Bool
    
    var color: Color
    
    let label: () -> LabelView
    
    let editLabel: () -> EditLabelView
    
//    @EnvironmentObject public var config: Config
    
    var center: CGPoint {
        let dx = (curve.point2.x - curve.point1.x) / 2.0
        let dy = (curve.point2.y - curve.point1.y) / 2.0
        return CGPoint(x: curve.point1.x + dx, y: curve.point1.y + dy)
    }
    
    var body: some View {
        ZStack {
            ArrowView(curve: $curve, strokeNumber: strokeNumber, colour: color)
            if editing {
//                TextField("", text: $label)
//                    .font(config.fontBody)
                editLabel()
                    .fixedSize()
                    .position(center)
            } else {
//                Text(label)
//                    .font(config.fontBody.italic())
                label()
                    .fixedSize()
                    .position(center)
            }
        }
    }
}

struct ArrowWithLabelView_Previews: PreviewProvider {
    
    struct Editing_Preview: View {
        
        @State var curve = Curve(
            point0: CGPoint(x: 50, y: 50),
            point1: CGPoint(x: 100, y: 100),
            point2: CGPoint(x: 150, y: 100),
            point3: CGPoint(x: 150, y: 50)
        )
        
        let strokeNumber: UInt8 = 2
        @State var label: String = "true"
        var editing: Bool = true
        let color: Color = .black
        
        let config = Config()
        
        var body: some View {
            ArrowWithLabelView(
                curve: $curve,
                strokeNumber: strokeNumber,
                editing: editing,
                color: color,
                label: { Text(label) },
                editLabel: { TextField("", text: $label) }
            ).environmentObject(config)
        }
        
    }
    
    struct NotEditing_Preview: View {
        
        @State var curve = Curve(
            point0: CGPoint(x: 50, y: 50),
            point1: CGPoint(x: 100, y: 100),
            point2: CGPoint(x: 150, y: 100),
            point3: CGPoint(x: 150, y: 50)
        )
        
        let strokeNumber: UInt8 = 2
        @State var label: String = "true"
        var editing: Bool = false
        let color: Color = .black
        
        let config = Config()
        
        var body: some View {
            ArrowWithLabelView(
                curve: $curve,
                strokeNumber: strokeNumber,
                editing: editing,
                color: color,
                label: { Text(label) },
                editLabel: { TextField("", text: $label) }
            ).environmentObject(config)
        }
        
    }
    
    static var previews: some View {
        VStack {
            Editing_Preview()
            NotEditing_Preview()
        }
    }
}
