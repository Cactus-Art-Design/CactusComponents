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
        
        
        let scale = max(min(Double(index) / count + (1 - opacity), 1), 0)
        
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
                            .opacity( 1 - makeOpacity(from: i) )
                            .zIndex(count - Double(i))
                            .foregroundStyle( makeColor(from: i) )
                    }
                }
                .blur(radius: 0.5)
            }
        }
//        .onAppear { 
//            if foregroundColor == nil { self.foregroundColor = colorScheme == .dark ? .white : .black}
//        }
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
    @State private var angle: Double = 30
    @State private var length: Double = 100
    @State private var spacing: Double = 5
    @State private var opacity: Double = 1
    
    @State private var foregroundColor: Color = .green
    @State private var backgroundColor: Color = .black
    @State private var fullBackgroundColor: Color = .black
    
//    MARK: Controls
    @ViewBuilder
    private func makeControl( title: String, value: Binding<Double>, in range: ClosedRange<Double> ) -> some View {
        VStack(alignment: .leading) {
            Text(title)
                .font(.callout)
                .bold()
            
            HStack {
                Slider(value: value, in: range)
                
                Text("\(Int(value.wrappedValue))")
            }
        }
    }
    
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
            makeControl(title: "Angle", value: $angle, in: 0...360)
            
            makeControl(title: "Length", value: $length, in: 5...300)
            
            makeControl(title: "Spacing", value: $spacing, in: 2...30)
            
            makeControl(title: "Opacity", value: $opacity, in: 0...1)
            
            HStack {
                
                makeColorPicker(title: "FG", value: $foregroundColor)
                
                makeColorPicker(title: "BG", value: $backgroundColor)
                
                makeColorPicker(title: "BG", value: $fullBackgroundColor)
            }
        }
        .padding()
        .background(.black.opacity(0.5))
        
    }
    
    
//    MARK: DemoBody
    var body: some View {
        
        GeometryReader { geo in
        
            VStack {
                makeControls()
                    .zIndex(5)
                
                Spacer()
                
                Text("HI")
                    .font(.custom("helvetica", size: 290))
                    .fontWeight(.black)
                
                    .castShadow(at: angle,
                                length: length,
                                spacing: spacing,
                                foregroundStyle: foregroundColor,
                                backgroundStyle: backgroundColor,
                                opacity: opacity)
                
                Spacer()
            }
        }
        .background(fullBackgroundColor)
        
    }
}


#Preview {
    CactusCastShadowDemoView()
}
