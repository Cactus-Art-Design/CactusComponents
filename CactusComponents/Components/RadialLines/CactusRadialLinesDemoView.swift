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
    
//    MARK: ViewBuilders
    
    @ViewBuilder
    private func makeControls() -> some View {
        
        VStack {
            CactusComponentControl("Line Count", for: $lines, in: 0...180)
            CactusComponentControl("Line Width", for: $width, in: 1...10)
            
            HStack {
                CactusComponentControl("Start Scale Range", for: $startScaleRangeStart,
                            in: 0...min(startScaleRangeEnd, 1.05), step: 0.05)
                CactusComponentControl(" ", for: $startScaleRangeEnd,
                            in: max(startScaleRangeStart, 0.05)...endScaleRangeStart - 0.05, step: 0.05)
            }
            
            HStack {
                CactusComponentControl("End Scale Range", for: $endScaleRangeStart,
                            in: startScaleRangeEnd...min(endScaleRangeEnd, 1.05), step: 0.05)
                CactusComponentControl(" ", for: $endScaleRangeEnd,
                            in: max(endScaleRangeStart, startScaleRangeEnd + 0.05)...1.1, step: 0.05)
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
    CactusRadialLinesDemoView()
}
