//
//  StripedFillComplications.swift
//  CactusComponents
//
//  Created by Brian Masse on 7/11/24.
//

import Foundation
import SwiftUI

//MARK: ModularRibbon
struct ModularRibbon: View {
    
    
//    MARK: RotationNodePreferenceKey
//    this reads the rotation effects to provide bounds and chain nodes together
    struct RotationNodePreferenceKey: PreferenceKey {
        
        typealias Value = [ Int: CGRect ]

        static var defaultValue: Value = [:]

        static func reduce(
            value: inout Value,
            nextValue: () -> Value
        ) {
            value = nextValue()
        }
    }
    
//    MARK: RotationNoodeOffsetData
//    tells a node how to align itself with the previous node in the chain
    struct RotationNodeOffsetData {
        let offset: CGSize
        let scale: Double
    }
    
//    MARK: RotationNodeData
//    The individual attributes of a node
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
    }
    
//    MARK: RotationNode View
    private struct RotationNodeView: View {
        
        var data: RotationNodeData
        let index: Int
        let offsetData: RotationNodeOffsetData
            
//        depending on the perspective, certain offsets need to be inverted
        private var perspectiveDir: Double {
            if data.perspective == 0 { return 1 }
            return abs(data.perspective) / data.perspective
        }
        
//        depending on the alignment guide, the angle needs to be inverted
        private var alignmentDir: Double { data.alignment == .leading ? 1 : -1 }
        
//        depending on the alignment guide, the offset changes
        private var horizontalOffset: Double { data.alignment == .leading ? 0 : -data.size.width }
        
        var body: some View {
            GeometryReader { geo in
                Rectangle()
                    .opacity(0.5)
                    .border(.red)
                
                    .rotation3DEffect(
                        .init(degrees: alignmentDir * data.angle),
                        axis: (x: data.xAxis, y: data.yAxis, z: data.zAxis),
                        anchor: .init(x: data.alignment == .leading ? 0 : 1, y: 0.5 - data.perspective),
                        perspective: 0.5
                    )
                
                    .offset(x: horizontalOffset)
                    .scaleEffect(offsetData.scale, anchor: .leading)
                    .offset(.init(width: offsetData.offset.width, height: offsetData.offset.height * perspectiveDir))
                
//                for reading the height data
                Rectangle()
                    .foregroundStyle(.clear)
                    .anchorPreference(key: RotationNodePreferenceKey.self,
                                      value: .bounds, transform: { anchor in
                        return [ index: geo[anchor] ]
                    })
                     
                    .rotation3DEffect(
                        .init(degrees: data.angle),
                        axis: (x: data.xAxis, y: data.yAxis, z: data.zAxis),
                        anchor: .init(x: 0, y: 1.5),
                        perspective: 0.5
                    )
            }
                .frame(width: data.size.width, height: data.size.height)
                .border(.blue)
        }
    }
    
    
//    MARK: Ribbon Vars
    var nodes: [RotationNodeData] { [ .init(CGSize(width: 100, height: 100), at: rotation, y: 1),
                                      .init(CGSize(width: 200, height: 100), at: 45, perspective: 0, alignment: .trailing, y: 1) ] }
    
    @State private var rotation: Double = 45
    @State private var preferences: [ Int: RotationNodeOffsetData ] = [:]
    
//    take in the bound capture from the preference key and create the offset and scale
    private func makeOffsetData( in bounds: CGRect ) -> RotationNodeOffsetData {
        let offset = bounds.width
        
        let difference = bounds.height - 100
        let scale = ( 100 - (difference * 2) ) / 100
        
        return .init(offset: .init(width: offset, height: -difference * 2), scale: scale)
    }
    
    
//    MARK: Ribbon Body
    var body: some View {
    
        VStack {
            VStack(alignment: .leading) {
                Text("\(rotation)")
                
                Slider(value: $rotation, in: 0...90)
            }
            
            Spacer()
            
            ZStack(alignment: .leading) {
                
                ForEach( nodes.indices, id: \.self ) { i in
                    
                    let preference = preferences[i - 1] ?? .init(offset: .zero, scale: 1)
                    
                    RotationNodeView(data: nodes[i], index: i, offsetData: preference)
                    
                }
                .onPreferenceChange(RotationNodePreferenceKey.self) { values in
                    let newPreferences: [ Int: RotationNodeOffsetData ] = values.mapValues { makeOffsetData(in: $0) }
                    self.preferences = newPreferences
                }
            }
            
            Spacer()
        }
        .padding()
    }
}

#Preview {
    ModularRibbon()
}
