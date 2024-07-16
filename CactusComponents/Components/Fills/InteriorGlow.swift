//
//  InteriorGlow.swift
//  CactusComponents
//
//  Created by Brian Masse on 7/13/24.
//

import Foundation
import SwiftUI

struct InteriorGlow: ViewModifier {
    
//    MARK: Line
    private struct Line: Shape {
        let radius: Double
        let vertical: Bool
        
        private func makeVerticalLine(in rect: CGRect) -> Path {
            Path{ path in
                path.addArc(center: .init(x: rect.minX + radius, y: rect.maxY - radius),
                            radius: radius,
                            startAngle: .init(degrees: 90),
                            endAngle: .init(degrees: 180), clockwise: false)
                
                
                path.move(to: .init(x: rect.minX, y: rect.maxY - radius))
                path.addLine(to: .init(x: rect.minX, y: rect.minY + radius))
            }
        }
        
        private func makeHorizontalLine( in rect: CGRect ) -> Path {
            Path{ path in
                path.addArc(center: .init(x: rect.minX + radius, y: rect.minY + radius),
                            radius: radius,
                            startAngle: .init(degrees: 180),
                            endAngle: .init(degrees: 270), clockwise: false)
                
                
                path.move(to: .init(x: rect.minX + radius, y: rect.minY))
                path.addLine(to: .init(x: rect.maxX - radius, y: rect.minY))
            }
        }
        
        func path(in rect: CGRect) -> Path {
            if vertical { makeVerticalLine(in: rect) }
            else { makeHorizontalLine(in: rect) }
        }
    }
    
//    MARK: MakeLine
    @ViewBuilder
    private func makeLine( rotation: Rotation,
                           primaryBlur: Double? = nil,
                           secondaryBlur: Double? = nil,
                           lineWidth: Double? = nil,
                           secondarLineWidth: Double? = nil) -> some View {
        
        ZStack {
            
            Line(radius: radius, vertical: (rotation == .left || rotation == .right) ? true : false )
            .stroke(lineWidth: lineWidth == nil ? self.lineWidth : lineWidth!)
            .blur(radius: primaryBlur == nil ? self.primaryBlur : primaryBlur!)
            .opacity(0.5)
            
            Line(radius: radius, vertical: (rotation == .left || rotation == .right) ? true : false )
                .stroke(lineWidth: secondarLineWidth == nil ? self.secondarLineWidth : secondarLineWidth!)
                .blur(radius: secondaryBlur == nil ? self.secondaryBlur: secondaryBlur!)
            
            Line(radius: radius, vertical: (rotation == .left || rotation == .right) ? true : false )
                .stroke(lineWidth: 2)
                .opacity(opacity)
        }
        .rotationEffect(.init(degrees: rotation == .right || rotation == .bottom ? 180 : 0))
        
    }
    
    private enum Rotation: Int {
        case left
        case right
        case top
        case bottom
    }
    
//    MARK: Vars
    let radius: Double
    
    let primaryBlur: Double
    let secondaryBlur: Double
    
    let lineWidth: Double
    let secondarLineWidth: Double
    
    let opacity: Double
    
//    MARK: Body
    func body(content: Content) -> some View {
        let secondaryColor = Color(red: 255/255, green: 240/255, blue: 209/255 )
        
        content.background {
            Rectangle()
                .opacity(0.1)
            
                .overlay {
                    
                    makeLine(rotation: .left)
                        .foregroundStyle(secondaryColor)
                    
                    makeLine(rotation: .top)
                        .foregroundStyle(secondaryColor)
                    
                    makeLine(rotation: .right)
//
                    makeLine(rotation: .bottom)
                    
                }
                .clipShape(RoundedRectangle(cornerRadius: radius))
        }
    }
//    }
}

//MARK: ViewExtension
extension View {
    
    func interiorGlow(in radius: Double = 20,
                      primaryBlur: Double = 35,
                      secondaryBlur: Double = 10,
                      lineWidth: Double = 30,
                      secondaryLineWidth: Double = 15,
                      opacity: Double = 1) -> some View {
        
        modifier(InteriorGlow(radius: radius,
                              primaryBlur: primaryBlur,
                              secondaryBlur: secondaryBlur,
                              lineWidth: lineWidth,
                              secondarLineWidth: secondaryLineWidth,
                              opacity: opacity))
    }
    
    func interiorGlow( radius: Double, isFocussed: Bool = false ) -> some View {
        modifier(InteriorGlow(radius: radius,
                              primaryBlur: isFocussed ? 35 : 40,
                              secondaryBlur: isFocussed ? 10 : 25,
                              lineWidth: isFocussed ? 30 : 10,
                              secondarLineWidth: isFocussed ? 15 : 5,
                              opacity: isFocussed ? 1 : 0.35))
    }
}

//MARK: InteriorGlowTestView

struct InteriorGlowTestView: View {
    
    let bodyText: String = "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua."
    
    @State private var radius: Double = 20
    
    @State private var primaryBlur: Double = 35
    @State private var secondaryBlur: Double = 10
    
    @State private var lineWidth: Double = 30
    @State private var secondarLineWidth: Double = 15
    
    @State private var selectedContent: Int = 0
    
    @ViewBuilder
    private func makeControl( title: String, value: Binding<Double>, in range: ClosedRange<Double> ) -> some View {
        
        VStack(alignment: .leading, spacing: 5) {
            Text( title )
                .font(.callout)
                .bold()
            
            HStack {
                Slider(value: value, in: range, step: 1)
                
                Text("\(Int( value.wrappedValue ))")
            }
        }
        .padding(.bottom, 7)
        
    }
    
//    MARK: ContentBuilders
    @ViewBuilder
    private func makeControls() -> some View {
        
        makeControl(title: "Radius", value: $radius, in: 0...50)
        
        HStack {
            makeControl(title: "Blur", value: $primaryBlur, in: 0...100)
            
            makeControl(title: " ", value: $secondaryBlur, in: 0...100)
        }
        
        HStack {
            makeControl(title: "Strength", value: $lineWidth, in: 1...50)
            
            makeControl(title: " ", value: $secondarLineWidth, in: 1...50)
        }
        
    }
    
    @ViewBuilder
    private func makeContent(_ index: Int, title: String, subTitle: String, body: String) -> some View {
        
        VStack(alignment: .leading) {
            HStack { Spacer() }
            Text(title)
                .font(.title)
                .bold()
            
            Text(subTitle)
                .font(.callout)
                .bold()
                .padding(.bottom)
            
            Text(body)
                .font(.caption)
            
            Spacer()
        }
        .padding()
        .contentShape(Rectangle())
        .opacity( selectedContent == index ? 1 : 0.4 )
        .onTapGesture { withAnimation { selectedContent = index } }
        .interiorGlow(radius: radius, isFocussed: selectedContent == index)
        
    }
    
//    MARK: Body
    var body: some View {
        
        VStack {
            
            makeControls()
            
            HStack {
                makeContent(0, title: "hello", subTitle: "hello world", body: bodyText)
                
                makeContent(1, title: "hello", subTitle: "hello world", body: bodyText)
            }
            
            makeContent(2, title: "hello", subTitle: "hello world", body: bodyText)
            
            Spacer()
        }
        .padding()
    }
}

#Preview {
    
    InteriorGlowTestView()
    
}
