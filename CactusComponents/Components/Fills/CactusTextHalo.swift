//
//  CactusTextHalo.swift
//  CactusComponents
//
//  Created by Brian Masse on 7/27/24.
//

import Foundation
import SwiftUI
import UIUniversals

//MARK: Preference Keys

private struct WidthPreferenceKey: PreferenceKey {
    static var defaultValue: Double = 0
    static func reduce(value: inout Double, nextValue: () -> Double) {
        value = nextValue()
    }
}

private struct Sizeable: View {
    var body: some View {
        GeometryReader { geometry in
            Color.clear
                .preference(key: WidthPreferenceKey.self, value: geometry.size.width)
        }
    }
}


//MARK: CactusTextHalo
struct CactusTextHalo<C: View>: View, Animatable {
 
    
//    MARK: Vars
    var angle: Double
    var animatableData: Double {
        get { angle }
        set { angle = newValue }
    }

    let text: String
    let radius: Double
    
    let verticalPerspective: Double
    let backgroundOpacity: Double
    let maskedAngles: ClosedRange<Double>
    
    let contentBuilder: (String) -> C
    
    @State var textWidths: [Int:Double] = [:]
    
    var texts: [(offset: Int, element: Character)] {
        return Array(text.enumerated())
    }
    
    init( _ text: String,
          at angle: Double,
          in radius: Double,
          verticalPerspective: Double = 0.5,
          backgroundOpacity: Double = 0.1,
          maskedAngles: ClosedRange<Double> = 90...270,
          @ViewBuilder contentBuilder: @escaping (String) -> C) {
        
        self.text = text
        self.angle = angle
        self.radius = radius
        self.verticalPerspective = verticalPerspective
        self.backgroundOpacity = backgroundOpacity
        self.maskedAngles = maskedAngles
        self.contentBuilder = contentBuilder
        
    }
    
    
//    MARK: Struct Metods
    private func makeTextWidth() -> Double {
        let circumference = 2 * Double.pi * radius
        return circumference / Double( texts.count )
    }
    
    private func makeAngle(from index: Int) -> Double {
        let circumference = 2 * Double.pi * radius
        let previousOffsets = textWidths.filter{$0.key < index}.map{$0.value}.reduce(0, +)
        let percentage = (previousOffsets + (textWidths[index] ?? 0) / 2) / circumference

        let proposedAngle = (360 * percentage) + self.angle
        return proposedAngle.truncatingRemainder(dividingBy: 360)
    }
    
    private var verticalPerspectiveDir: Double {
        verticalPerspective / abs(verticalPerspective)
    }
    
//    MARK: Body
    var body: some View {

        ZStack {
            ForEach( texts, id: \.offset ) { index, char in
                
                let angle = makeAngle(from: index)
                let shouldHide = angle > maskedAngles.lowerBound && angle < maskedAngles.upperBound
                
                ZStack {
                    contentBuilder( "\(char)" )
                        .background(Sizeable())
                        .onPreferenceChange(WidthPreferenceKey.self, perform: { width in
                            textWidths[index] = width
                        })
                }
                .zIndex( abs( Double(texts.count) - angle ) )
                .opacity(shouldHide ? backgroundOpacity : 1)
            
                .frame(width: textWidths[index] ?? 200)
                .rotation3DEffect(
                    .init(degrees: -angle),
                    axis: (x: 0.0, y: 1.0, z: 0.0),
                    anchor: .init(x: 0.5, y: 0.5 + verticalPerspective ),
                    perspective: 0.5
                )
//                
                .offset(x:  sin( (Double.pi * angle) / 180 ) * radius  )
                .offset(y:  cos( (Double.pi * angle) / 180 ) * radius * verticalPerspective )
                
            }
        }
//        .rotationEffect(.init(degrees: 20))
    }
}

//MARK: CactusTextHaloDemoView
struct CactusTextHaloDemoView: View {
    
    let text0: String = "Lorem ipsum odor amet, consectetuer adipiscing elit. Ut ultricies lectus sapien faucib"
    let text: String = "#32#32#32#32#32#32#32#32#32#32#32"
    let text2: String = "Mólancoliquo            Appel non toxé           numéro"
    let text3: String = "#31#777723              Anonyme                  OC + prix de l'appel"
    
    @State private var rotation: Double = 0
    @State private var radius: Double = 150
    @State private var offset: Double = -75
    
    @State private var verticalPerspective: Double = -0.5
    
    @State private var color: Color = .red
    
//    MARK: ContentBuilders
    @ViewBuilder
    private func makeFirstDemo() -> some View {
        ForEach(0...1, id: \.self) { i in
            CactusTextHalo(text, at: rotation, in: radius, verticalPerspective: verticalPerspective) { text in
                Text(text)
                    .font(.custom("Helvetica", size: 50))
                    .bold()
                    .foregroundStyle(color)
                    .shadow(color: color, radius: 5)
                    .shadow(color: color.opacity(0.5), radius: 40)
            }
        }
        
        CactusTextHalo(text2, at: rotation - 60, in: radius, verticalPerspective: verticalPerspective) { text in
            Text(text)
                .bold()
                .font(.caption)
                .foregroundStyle(color)
                .opacity(0.9)
        }

        CactusTextHalo(text3, at: rotation - 60, in: radius, verticalPerspective: verticalPerspective) { text in
            Text(text)
                .bold()
                .font(.caption)
                .foregroundStyle(color)
                .opacity(0.9)
        }
    }
    
    @ViewBuilder
    private func makeSecondDemo() -> some View {
        ForEach(0...10, id: \.self) { i in
            let dir: Double = Double.random(in: -1...1)
            
            CactusTextHalo(text0, at: dir * rotation + Double(i * 45), in: radius, verticalPerspective: verticalPerspective) { text in
                Text(text)
                    .font(.callout)
                    .foregroundStyle(color)
            }
        }
    }
    
    
    var body: some View {
    
        VStack {
                
//            Slider(value: $rotation, in: 0...360)
//            Slider(value: $radius, in: 100...350)
//            Slider(value: $verticalPerspective, in: -1...1)
            
            GeometryReader { geo in
                VStack {
                    HStack { Spacer() }
                    Spacer()
                    
                    
                    makeSecondDemo()
                    
                    Spacer()
                    
                }
                .offset(y: offset)
//                .stripedMask(at: 90, width: 2, spacing: 3)
            }
        }
        .onAppear {
            withAnimation(.linear(duration: 7).repeatForever(autoreverses: false) ) {
                rotation += 360
            }
            
            withAnimation(.easeInOut(duration: 3.5).repeatForever(autoreverses: true) ) {
//                verticalPerspective = 0.5
                offset = 75
            }
        }
    }
}


#Preview {
    
    CactusTextHaloDemoView()
    
}
