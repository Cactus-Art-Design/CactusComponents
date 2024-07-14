//
//  StripedFillComplications.swift
//  CactusComponents
//
//  Created by Brian Masse on 7/11/24.
//

import Foundation
import SwiftUI


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

//MARK: ModularRibbon
struct ModularRibbon<C: View>: View {
    
//    MARK: RotationNode View
    private struct RotationNodeView: View {
        
        let index: Int
        let height: Double
        let perspective: Double
        let shadowOpacity: Double
        var data: RotationNodeData
        let offsetData: RotationNodeOffsetData
        
        let content: C
        
        init( _ index: Int, data: RotationNodeData, offsetData: RotationNodeOffsetData, perspective: Double, height: Double, shadowOpacity: Double, content: C ) {
            self.index = index
            self.data = data
            self.offsetData = offsetData
            self.perspective = perspective
            self.height = height
            self.shadowOpacity = shadowOpacity
            self.content = content
        }
        
//        depending on the alignment guide, the offset changes
        private var horizontalOffset: Double { data.alignment == .leading ? 0 : -data.width }
        
        var body: some View {
            GeometryReader { geo in
                Rectangle()
                    .opacity(0.5)
                    .overlay {
                        content
                        Rectangle()
                            .foregroundStyle(.black)
                            .opacity(index % 2 == 1 ? 0 : shadowOpacity)
                    }
                    
                
                    .rotation3DEffect(
                        .init(degrees: data.alignmentDir * data.angle),
                        axis: (x: 0, y: 1, z: 0),
                        anchor: .init(x: data.alignment == .leading ? 0 : 1, y: 0.5 - data.perspective),
                        perspective: perspective
                    )
                
                    .offset(x: horizontalOffset)
                    .scaleEffect(offsetData.scale, anchor: .leading)
                    .offset(.init(width: offsetData.offset.width, height: offsetData.offset.height))
                
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
    var nodes: [RotationNodeData]
    
    @State private var rotation: Double = 45
    @State private var preferences: [ Int: RotationNodeOffsetData ] = [:]
    
    @State private var preferencesLoaded: Int = 0
    
    let height: Double
    let perspective: Double
    let shadowOpacity: Double
    
    @ViewBuilder
    let contentBuilder: (Int) -> C
    
    init( _ nodes: [ RotationNodeData ], height: Double = 100, perspective: Double = 0.3, shadowOpacity: Double = 0.3, @ViewBuilder contentBuilder: @escaping (Int) -> C ) {
        self.nodes = nodes
        self.height = height
        self.perspective = perspective
        self.contentBuilder = contentBuilder
        self.shadowOpacity = shadowOpacity
    }
    
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
                offset.height += (preference.offset.height)
                
                scale *= preference.scale
            }
        }
        
        return .init(offset: offset, scale: scale)
    }
    
    
//    MARK: Ribbon Body
    var body: some View {
        ZStack(alignment: .leading) {
            
            ForEach( 0...min(preferencesLoaded, nodes.count - 1), id: \.self ) { i in
                
                let preference = flattenPreferences(for: i)
                
                RotationNodeView(i, data: nodes[i],
                                 offsetData: preference,
                                 perspective: perspective,
                                 height: height,
                                 shadowOpacity: shadowOpacity,
                                 content: contentBuilder(i) )
                .zIndex(100 - Double(i))

            }
            .onPreferenceChange(RotationNodePreferenceKey.self) { values in
                
                var newPreferences: [Int: RotationNodeOffsetData] = [:]
                for key in 0...nodes.count - 1 {
                    if let bound = values[key] {
                        
                        preferencesLoaded += 1
                        
                        let preiousScale = flattenPreferences(for: key).scale
                        let offsetData = makeOffsetData(in: bound, for: key, previousScale: preiousScale)
                        
                        newPreferences[key] = offsetData
                    }
                }
                
                self.preferences = self.preferences.merging( newPreferences ) { ( current, new ) in new }
            }
        }
    }
}

