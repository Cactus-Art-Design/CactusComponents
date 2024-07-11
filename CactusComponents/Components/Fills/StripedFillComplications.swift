//
//  StripedFillComplications.swift
//  CactusComponents
//
//  Created by Brian Masse on 7/11/24.
//

import Foundation
import SwiftUI

struct StripedFillComplication: View {
    
    struct RotationNodeData {
        let angle: Double
        let size: CGSize
        
        let xAxis: Double
        let yAxis: Double
        let zAxis: Double
        
        let perspective: Double
        
        init( _ size: CGSize, at angle: Double = 0, perspective: Double = 0, x: Double = 0, y: Double = 0, z: Double = 0 ) {
            self.angle = angle
            self.size = size
            self.perspective = perspective
            self.xAxis = x
            self.yAxis = y
            self.zAxis = z
        }
        
        func getScaleForNextNode() -> Double {
            
            let angle = (Double.pi * angle) / 180
            
            return 1 - (1/2) * pow( self.angle / 90, 0.52 )
            
//            return 0
        }
        
        func getOffsetForNextNode() -> Double {
            let angle = ( Double.pi * angle ) / 180
            
            return size.width * cos(angle)
        }
    }
    
    var nodes: [RotationNodeData] { [ .init(CGSize(width: 100, height: 100), at: rotation, y: 1),
                                      /*.init(CGSize(width: 250, height: 100))*/ ] }
    
    @State private var rotation: Double = 45
    
    private struct RotationNodeView: View {
        
        var data: RotationNodeData
        let offset: CGSize
        let scale: Double
        
        var body: some View {
            Rectangle()
                .opacity(0.5)
//                .foregroundStyle( Color(red: Double.random(in: 0...1),
//                                        green: Double.random(in: 0...1),
//                                        blue: Double.random(in: 0...1)) )
            
                .coordinateSpace(name: "test")
                .border(.red)
            
                .frame(width: data.size.width, height: data.size.height)
                .rotation3DEffect(
                    .init(degrees: data.angle),
                    axis: (x: data.xAxis, y: data.yAxis, z: data.zAxis),
                    anchor: .init(x: 0, y: 0.5 - data.perspective),
                    perspective: 1
                )
                .scaleEffect(scale, anchor: .leading)
                .offset(offset)
                .border(.blue)
        }
        
    }
    
//    @State private var rotation = 0.0
       @State private var perspective = 1.0
    
    private struct TestLine: Shape {
        
        let angle: Double
        func path(in rect: CGRect) -> Path {
            
            Path { path in
                path.move(to: .init(x: rect.minX, y: rect.minY))
                
                let angle = (Double.pi * angle) / 180
                let x = 300 * cos(angle)
                let y = 300 * sin(angle)
                
                path.addLine(to: .init(x: rect.minX + x, y: rect.minY + y))
                
            }
        }
    }
    
    
    var body: some View {
        
        VStack {
                    
                    Rectangle()
                        .fill(.blue)
                        .frame(width: 100, height: 100)
                        .rotation3DEffect(.degrees(rotation), axis: (x: 0, y: 1, z: 0), anchor: .leading, anchorZ: 0, perspective: perspective)
                    
                    Text("Rotation: \(rotation, specifier: "%.1f") degrees")
                    Slider(value: $rotation, in: -180...180)
                    
                    Text("Perspective: \(perspective, specifier: "%.1f")")
                    Slider(value: $perspective, in: -5...5)
                }
                .padding()
        
        GeometryReader { geo in
            
            Slider(value: $rotation, in: 0...90)
                .offset(y: 200)
            
            Text("\(rotation)")
            
            ZStack(alignment: .topLeading) {
            
                
//                Rectangle()
//                    .foregroundStyle(.clear)
//                    .stripedFill(at: 0, width: 1, spacing: 15, opacity: 0.2)
//                    .stripedFill(at: 90, width: 1, spacing: 15, opacity: 0.2)
                
//                Image("Mojave")
//                    .resizable()
//                    .aspectRatio(contentMode: .fill)
//                    .frame(width: geo.size.width - 50, height: geo.size.width - 50)
//                    .clipShape(Ellipse() )
//                    .allowsHitTesting(false)
                
                ForEach( nodes.indices, id: \.self ) { i in
                    
                    if i == 0 {
                        RotationNodeView(data: nodes[i], offset: .init(width: 0, height: 0), scale: 1)
                            .overlay {
                                GeometryReader { geo in
                                    
                                    let frame = geo.frame(in: .named("test"))
                                    
                                    Rectangle()
                                        .frame(width: frame.width, height: 10)
                                    
                                    
                                }
                                .border(.green)
                            }
                        
                    } else {
                        let previousNode = nodes[i - 1]
                        let scale = previousNode.getScaleForNextNode()
                        let offset = previousNode.getOffsetForNextNode()
                        
                        RotationNodeView(data: nodes[i], offset: .init(width: offset, height: 0), scale: 1)
                    }
                    
                    
                        
                }
                
                Circle()
                    .foregroundColor(.red)
                    .frame(width: 5, height: 5  )
                    .offset(x: 50, y: 10)
//                Rectangle()
//                    .frame(width: 50, height: 50)
//                    .foregroundStyle(.blue)
//                    .opacity(0.5)
                
//                Rectangle()
//                    .frame(width: 120, height: 100)
//                    .opacity(0.5)
//                
//                Rectangle()
//                    .opacity(0.5)
//                    .foregroundStyle(.red)
//                    .frame(width: 250, height: 100)
//                    .rotation3DEffect(
//                        .init(degrees: 45),
//                                              axis: (x: 0.0, y: 1.0, z: 0.0),
//                        anchor: .leading
//                    )
//                    .offset(x: 120)
//                
//                Rectangle()
//                    .opacity(0.5)
//                    .foregroundStyle(.green)
//                    .frame(width: 250, height: 100)
//                    .rotation3DEffect(
//                        .init(degrees: -45),
//                                              axis: (x: 0.0, y: 1.0, z: 0.0),
//                        anchor: .trailing
//                    )
//                    .offset(x: 120)
            }
        }
    }
    
}


struct BoundsPreferenceKey: PreferenceKey {
    typealias Value = Anchor<CGRect>?

    static var defaultValue: Value = nil

    static func reduce(
        value: inout Value,
        nextValue: () -> Value
    ) {
        value = nextValue()
    }
}

struct ExampleView: View {
    var body: some View {
        ZStack {
            Text("Hello World !!!")
                .padding()
                .border(.red)
            
                .anchorPreference(
                    key: BoundsPreferenceKey.self,
                    value: .bounds
                ) { $0 }
            
                .rotation3DEffect(
                    .init(degrees: 45),
                                          axis: (x: 0.0, y: 1.0, z: 0.0),
                    anchor: .leading,
                    perspective: 1
                )
            
                .border(.green)
            
                
        }
        .backgroundPreferenceValue(BoundsPreferenceKey.self) { preferences in
            GeometryReader { geometry in
                preferences.map {
                    Rectangle()
                        .foregroundStyle(.blue)
//                        .stroke()
                        .frame(
                            
                            width: geometry[$0].width,
                            height: geometry[$0].height
                        )
                        .offset(
                            x: geometry[$0].minX,
                            y: geometry[$0].minY
                        )
                }
            }
        }
    }
}

#Preview {
    
    ExampleView()
    
}
