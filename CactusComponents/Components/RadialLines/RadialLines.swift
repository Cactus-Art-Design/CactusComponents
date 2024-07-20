//
//  RadialLines.swift
//  CactusComponents
//
//  Created by Brian Masse on 7/10/24.
//

import Foundation
import SwiftUI

struct RadialLines<C: View>: View {
    
//    MARK: Line
    private struct Line: Shape {
        
        //input angles in degrees, ranging from -180 to 180
        let angle: Double
        
        let startScaleRange: ClosedRange<Double>
        let endScaleRange: ClosedRange<Double>
        
        private func distance(from point: CGPoint, to point2: CGPoint) -> Double {
            let dx = point.x - point2.x
            let dy = point.y - point2.y
            
            return sqrt( pow(dx, 2) + pow(dy, 2) )
        }
        
        private func computeLength(from angle: Double, in rect: CGRect) -> Double {
            
            let slope = tan(angle)
            let center = CGPoint(x: rect.midX, y: rect.midY)
            
            let cutOffAngle1 = atan(-(rect.maxY - rect.midY) / (rect.minY - rect.midX))
            let cutOffAngle2 = Double.pi - cutOffAngle1
            
            //if it first intersects the top or bottom of the frame, compute the x coord
            if abs( angle ) >= cutOffAngle1 && abs( angle ) <= cutOffAngle2 {
                
                let x = (rect.minY - rect.midY) * (1 / slope) + rect.midX
                return distance(from: center, to: .init(x: x, y: rect.minY) )
                
            } else {
             
                let y = slope * ( rect.maxX - rect.midX ) + rect.midY
                return distance(from: center, to: .init(x: rect.maxX, y: y))
                
            }
        }
        
//        MARK: DrawLine
        func path(in rect: CGRect) -> Path {
            Path { path in
                let radAngle = (angle * Double.pi) / 180
                
                let length: Double = computeLength(from: radAngle, in: rect)
                let startLength = min(abs(rect.minY - rect.midY), abs(rect.maxX - rect.midX))
                
                let startScale = Double.random(in: startScaleRange)
                let endScale = Double.random(in: endScaleRange)
                
                let x = cos( radAngle )
                let y = sin( radAngle )
                
                path.move(to: .init(x: rect.midX + x * startLength * startScale,
                                    y: rect.midY - y * startLength * startScale))
                
                path.addLine(to: .init(x: rect.midX + x * length * endScale,
                                       y: rect.midY - y * length * endScale))
            }
        }
    }
    
//    MARK: Vars
    let lines: Int
    let lineWidth: Double
    
    let startScaleRange: ClosedRange<Double>
    let endScaleRange: ClosedRange<Double>
    
    let content: C
    
    init( lines: Int = 25, width: Double = 2,
          startScaleRange: ClosedRange<Double> = 0.5...0.53,
          endScaleRange: ClosedRange<Double> = 0.8...1,
          @ViewBuilder contentBuilder: () -> C ) {
        
        self.lines = lines
        self.lineWidth = width
        self.startScaleRange = startScaleRange
        self.endScaleRange = endScaleRange
        self.content = contentBuilder()
    }
    
//    MARK: Body
    var body: some View {
        
        ZStack {
            ForEach(0...lines, id: \.self) { i in
             
                let angle = Double(i) / Double(lines) * 360 - 180
                
                
                Line(angle: angle, startScaleRange: startScaleRange, endScaleRange: endScaleRange)
                    .stroke(style: .init(lineWidth: lineWidth, lineCap: .round))
                    .padding()
            }
            
            content
        }
    }
}

//MARK: RadialLinesControls
struct RadialLinesControls: View {
    
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
    
    var body: some View {
        
        VStack {
        
            makeControls()
            
            RadialLines(lines: Int(lines), width: width,
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
//    RadialLinesControls()
    LineFillDemoView()
}