//MARK: RibbonViewDemo
struct RibbonViewDemo: View {
    
    let nodes: [RotationNodeData] = [ .init(in: 150, at: 10, perspective: -3),
                                      .init(in: 420, at: 45, perspective: 5, alignment: .leading),
                                      .init(in: 200, at: 20, perspective: 7, alignment: .trailing),
                                      .init(in: 350, at: 45, perspective: 5, alignment: .leading),
                                      .init(in: 200, at: 20, perspective: 11, alignment: .trailing),
                                      .init(in: 600, at: 20, perspective: 4, alignment: .trailing),
                                      .init(in: 350, at: 45, perspective: -8, alignment: .leading),
                                      .init(in: 250, at: 45, perspective: -5, alignment: .trailing),
                                      .init(in: 650, at: 45, perspective: -8, alignment: .leading) ]
    
//    MARK: Segments
    @ViewBuilder
    private func makeFirstSegment() -> some View {
        
        VStack(alignment: .leading) {
            HStack {
                Text("Route")
                Image(systemName: "arrow.forward")
                
                Spacer()
            }
            .font(.title)
            .bold()
            
            Text( "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum." )
                .font(.caption2)
                .padding(.bottom, 50)
        }
    }
    
    @ViewBuilder
    private func makeSecondSegment() -> some View {
        VStack(alignment: .leading) {
            HStack {
                Text("INTO THE WILD")
                Spacer()
            }
            .font(.largeTitle)
            .bold()
            .scaleEffect(1.5, anchor: .topLeading)
            .padding(.bottom)
            
            Text( "Design By Brian Masse" )
                .bold()
            
            Spacer()
        }
    }
    
    @ViewBuilder
    private func makeThirdSegment() -> some View {
        VStack(alignment: .trailing) {
            Spacer()
            
            Text("wow this took a long time")
            
            HStack {
                Spacer()
                Text("Leap of Faith")
            }
            .font(.largeTitle)
            .bold()
            .padding(.bottom)
        }
    }
    
    @ViewBuilder
    private func makeLastSegment() -> some View {
        HStack(alignment: .top) {
            Text("Safety")
                .font(.largeTitle)
                .bold()
            
            Text("Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat.")
                .font(.caption2)
                .padding(.trailing, 50)
            
            Text("About us")
                .font(.largeTitle)
                .bold()
            
            Text("Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat.")
                .font(.caption2)
                .padding(.trailing)
            
            
            VStack(alignment: .leading) { Spacer() }
            
            Spacer()
        }.padding(.bottom, 50 )
    }
    
//    MARK: RibbonViewDemo
    var body: some View {
        
        ZStack(alignment: .bottomLeading) {
            GeometryReader { geo in
                VStack {
                    
                    Spacer()
                    
                    ModularRibbon( nodes, height: 150, perspective: 0.3, shadowOpacity: 0.1) { i in
                        
                        Rectangle()
                            .foregroundStyle(.white)
                        
                        Group {
                            if i == 0 { makeFirstSegment() }
                            if i == 1 { makeSecondSegment() }
                            if i == 3 { makeThirdSegment() }
                            if i == 5 { makeLastSegment() }
                            
                        }
                        .padding(7)
                    }
                    .shadow(color: .white.opacity(0.2), radius: 15)
                    .foregroundColor(.black)
                    .offset(y: geo.size.height / 5)
                    
                    Spacer()
                }
            }
            
            Text("BRIAN \nMASSE")
                .font(.title2)
                .bold()
                .foregroundStyle(.yellow)
                .padding(30)
        }
        .background {
            Image( "farm" )
                .resizable()
                .aspectRatio(contentMode: .fill)
                .clipShape(Rectangle())
        }
        .ignoresSafeArea()
    }
}

#Preview {
    RibbonViewDemo()
}
