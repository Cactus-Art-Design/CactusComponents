//
//  InteriorGlow.swift
//  CactusComponents
//
//  Created by Brian Masse on 7/13/24.
//

import Foundation
import SwiftUI

struct InteriorGlow: View {
    
//    MARK: Line
    private struct Line: Shape {
        let radius: Double
        
        func path(in rect: CGRect) -> Path {
            Path{ path in
                
                path.addArc(center: .init(x: rect.minX + radius, y: rect.maxY - radius),
                            radius: radius,
                            startAngle: .init(degrees: 90),
                            endAngle: .init(degrees: 180), clockwise: false)
                
                
                path.move(to: .init(x: rect.minX, y: rect.maxY - radius))
                path.addLine(to: .init(x: rect.minX, y: rect.minY + radius))
                
                path.addArc(center: .init(x: rect.minX + radius, y: rect.minY + radius),
                            radius: radius,
                            startAngle: .init(degrees: 180),
                            endAngle: .init(degrees: 270), clockwise: false)
                
            }
        }
    }
    
//    MARK: MakeLine
    @ViewBuilder
    private func makeLine( rotation: Double,
                           primaryBlur: Double? = nil,
                           secondaryBlur: Double? = nil,
                           lineWidth: Double? = nil,
                           secondarLineWidth: Double? = nil) -> some View {
        
        ZStack {
            
            Line(radius: radius)
            .stroke(lineWidth: lineWidth == nil ? self.lineWidth : lineWidth!)
            .blur(radius: primaryBlur == nil ? self.primaryBlur : primaryBlur!)
            .opacity(0.5)
            
            Line(radius: radius)
                .stroke(lineWidth: secondarLineWidth == nil ? self.secondarLineWidth : secondarLineWidth!)
                .blur(radius: secondaryBlur == nil ? self.secondaryBlur: secondaryBlur!)
            
            Line(radius: radius)
                .stroke(lineWidth: 2)
//                .blur(radius: 5)
        }
        .rotationEffect(.init(degrees: rotation))
        
    }
    
//    MARK: Vars
    let radius: Double = 20
    
    let primaryBlur: Double = 35
    let secondaryBlur: Double = 10
    
    let lineWidth: Double = 30
    let secondarLineWidth: Double = 15
    
//    MARK: Body
    var body: some View {
        
        let secondaryColor = Color(red: 255/255, green: 240/255, blue: 209/255 )
     
//        Slider(value: $radius, in: 0...50)
        
        Rectangle()
            .frame(width: 200, height: 200)
            .opacity(0.1)
        
            .overlay {
                
                makeLine(rotation: 0)
                .foregroundStyle(secondaryColor)
                
                makeLine(rotation: 90)
                    .foregroundStyle(secondaryColor)
                
                makeLine(rotation: 180)
                
                makeLine(rotation: -90)
                
            }
            .clipShape(RoundedRectangle(cornerRadius: radius))
    }
}

//MARK: InteriorGlowTestView

struct InteriorGlowTestView: View {
    
    let radius: Double = 20
    
    let primaryBlur: Double = 35
    let secondaryBlur: Double = 10
    
    let lineWidth: Double = 30
    let secondarLineWidth: Double = 15
    
    var body: some View {
        
        
        Text("Hello World!")
            .font(.title)
            .bold()
        
        Text("This is a simple effect!")
        
        
    }
}

#Preview {
    
    InteriorGlowTestView()
    
}
