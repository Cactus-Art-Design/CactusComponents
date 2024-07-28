//
//  CactusTextHalo.swift
//  CactusComponents
//
//  Created by Brian Masse on 7/27/24.
//

import Foundation
import SwiftUI

struct CactusTextHalo: View {
 
    
    @State private var angle: Double = 0
    
    static let text: String = "Hello world this is a really long and awesome string!"
    
    @State private var radius: Double = 150
    
    var texts: [(offset: Int, element: Character)] {
        return Array(CactusTextHalo.text.enumerated())
    }
    
    private func makeTextWidth() -> Double {
        let circumference = 2 * Double.pi * radius
        return circumference / Double( texts.count )
    }
    
    private func makeAngle(from index: Int) -> Double {
        let proposedAngle = (360 * Double(index) / Double( texts.count)) + self.angle
        return proposedAngle.truncatingRemainder(dividingBy: 360)
    }
    
    var body: some View {
        
        VStack {
            
            
            Slider(value: $angle, in: 0...360)
            
            Slider(value: $radius, in: 100...350)
            
            //        Rectangle()
            //            .frame(width: 300, height: 100)
            //
            
            //
            
            Spacer()
            
            ZStack {
                
                let width = makeTextWidth()
                
                ForEach( texts, id: \.offset ) { index, char in
                    
                    let angle = makeAngle(from: index)
                    let shouldHide = angle > 90 && angle < 270
                    
                    ZStack {
                        Text("\(char)")
                    }
                    .bold()
                    .font(.title)
                    .frame(width: width)
                    .background(.white)
                    .zIndex( abs( Double(texts.count) - angle ) )
                    .opacity(shouldHide ? 0.5 : 1)
                    
                    
                    .rotation3DEffect(
                        .init(degrees: -angle),
                        axis: (x: 0.0, y: 1.0, z: 0.0),
                        anchor: .bottom,
                        perspective: -0.5
                    )
                    
                    .offset(x:  sin( (Double.pi * angle) / 180 ) * radius  )
                    .offset(y:  cos( (Double.pi * angle) / 180 ) * radius * -0.5 )
                    
                }
            }
            .rotationEffect(.init(degrees: 20))
            
            Spacer()
        }
    }
}

#Preview {
    
    CactusTextHalo()
    
}
