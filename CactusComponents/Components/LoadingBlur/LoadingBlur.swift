//
//  ContentView.swift
//  LoadingBlurDemo
//
//  Created by Brian Masse on 5/30/24.
//

import SwiftUI

//MARK: Component Conformance
@available(iOS 15.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
public final class LoadingBlurComponent: CactusComponent, SingleInstance {
    private init() {
        super.init(name: "Loading Blur Demo",
                   description: "This is a styled, animated loading background") {
            LoadingBlurViewPreview()
        }
    }
    
    public static var shared: LoadingBlurComponent = LoadingBlurComponent()
}

@available(iOS 15.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
private struct LoadingBlurViewPreview: View {
    var body: some View {
        ZStack {
            BlurredBackground()
            
            Text( "hello." )
                .font(Font.custom("Bodoni 72", size: 25))
        }
    }
}

//MARK: BurredBackground
@available(iOS 15.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
private struct BlurredBackground: View {
    
    @Environment(\.colorScheme) var colorScheme
    
    struct BlurComponent: View {
        
        let geo: GeometryProxy
        let radius: CGFloat
        
        @State var animating: Bool = true
        @State var horizontalOffset: CGFloat = 0
        @State var verticalOffset: CGFloat = 0
        @State var opacity: CGFloat = 1
        
        let animationDuration: Double
        @State var dynamicDuration: Double = 1
    
        
        @Binding var holding: Bool
        let color: Color
        
        private var duration: CGFloat {
            animationDuration * (self.holding ? 0.3 : 1 )
        }
        
        private func runAnimation() {
            if !animating { return }
            
            let width = Double.random(in: 0...geo.size.width)
            let height = Double.random(in: 0...geo.size.height)
            
            let xDistance = abs( self.horizontalOffset - width )
            let yDistance = abs( self.verticalOffset - height )
            
//            let distance = sqrt( pow(xDistance, 2) + pow(yDistance, 2) )
            self.dynamicDuration = duration
//            * distance / 100
            
            withAnimation( .easeInOut(duration: self.dynamicDuration) ) {
                self.horizontalOffset = width
                self.verticalOffset = height
                self.opacity = CGFloat.random(in: 0.1...1)
            }
        }
        
        
        var body: some View {
            if #available(iOS 17.0, *) {
                Circle()
                    .offset(x: horizontalOffset - radius,
                            y: verticalOffset - radius)
                    .frame(width: radius * 2, height: radius * 2)
                    .foregroundStyle(color)
                    .saturation(3)
                    .opacity(opacity)
                
                    .onChange(of: horizontalOffset, {
                        DispatchQueue.main.asyncAfter(deadline: .now() + dynamicDuration) {
                            runAnimation()
                        }
                    })
                
                    .onAppear {
                        let width = Double.random(in: 0...geo.size.width)
                        let height = Double.random(in: 0...geo.size.height)
                        
                        self.horizontalOffset = width
                        self.verticalOffset = height
                        runAnimation()
                    }
            } else {
                // Fallback on earlier versions
            }
        }
    }
    
//    MARK: Vars
    private var defaultColors = [  c(r: 176, g: 158, b:153),
                                   c(r: 255, g: 233, b:225),
                                   c(r: 250, g: 212, b:192),
                                   c(r: 100, g: 182, b: 172),
                                   c(r: 192, g:253, b: 251),
                                   .red.opacity(0.7) ]
    
    @State var holding: Bool = false
    @State var colors: [Color] = [.red]
    
    static func c(r: Double, g: Double, b: Double) -> Color {
        .init(red: r/255, green: g/255, blue: b/255)
    }
    
    private func scrambleColors() {
        for i in 0..<colors.count {
            let r = Double.random(in: 0...1)
            let g = Double.random(in: 0...1)
            let b = Double.random(in: 0...1)
            
            let color: Color = .init(red: r, green: g, blue: b)
            self.colors[i] = color
        }
    }
    
    private var holdGesture: some Gesture {
        DragGesture(minimumDistance: 0)
            .onChanged { value in self.holding = true }
            .onEnded { value in self.holding = false }
    }
    
//    MARK: Body
    var body: some View {
        
        GeometryReader { geo in
            ZStack(alignment: .topTrailing) {
                ForEach( 0...15, id: \.self ) { i in
                    let radius = Double.random(in: 100...350)
                    let animationDuration = Double.random(in: 3...7)
                    
                    let index = (i % (colors.count))
                    let color = colors[index]
                    
                    BlurComponent(geo: geo,
                                  radius: radius,
                                  animationDuration: animationDuration,
                                  holding: $holding,
                                  color: color)
                }
            }
            .blur(radius: 100)
            .opacity( colorScheme == .dark ? 0.3 : 1)
                
            
            Image("noise")
                .resizable()
                .ignoresSafeArea()
                .frame(height: geo.size.height)
                .aspectRatio(contentMode: .fit)
                .clipped()
                .blendMode(.overlay)
                .opacity(0.1)
                .scaleEffect(1.2)
            
            HStack {
                Spacer()
                
                Image(systemName: "circle.dotted")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 25)
                    .padding(.horizontal, 7)
                    .onTapGesture { withAnimation { self.colors = defaultColors } }
                
                Image(systemName: "circle.hexagongrid")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 25)
                    .padding(.horizontal, 7)
                    .onTapGesture { withAnimation { scrambleColors() } }
            }
            .padding()
        }
        .contentShape(Rectangle())
        .clipped()
        .background(colors[0].opacity(colorScheme == .dark ? 0.2 : 0.7))
        .gesture(holdGesture)
        .onAppear { colors = defaultColors }
    }
}
