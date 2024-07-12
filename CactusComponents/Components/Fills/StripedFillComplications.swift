//
//  StripedFillComplications.swift
//  CactusComponents
//
//  Created by Brian Masse on 7/11/24.
//

import Foundation
import SwiftUI

struct RotationNodePreferenceKey: PreferenceKey {
    struct RotationNodePreferenceStorageData: Equatable {
        let interiorBounds: CGRect
        let anchor: Anchor<CGRect>
    }
    
    typealias Value = [ Int: RotationNodePreferenceStorageData ]

    static var defaultValue: Value = [:]

    static func reduce(
        value: inout Value,
        nextValue: () -> Value
    ) {
        value = nextValue()
    }
}

struct StripedFillComplication: View {
    
    struct RotationNodeOffsetData {
        let offset: CGSize
        let scale: Double
        let scaledWidth: Double
    }
    
    struct RotationNodeData {
        let angle: Double
        let size: CGSize
        
        let alignment: Alignment
        
        let xAxis: Double
        let yAxis: Double
        let zAxis: Double
        
        let perspective: Double
        
        init( _ size: CGSize, at angle: Double = 0, perspective: Double = 1, alignment: Alignment = .leading, x: Double = 0, y: Double = 0, z: Double = 0 ) {
            self.angle = angle
            self.size = size
            self.perspective = perspective
            self.xAxis = x
            self.yAxis = y
            self.zAxis = z
            
            self.alignment = alignment == .leading ? .leading : .trailing
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
                                      .init(CGSize(width: 200, height: 100), at: 45, perspective: 0, alignment: .trailing, y: 1) ] }
    
    @State private var rotation: Double = 45
    
    private struct RotationNodeView: View {
        
        
        var data: RotationNodeData
        let index: Int
        let offsetData: RotationNodeOffsetData
        
        @Binding var preferences: [Int: RotationNodeOffsetData]
        
        @State private var scaledWidth: Double = 0
    
        
        private var perspectiveDir: Double {
            if data.perspective == 0 { return 1 }
            return abs(data.perspective) / data.perspective
        }
        
        private var alignmentDir: Double {
            data.alignment == .leading ? 1 : -1
        }
        
        private var horizontalOffset: Double {
            data.alignment == .leading ? 0 : -200
        }
        
        var body: some View {
            GeometryReader { geo in
                Rectangle()
                
                    .opacity(0.5)
    //                .foregroundStyle( Color(red: Double.random(in: 0...1),
    //                                        green: Double.random(in: 0...1),
    //                                        blue: Double.random(in: 0...1)) )
                    .border(.red)
                
                    
                
                    .rotation3DEffect(
                        .init(degrees: alignmentDir * data.angle),
                        axis: (x: data.xAxis, y: data.yAxis, z: data.zAxis),
                        anchor: .init(x: data.alignment == .leading ? 0 : 1, y: 0.5 - data.perspective),
                        perspective: 1
                    )
                
                    .offset(x: horizontalOffset)
                    
                    .scaleEffect(offsetData.scale, anchor: .leading)
                    
                    .offset(.init(width: offsetData.offset.width, height: offsetData.offset.height * perspectiveDir))
                
                    
                
//                for reading the height data
                Rectangle()
                
                    .opacity(0)
    //                .foregroundStyle( Color(red: Double.random(in: 0...1),
    //                                        green: Double.random(in: 0...1),
    //                                        blue: Double.random(in: 0...1)) )
//                    .border(.red)
                    .scaleEffect(offsetData.scale, anchor: .leading)
//                    .offset(offsetData.offset)
            
                    .anchorPreference(key: RotationNodePreferenceKey.self,
                                      value: .bounds, transform: { anchor in
                        
                        let bounds = geo[anchor]
                        
                        return [ index: .init(interiorBounds: bounds, anchor: anchor) ]
                    })
                     
                
                    .rotation3DEffect(
                        .init(degrees: data.angle),
                        axis: (x: data.xAxis, y: data.yAxis, z: data.zAxis),
                        anchor: .init(x: 0, y: 1.5),
                        perspective: 1
                    )
            }

                .frame(width: data.size.width, height: data.size.height)
                .border(.blue)
                .onPreferenceChange(RotationNodePreferenceKey.self) { value in
                
                    if self.index == 1 {
                        print(value[1]?.interiorBounds.width)
                        
                        self.scaledWidth = value[1]!.interiorBounds.width
                        
                    }
                    
                }
            
                .overlayPreferenceValue(RotationNodePreferenceKey.self, { value in
                    
                    Rectangle()
                        .stroke(.purple)
//                        .stroke()
                        .frame(
                            
                            width: value[index]?.interiorBounds.width,
                            height: value[index]?.interiorBounds.height
                        )
                        .offset(
                            x: value[index]?.interiorBounds.minX ?? 0,
                            y: value[index]?.interiorBounds.minY ?? 0
                        )
                  
//                    Rectangle()
//                        .frame(width: 100, height: 100)
//                        .opacity(0.5)
//                        .rotation3DEffect(
//                            .init(degrees: data.angle),
//                            axis: (x: data.xAxis, y: data.yAxis, z: data.zAxis),
//                            anchor: .init(x: 0.5, y: 0.5 - data.perspective),
//                            perspective: 1
//                        )
                    
                })
        }
        
    }
    
//    @State private var rotation = 0.0
       @State private var perspective = 1.0
    
