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
            .offset(y: (100 / 650) * geo.size.height )
            
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
    let ignoreSafeArea: Bool
    
    func body(content: Content) -> some View {
        content
            .background {
                CactusRadialGlow(colors: colors, opacity: opacity, ignoreSafeArea: ignoreSafeArea)
            }
    }
}


//MARK: Extension
extension View {
    func backgroundRadialGlowDemo(_ colors: [Color], opacity: Double = 1, ignoreSafeArea: Bool = true) -> some View {
        modifier( CactusRadialGlowModifier( colors: colors, opacity: opacity, ignoreSafeArea: ignoreSafeArea ) )
    }
}


//MARK: Demo View
struct CactusRadialGlowDemoView: View {
    
    static func makeColor(_ red: Double, _ green: Double, _ blue: Double) -> Color {
        .init(red: red / 255, green: green / 255, blue: blue / 255)
    }
    
    let colors = [ makeColor(242, 138, 2),
                   makeColor(250, 208, 55),
                   makeColor(16, 176, 224) ]
    
    var body: some View {
        
        VStack {
            HStack { Spacer() }
            
            Text("hello world!")
            
            Spacer()
        }
        .backgroundRadialGlowDemo(colors)
    }
}

#Preview {
    
    
    CactusRadialGlowDemoView()
    
}
