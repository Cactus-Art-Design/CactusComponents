//
//  CactusTicker.swift
//  CactusComponents
//
//  Created by Brian Masse on 8/31/24.
//

import Foundation
import SwiftUI

struct CactusTicker: View {
    
    @State private var number: Double = 15
    
    private let fractionDigits: Int = 3
    private let integerDigits: Int = 2
    
    private let numberHeight: Double = 100
    
    private var incrementValue: Double {
        1 / pow(10, Double(fractionDigits))
    }
    
    @ViewBuilder
    private func makeTickerLine( number: Int ) -> some View {
        
        VStack(spacing: 0) {
            ForEach( 0..<10, id: \.self ) { i in
                
                Text("\(i)")
                    .frame(height: numberHeight)
                    .blur(radius: i == number ? 0 : 10)
            }
            .offset(y: numberHeight * -Double(number) )
        }
        .frame(height: numberHeight, alignment: .top)
        .clipShape(Rectangle())
        .contentShape(Rectangle())
    }
    
    private func roundNumber() -> String {
        let formatter = NumberFormatter()
        formatter.minimumFractionDigits = fractionDigits
        formatter.maximumFractionDigits = fractionDigits
        
        formatter.minimumIntegerDigits = integerDigits
        formatter.maximumIntegerDigits = integerDigits
        
        return formatter.string(from: NSNumber(floatLiteral: number)  ) ?? ""
    }

    var  body: some View {
        
        VStack {
            
            Text("increment").onTapGesture { number += incrementValue }
            Text("decerement").onTapGesture { number -= incrementValue }
            
            Slider(value: $number, in: 0...20)
            
            HStack(spacing: 0) {
                
                let string = roundNumber()
                
                ForEach( 0..<string.count, id: \.self ) { i in
                    
                    let index = string.index(string.startIndex, offsetBy: i)
                    let char = "\(string[index])"
                    let number = Int( char )
                    
                    Group {
                        if let number {
                            makeTickerLine(number: number)
                                
                        } else {
                            Text(char)
                        }
                    }
                    .border(.red)
                    .animation(.easeInOut, value: number)
                    .font(.custom("", size: 100))
                }
            }
        }
    }
}

#Preview {
    CactusTicker()
}