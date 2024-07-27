//
//  CactusRadialLinesDemoView.swift
//  CactusComponents
//
//  Created by Brian Masse on 7/24/24.
//

import Foundation
import SwiftUI

//MARK: CactusRadialLinesDemoView
struct CactusRadialLinesDemoView: View {
    
    
//    MARK: Vars
    @State private var lines: Double = 25
    @State private var width: Double = 2
    
    @State private var startScaleRangeStart: Double = 0.2
    @State private var startScaleRangeEnd: Double = 0.5
    
    @State private var endScaleRangeStart: Double = 0.6
    @State private var endScaleRangeEnd: Double = 0.8

    func forTrailingZero(_ temp: Double) -> String {
        
        let tempVar = String(format: "%.2f", temp)
        return tempVar.count == 3 ? tempVar + "0" : tempVar
    }
    
//    MARK: ViewBuilders
    @ViewBuilder
    private func makeControl(title: String, value: Binding<Double>, range: ClosedRange<Double>, step: Double) -> some View {
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
    
    @ViewBuilder
    private func makeControls() -> some View {
        
        VStack {
            makeControl(title: "Line Count", value: $lines, range: 0...180, step: 1)
            makeControl(title: "Line Width", value: $width, range: 1...10, step: 1)
            
            HStack {
                makeControl(title: "Start Scale Range", value: $startScaleRangeStart,
                            range: 0...min(startScaleRangeEnd, 1.05), step: 0.05)
                makeControl(title: " ", value: $startScaleRangeEnd,
                            range: max(startScaleRangeStart, 0.05)...endScaleRangeStart - 0.05, step: 0.05)
            }
            
            HStack {
                makeControl(title: "End Scale Range", value: $endScaleRangeStart,
                            range: startScaleRangeEnd...min(endScaleRangeEnd, 1.05), step: 0.05)
                makeControl(title: " ", value: $endScaleRangeEnd,
                            range: max(endScaleRangeStart, startScaleRangeEnd + 0.05)...1.1, step: 0.05)
            }
            
        }
        .padding(.horizontal)
        
    }
    
//    MARK: Body
    var body: some View {
        
        VStack {
        
            makeControls()
            
            CactusRadialLines(lines: Int(lines), width: width,
                        startScaleRange: startScaleRangeStart...startScaleRangeEnd,
                        endScaleRange: endScaleRangeStart...endScaleRangeEnd) {
                Text( "52" )
                    .font(.largeTitle)
                    .bold()
                    .foregroundStyle(.foreground)
            }
                        .foregroundStyle(.red)
        }
    }
}

#Preview {
    LineFillDemoView()
}
