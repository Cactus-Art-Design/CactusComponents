//
//  StripedFill.swift
//  CactusComponents
//
//  Created by Brian Masse on 7/10/24.
//

import Foundation
import SwiftUI

//    MARK: Line
private struct StripedLine: Shape {
    
    let angle: Double
    
    static func getAdditionalLength( angle: Double, in rect: CGRect) -> Double {
        let angle = (Double.pi * angle) / 180
        let length = StripedLine.getLength(angle: angle, in: rect)
    
        return abs(cos(angle) * length)
        
    }
    
    static func getLength( angle: Double, in rect: CGRect ) -> Double {
        
        let slope = tan( angle )
        
        let x = (rect.maxY - rect.midY) * (1 / slope) + rect.minX
        
        let dx = x - rect.minX
        let dy = rect.maxY - rect.midY
        
        return sqrt( pow(dx, 2) + pow(dy, 2) )
    }
    
    
//        MARK: Line Path
    func path(in rect: CGRect) -> Path {
        
        Path { path in
            
            let angle = (Double.pi * angle) / 180
            let length = StripedLine.getLength(angle: angle, in: rect)
            
            let x = length * cos(angle)
            let y = length * sin(angle)
            
            path.move(to: .init(x: rect.minX - x,
                                y: rect.midY + y ))
            
            path.addLine(to: .init(x: rect.minX + x,
                                   y: rect.midY - y ))
        }
    }
}

struct StripedFill<S>: ViewModifier, Animatable where S: ShapeStyle {
    
//    MARK: ViewModifier Vars
    var angle: Double
    let lineWidth: Double
    let spacing: Double
    let opacity: Double
    let foregroundStyle: S
    let overlayWithNormal: Bool
    
    var animatableData: Double {
        get { angle }
        set { self.angle = newValue }
    }
    
    init( at angle: Double, width: Double, spacing: Double?, style: S, opacity: Double, overlayWithNormal: Bool ) {
        
        self.angle = (angle.truncatingRemainder(dividingBy: 180) == 0) ? 0.01 : angle
        self.lineWidth = width
        self.spacing = spacing == nil ? width : spacing!
        self.opacity = opacity
        self.foregroundStyle = style
        self.overlayWithNormal = overlayWithNormal
        
    }
    
//    MARK: ViewModifier Body
    func body(content: Content) -> some View {
        
        content
            .coordinateSpace(name: "test")
            .background {
                GeometryReader { geo in
                    
                    let angle = (angle.truncatingRemainder(dividingBy: 180) == 0) ? 0.01 : angle
                    let additionalLength = StripedLine.getAdditionalLength(angle: angle, in: .init(x: 0, y: 0,
                                                                                            width: geo.size.width,
                                                                                            height: geo.size.height)  )
                
                    let radAngle = (Double.pi * angle) / 180
                    let offset = (lineWidth + spacing) / abs(cos( Double.pi / 2 - radAngle ))
                    
                    let count = Int( (geo.size.width + additionalLength * 2) / (offset) )
                    
                    ZStack {
                        ForEach( 0...count, id: \.self ) { i in
                            StripedLine(angle: animatableData )
                                .stroke(style: .init(lineWidth: lineWidth, lineCap: CGLineCap.square))
                                .foregroundStyle( foregroundStyle )
                            
                                .offset(x: Double(i) * offset )
                                .offset(x: -additionalLength + ( lineWidth / 2 ))
                            
                                .opacity(opacity)
                                .blendMode( overlayWithNormal ? .normal : .overlay)
                        }
                    }
                }
                .clipShape(Rectangle())
            }
    }
}

//MARK: StripedMask
struct StripedMask<S>: ViewModifier where S: ShapeStyle {
    
//    MARK: ViewModifier Vars
    var angle: Double
    let lineWidth: Double
    let spacing: Double
    let opacity: Double
    let maskOpacity: Double
    let foregroundStyle: S
    let overlayWithNormal: Bool
    
    var animatableData: Double {
        get { angle }
        set { self.angle = newValue }
    }
    
    func body(content: Content) -> some View {
        
        content
            .mask {
                Rectangle()
                    .opacity(1 - maskOpacity)
                    .stripedFill(at: animatableData,
                                 width: lineWidth,
                                 spacing: spacing,
                                 style: foregroundStyle,
                                 opacity: opacity,
                                 overlayWithNormal: overlayWithNormal)
            }
    }
}

extension View {
    func stripedFill<S>(at angle: Double,
                        width: Double,
                        spacing: Double? = nil,
                        style: S = .foreground,
                        opacity: Double = 1,
                        overlayWithNormal: Bool = true) -> some View where S: ShapeStyle {
        
        modifier(StripedFill(at: angle,
                             width: width,
                             spacing: spacing,
                             style: style,
                             opacity: opacity,
                             overlayWithNormal: overlayWithNormal))
    }
    
    func stripedMask<S>(at angle: Double = 90,
                        width: Double = 2,
                        spacing: Double? = nil,
                        style: S = .foreground,
                        opacity: Double = 1,
                        maskOpacity: Double = 1,
                        overlayWithNormal: Bool = true) -> some View where S: ShapeStyle {
        
        modifier( StripedMask(angle: angle,
                              lineWidth: width,
                              spacing: spacing == nil ? width : spacing!,
                              opacity: opacity,
                              maskOpacity: maskOpacity,
                              foregroundStyle: style,
                              overlayWithNormal: overlayWithNormal) )
        
    }
}

//MARK: TestView
struct TestView: View {
    
    @State private var angle: Double = 96
    
    @State private var secondaryAngle: Double = 0
    @State private var color: Color = .red
    
    private func shuffleColor() {
        self.color = Color(red: Double.random(in: 0...1),
                           green: Double.random(in: 0...1),
                           blue: Double.random(in: 0...1))
    }
    
    var body: some View {
        
        VStack {
            ZStack {
                VStack {
                    HStack { Spacer() }
                    Spacer()
                    
                    Circle()
                        .frame(width: 200, height: 200)
                        .foregroundStyle(color)
                        .shadow(color: color, radius: 50)
                    
                    Text("52")
                        .font(.custom("arial", size:  140))
                        .bold()
                        .fontWeight(.black)
                    
                    HStack {
                        Text( "Shuffle" )
                        
                        Image(systemName: "circle.hexagongrid")
                    }
                    .font(.title)
                    .onTapGesture { withAnimation { shuffleColor() } }
                    
                    Spacer()
                }
            }
            .stripedMask(at: angle, width: 2, spacing: 3, maskOpacity: 0.95)
            .stripedMask(at: secondaryAngle, width: 25, spacing: 5, maskOpacity: 0.7)
            
            .stripedFill(at: 45, width: 5, opacity: 0.02)
            .ignoresSafeArea()
        }
    }
}

#Preview {
//    RadialLinesControls()
    TestView()
}