    @State private var preferences: [ Int: RotationNodeOffsetData ] = [:]
    
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
            
            ZStack(alignment: .leading) {
            
                
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
                    
                    let offset = preferences[i - 1]?.offset
                    let scale = preferences[i - 1]?.scale ?? 1
                    
//                    let _ = print( i, preferences[i]?.height )
                    
                    RotationNodeView(data: nodes[i],
                                     index: i,
                                     offsetData: preferences[i - 1] ?? .init(offset: .zero,
                                                                         scale: 1,
                                                                         scaledWidth: 1),
                                     preferences: $preferences)
                    
//                    if i == 0 {
//                        
//                            .overlay {
//                                GeometryReader { geo in
//                                    
//                                    let frame = geo.frame(in: .named("test"))
//                                    
//                                    Rectangle()
//                                        .frame(width: frame.width, height: 10)
//                                    
//                                    
//                                }
//                                .border(.green)
//                            }
//                        
//                    } else {
//                        let previousNode = nodes[i - 1]
//                        let scale = previousNode.getScaleForNextNode()
//                        let offset = previousNode.getOffsetForNextNode()
//                        
//                        RotationNodeView(data: nodes[i], offset: .init(width: offset, height: 0), scale: 1)
//                    }
                    
                    
                        
                }
                .offset(x: 41.42135623730951 / 2 + 100, y: 0)
                .onPreferenceChange(RotationNodePreferenceKey.self) { values in
                    
                    let newPreferences: [ Int: RotationNodeOffsetData ] = values.mapValues { storedBounds in
                        
                        let interiorBounds = storedBounds.interiorBounds
                        let exteriorBounds = geo[ storedBounds.anchor ]
                        
                        let offset = exteriorBounds.width
                        
//                        let difference = (interiorBounds.height - exteriorBounds.height) / 2
//                        let ratio = difference / (interiorBounds.width - offset / 2)
//                        let scaledDifference = ratio * offset * 2 + 5
//                        let scale = (exteriorBounds.height - scaledDifference) / exteriorBounds.height
                        
                        let difference = interiorBounds.height - 100
                        let scale = ( 100 - (difference * 2) ) / 100
                        
                        
                        
//                        print( offset, scale, interiorBounds.width )
                        
                        
                        
                        return .init(offset: .init(width: offset, height: -difference * 2), scale: scale, scaledWidth: exteriorBounds.width)
                    }
                    
                    self.preferences = newPreferences
                    
                }
                
                Rectangle()
                    .foregroundColor(.red)
                    .frame(width: 1, height: 198.48077530122103  )
                    .offset(x: 8.748866352592415, y: 0)
                
                Rectangle()
                    .foregroundColor(.red)
                    .frame(width: -41.42135623730951 / 2 + 100, height: 1 )
                    .offset(x: 41.42135623730951, y: 0)
                
                
                Rectangle()
                    .foregroundStyle(.green)
                    .frame(width: 1, height: 36.93980625181293 / 2)
                    .offset(x: 41.42135623730951 * 1.5 + 100, y: 0)
                
                Rectangle()
                    .foregroundColor(.red)
                    .frame(width: 1, height: 100 *  0.5806019374818707 )
                    .offset(x: 41.42135623730951 * 1.5 + 100, y: 0)
                
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
            Rectangle()
                .frame(width: 200, height: 200)
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
    
    StripedFillComplication()
    
}
