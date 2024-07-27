//
//  RadialGlow.swift
//  CactusComponents
//
//  Created by Brian Masse on 7/24/24.
//

import Foundation
import SwiftUI
import UIUniversals

//MARK: CactusRadialGlow
struct CactusRadialGlow: View {
    
    let colors: [Color]
    
    let opacity: Double
    let offset: Double
    
    let ignoreSafeArea: Bool
    
    private func mapColors(in geo: GeometryProxy) -> [Gradient.Stop] {
    
        var colors = Array(colors)
        colors.append(.clear)
        
        let spacing = 0.65 / Double(colors.count)
        
        return colors.indices.map { i in
                .init(color: colors[i],
                      location: spacing * Double(i) )
        }
    }
    
    var body: some View {
        
        GeometryReader { geo in
            
            let stops = mapColors(in: geo)
            
            RadialGradient(stops: stops,
                           center: .bottom,
                           startRadius: geo.size.width / 2,
                           endRadius: geo.size.height * 1.3)
            
            .opacity(opacity)
            
            .rotationEffect(.init(degrees: -10))
            .scaleEffect(1.3)
            .blur(radius: 40)
            .scaleEffect(y: 0.95)
            .offset(y: (100 / 650) * geo.size.height + offset)
            
            .clipShape(Rectangle())
        }
        .if(ignoreSafeArea) { view in
            view.ignoresSafeArea()
        }
    }
}

//MARK: CactusRadialGlowModifier
struct CactusRadialGlowModifier: ViewModifier {
    
    let colors: [Color]
    let opacity: Double
    let offset: Double
    let ignoreSafeArea: Bool
    
    func body(content: Content) -> some View {
        content
            .background {
                CactusRadialGlow(colors: colors, opacity: opacity, offset: offset, ignoreSafeArea: ignoreSafeArea)
            }
    }
}


//MARK: Extension
extension View {
    func backgroundRadialGlowDemo(_ colors: [Color], opacity: Double = 1, offset: Double = 0, ignoreSafeArea: Bool = true) -> some View {
        modifier( CactusRadialGlowModifier( colors: colors, opacity: opacity, offset: offset, ignoreSafeArea: ignoreSafeArea ) )
    }
}


//MARK: Demo View
struct CactusRadialGlowDemoView: View {
    
    static func makeColor(_ red: Double, _ green: Double, _ blue: Double) -> Color {
        .init(red: red / 255, green: green / 255, blue: blue / 255)
    }
    
    let pallette1 = [ makeColor(242, 138, 2), makeColor(250, 208, 55), makeColor(16, 176, 224) ]
    let pallette2 = [makeColor(204, 103, 86), makeColor(190, 100, 117), makeColor( 91, 75, 146 )]
    let pallette3 = [makeColor(221, 230, 135), makeColor(66, 224, 245), makeColor( 114, 66, 245 )]
    
    let bodyText: String = "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua."
    
//    MARK: ViewBuilders
    @ViewBuilder
    private func makeCard(icon: String, title: String, subTitle: String) -> some View {
        VStack(alignment: .leading) {
            HStack {
                Image(systemName: icon)
                
                Text(title)
                
                Spacer()
            }
            .font(.title3)
            .bold()
            .textCase(.uppercase)
            
            Text(subTitle)
                .opacity(0.5)
            
            Text(bodyText)
                .font(.callout)
                .lineLimit(2)
        }
        .padding()
        .background {
            RoundedRectangle(cornerRadius: 25)
                .foregroundStyle(.ultraThinMaterial)
                .opacity(0.6)
        }
    }
    
    @ViewBuilder
    private func makeContent() -> some View {
        
        VStack(alignment: .leading) {
            HStack { Spacer() }
            
            Group {
                Text("Hello World")
                Text("Radial Glow Fill")
                    .opacity(0.5)
            }
            .font(.largeTitle)
            .bold()
            .textCase(.uppercase)
            
            Spacer()
            
            makeCard(icon: "map", title: "Task 1", subTitle: "Lorem ipsum dolor")
            
            makeCard(icon: "tram", title: "Task 2", subTitle: "Lorem ipsum dolor")
        }
    }
    
    
//    MARK: Body
    var body: some View {
        
        makeContent()
            .padding()
            .backgroundRadialGlowDemo(pallette3)
    }
}

#Preview {
    
    
    CactusRadialGlowDemoView()
    
}
