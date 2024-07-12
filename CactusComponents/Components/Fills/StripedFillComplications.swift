//
//  StripedFillComplications.swift
//  CactusComponents
//
//  Created by Brian Masse on 7/11/24.
//

import Foundation
import SwiftUI

//MARK: ModularRibbon
struct ModularRibbon<C: View>: View {
    
    
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
        let width: Double
        
        let alignment: Alignment
        let perspective: Double
        
        
//        depending on the perspective, certain offsets need to be inverted
        var perspectiveDir: Double {
            if perspective == 0 { return 1 }
            return abs(perspective) / perspective
        }
        
//        depending on the alignment guide, the angle needs to be inverted
        var alignmentDir: Double { alignment == .leading ? 1 : -1 }
        
        
        init( in width: Double, at angle: Double = 0, perspective: Double = 1, alignment: Alignment = .leading ) {
            self.angle = angle
            self.width = width
            self.perspective = perspective
            
            self.alignment = alignment == .leading ? .leading : .trailing
        }
    }
    
//    MARK: RotationNode View
    private struct RotationNodeView<T: View>: View {
        
        let index: Int
        let height: Double
        let perspective: Double
        var data: RotationNodeData
        let offsetData: RotationNodeOffsetData
        
        let content: T
        
        init( _ index: Int, data: RotationNodeData, offsetData: RotationNodeOffsetData, perspective: Double, height: Double ) {
            self.index = index
            self.data = data
            self.offsetData = offsetData
            self.perspective = perspective
            self.height = height
        }
        
//        depending on the alignment guide, the offset changes
        private var horizontalOffset: Double { data.alignment == .leading ? 0 : -data.width }
        
        var body: some View {
            GeometryReader { geo in
                Rectangle()
                    .opacity(0.5)
                
                    .rotation3DEffect(
                        .init(degrees: data.alignmentDir * data.angle),
                        axis: (x: 0, y: 1, z: 0),
                        anchor: .init(x: data.alignment == .leading ? 0 : 1, y: 0.5 - data.perspective),
                        perspective: perspective
                    )
                
                    .offset(x: horizontalOffset)
                    .scaleEffect(offsetData.scale, anchor: .leading)
                    .offset(.init(width: offsetData.offset.width, height: offsetData.offset.height * data.perspectiveDir))
                
//                for reading the height data
                Rectangle()
                    .foregroundStyle(.clear)
                    .anchorPreference(key: RotationNodePreferenceKey.self,
                                      value: .bounds, transform: { anchor in
                        return [ index: geo[anchor] ]
                    })
                     
                    .rotation3DEffect(
                        .init(degrees: data.angle),
                        axis: (x: 0, y: 1, z: 0),
                        anchor: .init(x: 0, y: 1.5),
                        perspective: perspective
                    )
            }
                .frame(width: data.width, height: height)
        }
    }
    
    
//    MARK: Ribbon Vars
    var nodes: [RotationNodeData] { [ .init(in: 320, at: rotation, perspective: 3),
                                      .init(in: 350, at: 45, perspective: 5, alignment: .leading),
                                      .init(in: 250, at: 20, perspective: 7, alignment: .trailing),
                                      .init(in: 350, at: 20, perspective: 1, alignment: .leading),
                                      .init(in: 450, at: 20, perspective: 8, alignment: .trailing)] }
    
    
    @State private var rotation: Double = 45
    @State private var preferences: [ Int: RotationNodeOffsetData ] = [:]
    
    @State private var preferencesLoaded: Int = 0
    
    let height: Double = 100
    let perspective: Double = 0.3
    
//    take in the bound capture from the preference key and create the offset and scale
//    the bounds are the recorded by the preference key invisibly overlayed on the rotation node
//    the index is the node that you are making the offset data for (this function needs its perspective data)
//    to correctly calculate the veritcal offset
    private func makeOffsetData( in bounds: CGRect, for index: Int, previousScale: Double ) -> RotationNodeOffsetData {
        let offset = bounds.width
        
        let difference = bounds.height - height
        let scale = ( height - (difference * 2) ) / height
        let perspective = nodes[index].perspective

        return .init(offset: .init(width: offset, height: -difference * 2 * perspective * previousScale ), scale: scale)
    }
    
    private func flattenPreferences( for i: Int ) -> RotationNodeOffsetData {
        
        if i == 0 { return .init(offset: .zero, scale: 1) }
        
        var scale: Double = 1
        var offset: CGSize = .zero
        
        for j in 0...(i - 1) {
            if let preference = preferences[j] {
                
                let node = nodes[j]
                
                offset.width += (preference.offset.width * scale * node.alignmentDir)
                offset.height += (preference.offset.height * node.perspectiveDir)
                
                scale *= preference.scale
            }
        }
        
        return .init(offset: offset, scale: scale)
        
    }
    
    
//    MARK: Ribbon Body
    var body: some View {
    
        GeometryReader { geo in
            VStack(alignment: .leading) {
                VStack(alignment: .leading) {
                    Text("\(rotation)")
                    
                    Slider(value: $rotation, in: 0...90)
                }
                
                Spacer()
                
                ZStack(alignment: .leading) {
                    
                    ForEach( 0...min(preferencesLoaded, nodes.count - 1), id: \.self ) { i in
                        
                        let preference = flattenPreferences(for: i)
                        
                        RotationNodeView( index: i,
                                          height: height,
                                          perspective: perspective,
                                          data: nodes[i],
                                          offsetData: preference)

                    }
                    .onPreferenceChange(RotationNodePreferenceKey.self) { values in
                        
                        var newPreferences: [Int: RotationNodeOffsetData] = [:]
                        for key in 0...nodes.count - 1 {
                            if let bound = values[key] {
                                
                                preferencesLoaded += 1
                                
                                let test = flattenPreferences(for: key).scale
                                
                                var offsetData = makeOffsetData(in: bound, for: key, previousScale: test)
                                
                                newPreferences[key] = offsetData
                            }
                        }
                        
                        self.preferences = self.preferences.merging( newPreferences ) { ( current, new ) in new }
                    }
                }
                
                Spacer()
            }
        }
        .padding()
    }
}

#Preview {
    ModularRibbon()
}
