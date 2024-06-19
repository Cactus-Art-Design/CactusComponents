//
//  ContentView.swift
//  WaveLoadingDemo
//
//  Created by Brian Masse on 5/29/24.
//

import SwiftUI

@available(iOS 15.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
public final class LoadingWaveComponent: CactusComponent, SingleInstance {
    private init() {
        super.init(name: "Loading Wave Demo",
                   description: "This is an infinite wave loading view") {
            LoadingWavePreview()
        }
    }
    
    public static var shared: LoadingWaveComponent = LoadingWaveComponent()
}

@available(iOS 15.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
private struct LoadingWavePreview: View {
    var body: some View {
        VStack {
            Spacer()
            WaveLoadingView()
            Spacer()
        }
        .background(.white)
    }
}

//MARK: LoadingView
@available(iOS 15.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
private struct WaveLoadingView: View {
        
    struct SinCurve: AnimatableModifier {
        @Environment(\.colorScheme) var colorScheme
        
        let geo: GeometryProxy
        
        var shift: Double
        
        private let step: CGFloat = 1
        
        let color: Color
        let amplitude: CGFloat
        let horizontalScale: CGFloat
        let glowScale: CGFloat

        var animatableData: Double {
            get { shift }
            set { shift = newValue }
        }
        
//        MARK: SinCurve
        private func graph( x: CGFloat ) -> CGFloat {
            let sin1 = sin(1/(1*horizontalScale) * x - shift * 1) * amplitude
            let sin2 = sin(1/(2*horizontalScale) * x - shift * 1/5) * amplitude
            let sin3 = sin(1/(3*horizontalScale) * x - shift * 1/10) * amplitude
            
            return sin1 + 0.8 * sin2 + 0.5 * sin3
        }
        
        private func derivative( x: CGFloat ) -> CGFloat {
            let cos1 = 1/10 * amplitude * cos(1/10 * x - shift * 1)
            let cos2 = 1/20 * amplitude * cos(1/20 * x - shift * 1/5)
            let cos3 = 1/33 * amplitude * cos(1/33 * x - shift * 1/10)
            
            return cos1 + cos2 + cos3
        }
        
        private func makeSinCurve(scale: CGFloat = 1, reverse: Bool = false) -> Path {
            Path { path in
                
                let startX: CGFloat = !reverse ? 0 : geo.size.width
                let endX:   CGFloat = !reverse ? geo.size.width : 0
                var x = startX
                
                let transY = geo.size.height / 2
                
                path.move(to:    .init(x: startX, y: graph(x: startX) * scale + transY ))
                
                for _ in 0..<Int(abs(endX - x) / step) {
                    x += !reverse ? step : -step
                    path.addLine(to: .init(x: x, y: graph(x: x) * scale + transY))
                }
            }
        }
        
//        MARK: VariableWidthCurve
        private func makeVariableWidthCurve(baseScale: CGFloat, boostScale: CGFloat) -> Path {
            Path { path in
                let transY = geo.size.height / 2
                
                path.move(to: .init(x: 0, y: graph(x: 0) + transY ))
                path.addPath(makeSinCurve(scale: boostScale))
                
                path.addLine(to: .init(x: geo.size.width, y: graph(x: geo.size.width) * baseScale + transY ))
                path.addPath(makeSinCurve(scale: baseScale, reverse: true))
                
                path.addLine(to: .init(x: 0, y: graph(x: 0) * boostScale + transY ))
            }
        }
        
        private var fullPath: Path {
            Path { path in
                
                let scaledAmplitude = amplitude * 4
                let transY = geo.size.height / 2
                
                path.move(to:       .init(x: 0, y: scaledAmplitude + transY))
                path.addLine(to:    .init(x: 0, y: graph(x: 0) + transY ))
                
                path.addPath(makeSinCurve())
                
                path.addLine(to: .init(x: geo.size.width, y: scaledAmplitude + transY))
                path.addLine(to: .init(x: 0, y: scaledAmplitude + transY))
            }
        }
        
//        MARK: LinearGradient
        private var linearGradient: LinearGradient {
            LinearGradient(colors: [.white, .white.opacity(0.2), .clear], startPoint: .top, endPoint: .bottom)
        }
        
        @ViewBuilder
        private func makeLinearGradientOverlay() -> some View {
            ZStack {
                Rectangle().foregroundStyle(.clear)
                
                linearGradient
                    .blur(radius: 5)
                    .frame(height: amplitude * 6)
            }
            .mask( { fullPath })
        }
        
//        MARK: Body
        func body(content: Content) -> some View {
            let opacityScale = 1.0
            
            content.overlay {
                ZStack {
                    makeSinCurve()
                        .stroke(lineWidth: 20)
                        .foregroundStyle(color)
                        .blur(radius: 40)
                        .opacity(0.8 * opacityScale)
                    
                    makeVariableWidthCurve(baseScale: 1, boostScale: 2.5 * glowScale)
                        .foregroundStyle(color)
                        .blur(radius: 15)
                        .opacity(0.2 * opacityScale)
                    
                    makeVariableWidthCurve(baseScale: 1, boostScale: -2.5 * glowScale)
                        .foregroundStyle( colorScheme == .dark ? .black : .white)
                        .blur(radius: 15)
                        .opacity(0.2 * opacityScale)
                    
                    
                    makeVariableWidthCurve(baseScale: 1, boostScale: 2 * glowScale)
                        .foregroundStyle(color)
                        .blur(radius: 10)
                        .opacity(0.5 * opacityScale)
                    
                    makeVariableWidthCurve(baseScale: 1, boostScale: -2 * glowScale)
                        .foregroundStyle(colorScheme == .dark ? .black : .white)
                        .blur(radius: 10)
                        .opacity(0.5 * opacityScale)
                    
                    
                    makeVariableWidthCurve(baseScale: 1, boostScale: 1.5 * glowScale)
                        .foregroundStyle(color)
                        .blur(radius: 7)
                        .opacity(0.8 * opacityScale)
                    
                    makeVariableWidthCurve(baseScale: 1, boostScale: -1.5 * glowScale)
                        .foregroundStyle(colorScheme == .dark ? .black : .white)
                        .blur(radius: 7)
                        .opacity(0.8 * opacityScale)
                    
                    
                    makeVariableWidthCurve(baseScale: 0.9, boostScale: 1.3 * glowScale)
                        .foregroundStyle(color)
                        .blur(radius: 3)
                        .opacity(1 * opacityScale)
                    
                    makeVariableWidthCurve(baseScale: 0.9, boostScale: -1.3 * glowScale)
                        .foregroundStyle(colorScheme == .dark ? .black : .white)
                        .blur(radius: 3)
                        .opacity(1 * opacityScale)
                    
                    makeSinCurve()
                        .stroke()
                        .foregroundStyle(color)
                        .opacity(0.3)
                    
                }
                .overlay {
                    let dir = floor(self.shift.truncatingRemainder(dividingBy: 2))
                    
                    Image( "noise" )
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(height: geo.size.height)
                        .scaleEffect(2)
                        .rotationEffect(.degrees( dir * 90))
                        .blendMode(.colorDodge)
                        .opacity(0.1)
                        .clipped()
                        .allowsHitTesting(false)
                    
                    Image( "noise" )
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(height: geo.size.height)
                        .scaleEffect(2)
                        .rotationEffect(.degrees( dir * 90))
                        .blendMode(.colorBurn)
                        .opacity(0.2)
                        .clipped()
                        .allowsHitTesting(false)
                }
            }
        }
    }

//    MARK: Vars
    @Environment(\.colorScheme) var colorScheme
    
    @State private var color: Color = .black
    @State private var amplitude: CGFloat = 20
    @State private var horizontalScale: CGFloat = 40
    @State private var glowScale: CGFloat = 0.8
    @State private var speed: CGFloat = 13
    
    @State var showingEditScreen: Bool = false
    @State var shift: CGFloat = 0

    @ViewBuilder
    private func makeHeader() -> some View {
        HStack {
            Text("Wave Loading")
                .textCase(.uppercase)
            
            Spacer()
            
            Image(systemName: "righttriangle.split.diagonal")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 20)
                .padding(.horizontal)
                .onTapGesture { withAnimation { showingEditScreen.toggle() }}
        }
        .padding()
    }
    
//    MARK: SettingsPage
    private func setColorToBlackAndWhite() {
        self.color = colorScheme == .dark ? .white : .black
    }
    
    private func checkBlackAndWhite() -> Color {
        if self.color == .black || self.color == .white {
            self.setColorToBlackAndWhite()
            return self.color
        }
        return self.color
    }
    
    @ViewBuilder
    private func makeSlider(_ title: String, property: Binding<CGFloat>, range: ClosedRange<CGFloat>) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(title)
                .textCase(.uppercase)
            HStack {
                Text("\(Int(range.lowerBound))")
                    .font(.caption)
                
                Slider(value: property, in: range)
                    .tint(colorScheme == .light ? .black : .white)
                
                Text("\(Int(range.upperBound))")
                    .font(.caption)
            }
        }
    }
    
    @ViewBuilder
    private func makeSettingsPage() -> some View {
        VStack(alignment: .leading, spacing: 20) {
            makeSlider("amplitude", property: $amplitude, range: 1...100)
            
            makeSlider("periodScale", property: $horizontalScale, range: 1...100)
            
            makeSlider("glowScale", property: $glowScale, range: 0...1)
            
            HStack {
                Image(systemName: "circle.lefthalf.filled.righthalf.striped.horizontal.inverse")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 25)
                    .onTapGesture { withAnimation { setColorToBlackAndWhite() }}
                
                ColorPicker(selection: $color, supportsOpacity: true, label: {
                    Rectangle()
                        .foregroundStyle(color)
                        .frame(height: 30)
                        .cornerRadius(24)
                })
            }
        }
        .padding()
    }
    
//    MARK: Body
    var body: some View {
        VStack {
            makeHeader()
            
            if showingEditScreen {
                makeSettingsPage()
            }
            
            GeometryReader { geo in
                Rectangle()
                    .foregroundStyle(.clear)
                    .modifier(SinCurve(geo: geo,
                                       shift: shift,
                                       color: checkBlackAndWhite(),
                                       amplitude: amplitude,
                                       horizontalScale: horizontalScale,
                                       glowScale: glowScale))
                    .animation(.linear(duration: speed).repeatForever(autoreverses: false), value: shift)
                    .onAppear { withAnimation {
                        self.shift = 20 * Double.pi
                    } }
            }
            .contentShape(Rectangle())
        }
    }
}
