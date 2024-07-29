//
//  CactusCastShadow.swift
//  CactusComponents
//
//  Created by Brian Masse on 7/27/24.
//

import Foundation
import SwiftUI

//MARK: CactusCastShadow
struct CactusCastShadow: ViewModifier {
    
    @Environment(\.colorScheme) var colorScheme
    
    
//    MARK: Vars
    let count: Double
    let spacing: Double
    let opacity: Double
    let angle: Double
    
    let foregroundColor: Color?
    let backgroundColor: Color
    
    init( angle: Double,
          length: Double,
          spacing: Double,
          foregroundStyle: Color?,
          backgroundStyle: Color,
          opacity: Double) {
        
        
        self.angle = angle
        
        self.foregroundColor = foregroundStyle
        self.backgroundColor = backgroundStyle
        
        self.count = length / spacing
        self.spacing = spacing
        self.opacity = opacity
        
    }
    
//    MARK: struct methods
    private func degToRad(_ angle: Double) -> Double {
        (Double.pi * angle) / 180
    }
    
    private func makeOpacity(from index: Int) -> Double {
        (Double(index) / Double(count)) * opacity
    }
    
    private func makeVerticalOffset(from index: Int) -> Double {
        sin( degToRad(angle) ) * Double(index) * spacing
    }
    
    private func makeHorizontalOffset(from index: Int) -> Double {
        cos( degToRad(angle) ) * Double(index) * spacing
    }
    
    private func makeColor(from index: Int) -> Color {
        
        let startColor = (foregroundColor ?? .white).components
        let endColor = backgroundColor.components
        
        let proposedScale = (Double(index) / count) + (1 - opacity)
        let scale = max(min(proposedScale, 1), 0)
        
        let red     = (endColor.red - startColor.red) * (scale) + startColor.red
        let green   = (endColor.green - startColor.green) * (scale) + startColor.green
        let blue    = (endColor.blue - startColor.blue) * (scale) + startColor.blue
        
        return Color(red: red, green: green, blue: blue).opacity( scale == 1 ? 0 : 1 )
    }
    
//    MARK: Body
    func body(content: Content) -> some View {
        
        VStack {
            ZStack {
                content
                    .zIndex(count + 1)
                    .foregroundColor(foregroundColor)
                
                ZStack {
                    ForEach(0...Int(count), id: \.self) { i in
                        content
                            .offset(x: makeHorizontalOffset(from: i), y: makeVerticalOffset(from: i))
//                            .opacity( 1 - makeOpacity(from: i) )
                            .zIndex(count - Double(i))
                            .foregroundStyle( makeColor(from: i) )
                    }
                }
                .blur(radius: 0.5)
            }
        }
    }
}

//MARK: Extension
extension View {
    
    func castShadow( at angle: Double = 30,
                     length: Double = 100,
                     spacing: Double = 5,
                     foregroundStyle: Color = .black,
                     backgroundStyle: Color,
                     opacity: Double = 1,
                     changeOnColorScheme: Bool = false
    ) -> some View {
        
        modifier( CactusCastShadow(angle: angle,
                                   length: length,
                                   spacing: spacing,
                                   foregroundStyle: changeOnColorScheme ? nil : foregroundStyle,
                                   backgroundStyle: backgroundStyle,
                                   opacity: opacity) )
        
    }
    
}

//MARK: CactusCastShadowDemoView
struct CactusCastShadowDemoView: View {
    
//    MARK: Vars
    @State private var angle: Double = 200
    @State private var length: Double = 200
    @State private var spacing: Double = 15
    @State private var opacity: Double = 0.9
    
    @State private var foregroundColor: Color = .yellow
    @State private var backgroundColor: Color = .black
    @State private var fullBackgroundColor: Color = .black
    
//    MARK: Controls
    @ViewBuilder
    private func makeColorPicker( title: String, value: Binding<Color> ) -> some View {
        VStack {
            ColorPicker(title, selection: value)
                .padding()
                .background {
                    
                    RoundedRectangle(cornerRadius: 15)
                        .foregroundStyle(.white.opacity(0.15))
                }
        }
    }
    
    @ViewBuilder
    private func makeControls(  ) -> some View {
        
        VStack(spacing: 0) {
            CactusComponentControl("Angle", for: $angle, in: 0...360)
            
            CactusComponentControl("Length", for: $length, in: 5...300)
            
            CactusComponentControl("Spacing", for: $spacing, in: 2...30)
            
            CactusComponentControl("Opacity", for: $opacity, in: 0...1, step: 0.05)
            
            HStack {
                
                makeColorPicker(title: "FG", value: $foregroundColor)
                
                makeColorPicker(title: "BG", value: $backgroundColor)
                
                makeColorPicker(title: "BG", value: $fullBackgroundColor)
            }
        }
        .padding()
    }
    
    
//    MARK: DemoBody
    var body: some View {
        
        GeometryReader { geo in
        
            VStack(spacing: 5) {
                makeControls()
                    .zIndex(5)
                
                VStack(spacing: -100) {
                    Text("20")
                    Text("24")
                }
                .font(.custom("Helvetica", size: 250))
                .bold()
                
                .castShadow(at: angle,
                            length: length,
                            spacing: spacing,
                            foregroundStyle: foregroundColor,
                            backgroundStyle: backgroundColor,
                            opacity: opacity)
                
                .rotation3DEffect(
                    .init(degrees: 45),
                    axis: (x: -0.7, y: 2, z: 0.0),
                    perspective: 0
                )
                
                Spacer()
            }
        }
        .background(fullBackgroundColor)
        
    }
}


#Preview {
    CactusCastShadowDemoView()
}
