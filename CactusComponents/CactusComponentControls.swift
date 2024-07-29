//
//  CactusComponentControls.swift
//  CactusComponents
//
//  Created by Brian Masse on 7/29/24.
//

import Foundation
import SwiftUI

//MARK: CactusComponentControl
struct CactusComponentControl: View {
    
    let title: String
    let value: Binding<Double>
    let range: ClosedRange<Double>
    let step: Double
    
    func forTrailingZero(_ temp: Double) -> String {
        let tempVar = String(format: "%.2f", temp)
        return tempVar.count == 3 ? tempVar + "0" : tempVar
    }
    
    init( _ title: String, for value: Binding<Double>, in range: ClosedRange<Double> = 0...100, step: Double = 1) {
        self.title = title
        self.value = value
        self.range = range
        self.step = step
    }
    
    
//    MARK: Body
    var body: some View {
        VStack(alignment: .leading) {
            Text( title )
                .bold()
                .lineLimit(1, reservesSpace: true)
            
            HStack {
                
                Slider(value: value, in: range, step: step)
                
                Text( forTrailingZero(value.wrappedValue) )
            }
        }
    }
}
