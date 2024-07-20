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

//MARK: LineFillDemoView
struct LineFillDemoView: View {
    
    @State private var angle: Double = 90
    
    @State private var secondaryAngle: Double = 0
    @State private var color: Color = .red
    
    private func shuffleColor() {
        self.color = Color(red: Double.random(in: 0...1),
                           green: Double.random(in: 0...1),
                           blue: Double.random(in: 0...1))
    }
    
    @ViewBuilder
    private func makePageDetails() -> some View {
        VStack {
            
            HStack {
                Text("Reading, MA")
                Text("Weather")
                    .bold()
                    .italic()
                    .foregroundStyle(.blue)
                
                Spacer()
                
                Image(systemName: "mountain.2")
                    .font(.body)
                    .padding(7)
                    .background {
                        RoundedRectangle(cornerRadius: 50)
                            .aspectRatio(1, contentMode: .fill)
                            .foregroundStyle(.black)
                        
                        RoundedRectangle(cornerRadius: 50)
                            .stroke(lineWidth: 1)
                            .opacity(0.8)
                    }
            }
            .font(.title2)
         
            Spacer()
            
            HStack {
                Spacer()
                Text("View more Details ")
                Image(systemName: "arrow.down")
                Spacer()
            }
            .font(.title3)
            .bold()
            .padding()
            .background() {
                RoundedRectangle(cornerRadius: 50)
                    .foregroundStyle(.black)
                
                RoundedRectangle(cornerRadius: 50)
                    .stroke(lineWidth: 1)
                    .opacity(0.8)
            }
        }
        .padding()
    }
    
//    MARK: LineFilleDemoFill 1
    @ViewBuilder
    private func makeContent1() -> some View {
        VStack {
            Circle()
                .frame(width: 200, height: 200)
                .foregroundStyle(color)
                .shadow(color: color, radius: 50)
            
            Text("67°")
                .font(.custom("arial", size:  140))
                .bold()
                .fontWeight(.black)
        }
    }
    
//    MARK: LineFilleDemoFill 1
    @ViewBuilder
    private func makeArc(startAngle: Double, endAngle: Double, in geo: GeometryProxy) -> Path {
        Path { path in
            path.addArc(center: .init(x: geo.size.width / 2, y: geo.size.height / 2),
                        radius: 100,
                        startAngle: .init(degrees: startAngle),
                        endAngle: .init(degrees: endAngle),
                        clockwise: false)
            
        }
    }
    
    @ViewBuilder
    private func makeContent2(in geo: GeometryProxy) -> some View {
        VStack {
            ZStack {
                Circle()
                    .frame(width: 200, height: 200)
                    .foregroundStyle(.gray.opacity(0.5))
                
                Image(systemName: "cloud.drizzle.fill")
                    .resizable()
                    .frame(width: 240, height: 240)
                    .foregroundStyle(.blue)
                    .shadow(color: .blue.opacity(0.3), radius: 50)
            }
            
            Text("45°")
                .font(.custom("arial", size:  140))
                .bold()
                .fontWeight(.black)
        }
    }
    
//    MARK: LineFillDemoview Body
    var body: some View {
        
        GeometryReader { geo in
            ZStack {
                VStack {
                    HStack { Spacer() }
                    Spacer()
                    
                    makeContent2(in: geo)
                    
                    Spacer()
                }
            }
        }
        .stripedMask(at: 50, width: 2, spacing: 5, maskOpacity: 0.95)
        .stripedFill(at: 50, width: 1, spacing: 8, opacity: 0.15)
        .ignoresSafeArea()
        .overlay {
            makePageDetails()
        }
    }
}

#Preview {
//    RadialLinesControls()
    LineFillDemoView()
}
