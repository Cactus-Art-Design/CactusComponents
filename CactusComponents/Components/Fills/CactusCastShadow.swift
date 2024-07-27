//
//  CactusCastShadow.swift
//  CactusComponents
//
//  Created by Brian Masse on 7/27/24.
//

import Foundation
import SwiftUI



struct CactusCastShadow: View {
    
    var body: some View {
        
        Text("HI!")
            .font(.custom("helvetica", size: 260))
//            .bold()
            .fontWeight(.black)
            .modifier(CactusCastShadowDemoView())
//            .padding([.bottom, .trailing], 50)
//            .background(.red)
    }
}

struct CactusCastShadowDemoView: ViewModifier {
    
    @Environment(\.colorScheme) var colorScheme
    
    let count: Double
    let spacing: Double
    let opacity: Double
    let angle: Double
    
    @State var foregroundColor: Color?
    let backgroundColor: Color
    
    init( angle: Double = 45,
          length: Double = 100,
          spacing: Double = 5,
          foregroundStyle: Color? = nil,
          backgroundStyle: Color = .yellow,
          opacity: Double = 0.7) {
        
        
        self.angle = angle
        
        self.foregroundColor = foregroundStyle
        self.backgroundColor = backgroundStyle
        
        self.count = length / spacing
        self.spacing = spacing
        self.opacity = opacity
        
    }
    
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
        .onAppear { 
            if foregroundColor == nil { self.foregroundColor = colorScheme == .dark ? .white : .black}
        }
        
        
    }
}

struct TestingView: View {
    
    var body: some View {
        
        GeometryReader { geo in
        
            VStack {
                
                Spacer()
                
                CactusCastShadow()
                    
                
                Spacer()
                
            }
            
        }
        .background(.yellow)
        
    }
    
}


#Preview {
    
    TestingView()
    
}
