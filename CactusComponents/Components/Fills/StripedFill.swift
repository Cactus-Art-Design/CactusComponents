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

struct StripedFill<S>: ViewModifier where S: ShapeStyle {
    
//    MARK: ViewModifier Vars
    let angle: Double
    let lineWidth: Double
    let spacing: Double
    let opacity: Double
    let foregroundStyle: S
    let overlayWithNormal: Bool
    
    init( at angle: Double, width: Double, spacing: Double?, style: S, opacity: Double, overlayWithNormal: Bool ) {
        
        self.angle = (angle.truncatingRemainder(dividingBy: 180) == 0) ? 189.9 : angle
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
                    
                    let additionalLength = StripedLine.getAdditionalLength(angle: angle, in: .init(x: 0, y: 0,
                                                                                            width: geo.size.width,
                                                                                            height: geo.size.height)  )
                
                    let radAngle = (Double.pi * angle) / 180
                    let offset = (lineWidth + spacing) / abs(cos( Double.pi / 2 - radAngle ))
                    
                    let count = Int( (geo.size.width + additionalLength * 2) / (offset) )
                    
                    ZStack {
                        ForEach( 0...count, id: \.self ) { i in
                            StripedLine(angle: angle )
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
}

struct TestView: View {
    
    @State private var angle: Double = 45
    
    var body: some View {
        
        ZStack {
            GeometryReader { geo in
            }
            
            
            Rectangle()
                .foregroundStyle(.clear)
                .stripedFill(at: 90, width: 3, spacing: 6)
                .mask {
                    VStack {
                        Circle()
                            .frame(width: 200, height: 200)
                        
                        Text("\(52)")
                             .font(.custom("-", size: 120))
                    }
                    .shadow(color: .white, radius: 50)
                }
            
                
//                .bold()
//                .mask {
//                    Text("")
//                }
                
          
        }
        .stripedFill(at: 45, width: 5, opacity: 0.05)
        .ignoresSafeArea()
//        .compositingGroup()
//        .luminanceToAlpha()
    }
}

#Preview {
//    RadialLinesControls()
    TestView()
}
