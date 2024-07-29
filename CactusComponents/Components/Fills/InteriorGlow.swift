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
    
    @State var dic: Dictionary< String, Binding<Double> > = [:]
    
    
    @State private var radius: Double = 20
    
    @State private var primaryBlur: Double = 35
    @State private var secondaryBlur: Double = 10
    
    @State private var lineWidth: Double = 30
    @State private var secondarLineWidth: Double = 15
    
    @State private var selectedContent: Int = 0
    
//    MARK: ContentBuilders
    @ViewBuilder
    private func makeControls() -> some View {
        
        CactusComponentControl("Radius", for: $radius, in: 0...50)
        
        HStack {
            CactusComponentControl("Blur", for: $primaryBlur, in: 0...100)
            
            CactusComponentControl(" ", for: $secondaryBlur, in: 0...100)
        }
        
        HStack {
            CactusComponentControl("Strength", for: $lineWidth, in: 1...50)
            
            CactusComponentControl(" ", for: $secondarLineWidth, in: 1...50)
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
//        .interiorGlow(in: radius, primaryBlur: 35, secondaryBlur: 10, lineWidth: lineWidth, secondaryLineWidth: dic["test"]?.wrappedValue ?? 0, opacity: 1)
        
    }
    
//    MARK: Body
    var body: some View {
        
        GeometryReader { geo in
            ZStack(alignment: .bottom) {
                VStack(alignment: .leading) {
                    
                    makeControls()
                    
//                    Spacer(minLength: geo.size.height * 0.356)
                    
                    Text("My Overview")
                        .textCase(.uppercase)
                        .opacity(0.7)
                    
                    HStack {
                        makeContent(0, title: "$1456", subTitle: "Primary Account", body: bodyText)
                        
                        makeContent(1, title: "¥89772.15", subTitle: "Investment Account", body: bodyText)
                    }
                    
                    makeContent(2, title: "Account History", subTitle: "", body: bodyText)
                }
                
                HStack {
                    Image( systemName: "doc.text.magnifyingglass" )
                        .opacity(0.7)
                    Text("Search")
                        .opacity(0.7)
                    Text("Accounts")
                        .bold()
                    
                    Spacer()
                }
                .textCase(.uppercase)
                .padding()
                .background {
                    RoundedRectangle(cornerRadius: 50)
                        .stroke(lineWidth: 2)
                        .opacity(0.7)
                    
                    RoundedRectangle(cornerRadius: 50)
                        .foregroundStyle(.black)
                }
                .padding([.horizontal])
                .offset(y: 10)
            }
        }
        .padding()
    }
}

#Preview {
    
    InteriorGlowTestView()
    
}
