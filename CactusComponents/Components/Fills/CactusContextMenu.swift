//
//  CactusContextMenu.swift
//  CactusComponents
//
//  Created by Brian Masse on 7/31/24.
//

import Foundation
import SwiftUI

struct CactusContextMenu<C: View>: View {
    
    @ViewBuilder let contentBuilder: () -> C
    
    let count = 5
    let radius: Double = 100
    let threshold: Double = 0
    
    @State private var selectedIndex: Int = -1
    
    private func degToRad( _ angle: Double ) -> Double {
        (Double.pi * angle) / 180
    }
    
    //    MARK: Gesture
    private func getIndex(from position: CGPoint) -> Int {
        
        let measuredAngle = atan( (radius - position.y) / (-position.x + radius) )
        let angle = measuredAngle < 0 ? Double.pi + measuredAngle : measuredAngle
        
        let segmentArcLength: Double = Double.pi / Double(count - 1)
        let proposedIndex = round(angle / segmentArcLength)
        
        return Int(proposedIndex)
    }
    
    private func getLength(from pos: CGPoint) -> Double {
        if pos.y > radius { return 0 }
        return sqrt( pow( pos.x - radius, 2 ) + pow( Double(radius - pos.y), 2 ) )
    }
    
    private func checkSelection(in pos: CGPoint, and translation: CGSize) {
        if getLength(from: pos) > threshold {
            self.selectedIndex = getIndex(from: pos)
        } else {
            self.selectedIndex = -1
        }
    }
    
    private var dragGesture: some Gesture {
        DragGesture(minimumDistance: 10)
            .onChanged { value in
                
                checkSelection(in: value.location, and: value.translation)
            }
        
            .onEnded { value in self.selectedIndex = -1 }
        
    }
    
    
    var body: some View {
        
//        HStack {
//            contentBuilder()
//                .background(.red)
////                .overlay {
////                    Text(  )
////                }
//        }
        
        Text("\(selectedIndex)")
        
        
        ZStack {
            ForEach( 0..<count, id: \.self ) { i in
                
                let angle: Double = Double((180 / (count - 1))) * Double(i)
                
                
                Circle()
                
                    .frame(width: 20, height: 20)
                    .scaleEffect( i == selectedIndex ? 1.5 : 1 )
                    .offset(x: -radius * cos(degToRad(angle)),
                            y: -radius * sin(degToRad(angle)))
                       
            }
            
        }
        .offset(y: radius / 2)
        .frame(width: radius * 2, height: radius)
        .animation(.spring, value: selectedIndex)
        
        .background(.red)
        .gesture(dragGesture)
        
//        Text("hi")
//             
//        Menu("test") {
//            Button("1") { }
//            
//            Button("2") { }
//            
//            Button("3") { }
//        }
        
    }
    
}


struct CactusContextMenuDemoView: View {
    
    var body: some View {
        
        CactusContextMenu {
            Text("hello!")
            Text("hello!")
            Text("hello!")
            Text("hello!")
            
        }
    }
    
}

#Preview {
    CactusContextMenuDemoView()
}
