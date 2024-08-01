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
    
    @State private var selectedIndex: Int = 0
    
    private func degToRad( _ angle: Double ) -> Double {
        (Double.pi * angle) / 180
    }
    
    private func getIndex(from pos: CGPoint) -> Int {
        
        let measuredAngle = atan( -abs(pos.y) / pos.x )
        let angle = measuredAngle < 0 ? Double.pi + measuredAngle : measuredAngle
//        
        print(angle)
        
        let segmentArcLength: Double = Double.pi / Double(count - 1)
        let proposedIndex = round(angle / segmentArcLength)
        
        return Int(proposedIndex)
    }
    
    private func getLength(from translation: CGSize) -> Double {
        sqrt( pow( translation.width, 2 ) + pow( translation.height, 2 ) )
    }
    
    private var dragGesture: some Gesture {
        DragGesture(minimumDistance: 10)
            .onChanged { value in
                self.selectedIndex = getIndex(from: value.location)
            }
        
            .onEnded { value in
                
                if getLength(from: value.translation) > 100 {
                    self.selectedIndex = getIndex(from: value.location)
                } else {
                    self.selectedIndex = 0
                }
                
            }
        
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
                    .offset(x: radius * cos(degToRad(angle)),
                            y: -radius * sin(degToRad(angle)))
                       
            }
            
        }
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
