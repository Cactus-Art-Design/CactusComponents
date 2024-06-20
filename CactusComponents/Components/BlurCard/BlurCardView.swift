//
//  CardView.swift
//  BlurCardDemo
//
//  Created by Brian Masse on 5/25/24.
//

import Foundation
import SwiftUI

@available(iOS 15.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
internal struct BlurCard: View, Animatable {
    
//    MARK: Constants
    struct LocalConstants {
        static let width: CGFloat = 300
        static let aspectRatio: CGFloat = 4/3
        
        static let titleFont = "SpaceGrotesk-Medium"
        static let mainFont = "SpaceGrotesk-Regular"
        
        static let dotScale: CGFloat = 1
    }
        
    //    MARK: Vars
        let image: String
        
        @State var xRotation: Angle = Angle(degrees: 0)
        @State var yRotation: Angle = Angle(degrees: 0)
        
        @State var scale: CGFloat = 1
        @State var threshold: CGFloat = 0.3
        @State var saturation: CGFloat = 0.9

        private func checkIsOnBack() -> Bool {
            return floor((abs(xRotation.degrees) + 90) / 180).remainder(dividingBy: 2) != 0
        }
        
        private var dragGesture: some Gesture {
            DragGesture()
                .onChanged { value in
                    xRotation = Angle(degrees: value.translation.width)
                    yRotation = Angle(degrees: -value.translation.height / 10)
                }
                .onEnded { value in
                    withAnimation {
                        xRotation = Angle(degrees: 0)
                        yRotation = Angle(degrees: 0)
                    }
                }
    }
    
//    MARK: Overlay
@available(iOS 15.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
private struct AnimatingOverlay: AnimatableModifier {
    var threshold: Double
    let image: String

    var animatableData: Double {
        get { threshold }
        set { threshold = newValue }
    }
        
        @ViewBuilder
        private func makeImage(_ image: String) -> some View {
            Image(image)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: LocalConstants.width, height: LocalConstants.width * LocalConstants.aspectRatio)
                .clipped()
        }
        
        @ViewBuilder
        private func makeDottedOverlay(threshold: CGFloat) -> some View {
            Canvas { context, size in
                context.addFilter(.alphaThreshold(min: threshold, color: .white))
                context.addFilter(.blur(radius: 0.4))
                context.addFilter(.luminanceToAlpha)
                
                context.drawLayer { ctx in
                    let image = ctx.resolveSymbol(id: 2)!
                    
                    ctx.draw(image, at: .init(x: size.width / 2, y: size.height / 2))
                }
                
            } symbols: {
                ZStack {
                    
                    makeImage(image)
                        .grayscale(1)
                        .blur(radius: threshold)
                    
                    makeImage("texture")
                        .scaleEffect(BlurCard.LocalConstants.dotScale)
                        .clipped()
                        .blendMode( .colorDodge )
                        .rotationEffect(Angle(degrees: threshold))
                
                }
                .tag(2)
            }
            .frame(height: 450)
        }

        func body(content: Content) -> some View {
            content.overlay(
                makeDottedOverlay(threshold: threshold)
                    .blendMode(.overlay)
                    .opacity(0.2)
            )
        }
    }
    
//    MARK: Background
    @ViewBuilder
    private func makeImage(_ image: String) -> some View {
        Image(image)
            .resizable()
            .aspectRatio(contentMode: .fill)
            .frame(width: LocalConstants.width, height: LocalConstants.width * LocalConstants.aspectRatio)
            .clipped()
    }
    
    @ViewBuilder
    private func makeBackground() -> some View {
        ZStack {
            makeImage(image)
                .blur(radius: 30)
                .modifier(AnimatingOverlay(threshold: threshold, image: image))
            
            makeImage("noise")
                .opacity(0.1)
                .blendMode(.overlay)
        }
        .scaleEffect(1.3)
        .blur(radius: 0.2)
        .saturation(saturation)
        .frame(width: LocalConstants.width, height: LocalConstants.aspectRatio * LocalConstants.width)
        .overlay(.white.opacity(0.1))
        .contentShape( RoundedRectangle(cornerRadius: 25) )
        .clipShape( RoundedRectangle(cornerRadius: 25) )

        .shadow(color: .black.opacity(0.3), radius: 0.5, x: 1, y: 1)
        .shadow(color: .white.opacity(0.2), radius: 0.5, x: -1, y: -1)
    }
    
//    MARK: Content
    @ViewBuilder
    private func makeTitle() -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 0) {
                Text("Brian")
                    .textCase(.uppercase)
                    .font(Font.custom(LocalConstants.titleFont, size: 35))
                Text("Masse")
                    .textCase(.uppercase)
                    .font(Font.custom(LocalConstants.titleFont, size: 35))
                    .offset(y:-15)
            }
            
            Image(systemName: "staroflife.fill")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 20)
            
            Spacer()
        }
    }
    
    @ViewBuilder
    private func makeDetail(title: String, detail: String) -> some View {
        VStack(alignment: .leading, spacing: 0 ) {
            Text(title)
                .textCase(.uppercase)
                .font(Font.custom(LocalConstants.mainFont, size: 10))
            
            Text(detail)
                .textCase(.uppercase)
                .font(Font.custom(LocalConstants.titleFont, size: 20))
                .padding(.bottom)
        }
    }
    
    @ViewBuilder
    private func makeDetails() -> some View {
        makeDetail(title: "card number", detail: "2821 **** **** 1002")
        
        makeDetail(title: "card holder", detail: "Brain J. Masse")
        
        HStack(spacing: 15) {
            makeDetail(title: "Exp. Date", detail: "10/28")
            makeDetail(title: "CCV", detail: "***")
            
            Spacer()
        }
    }

    @ViewBuilder
    private func makeContent() -> some View {
        VStack(alignment: .leading, spacing: 0) {
            if !checkIsOnBack() {
                makeTitle()
                
                Spacer()
                
                makeDetails()
            }
        }
        .padding(30)
        .foregroundStyle(.white)
    }
    
//    MARK: Body
    var body: some View {
        makeBackground()
            .overlay { makeContent() }
        
            .rotation3DEffect( xRotation, axis: (x: 0, y: 0.5, z: 0), perspective: 0.1 )
            .rotation3DEffect( yRotation, axis: (x: 0, y: 0, z: 1), perspective: 0 )
            .gesture(dragGesture)
            .scaleEffect(scale)
        
            .shadow(color: .black.opacity(0.35), radius: 25, x: 0, y: 10)
            .animation(
                .easeInOut(duration: 0.2)
                , value: scale)
            
            .onTapGesture {
                scale = 1.05
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { scale = 1 }
            }
            .animation(.easeInOut(duration: 5).repeatForever(autoreverses: true), value: threshold)
            .animation(.easeInOut(duration: 12).repeatForever(autoreverses: true), value: saturation)
        
            .task { withAnimation {
                threshold = 0.99
                saturation = 1.7
            }}
    }
}

