//
//  Layout2.swift
//  CactusComponents
//
//  Created by Brian Masse on 7/22/24.
//

import Foundation
import SwiftUI


struct CactusLayout2: View {

    
//    MARK: CarouselNode
    private struct CarouselNode: View {
        
        let index: Int
        
        let width: Double
        
        @Binding var currentNodeIndex: Int
        
        init( _ index: Int, in width: Double, currentNodeIndex: Binding<Int> ) {
            self.index = index
            self.width = width
            self._currentNodeIndex = currentNodeIndex
        }
        
        private func makeOffset() -> Double {
            let difference = index - currentNodeIndex
            let dir =  difference / abs(max(difference, 1))
            
            if abs( difference ) == 1 { return Double(dir) * 100 }
            return 0
        }
        
        private func makeExitOffset() -> Double {
            if index < currentNodeIndex {
                return -width
            }
            return 0
        }
        
        private func makeScale() -> Double {
            let offset = abs(index - currentNodeIndex)
            
            return max((-0.1 * Double(offset)) + 1, 0.1)
        }
        
//        MARK: CarouselNode Body
        var body: some View {
         
            ZStack {
                Rectangle()
                    .foregroundStyle(.red)
                
                Text("\(index)")
            }
                .border(.blue)
                .scaleEffect(makeScale() )
                .offset(x: makeOffset())
        }
    }
    
//    MARK: Vars
    let carouselLength: Int = 4
    
    @State private var currentNodeIndex: Int = 0
    
    @State private var previousDragGestureThreshold: Double = 0
    
    private var swipeGesture: some Gesture {
        DragGesture(minimumDistance: 30)
            .onChanged { value in
                
                if value.translation.width < previousDragGestureThreshold - 100 {
                    previousDragGestureThreshold = value.translation.width
                    advanceCarousel()
                }
                if value.translation.width > previousDragGestureThreshold + 100 {
                    previousDragGestureThreshold = value.translation.width
                    reduceCarousel()
                }
                
            }
            .onEnded { _ in
                previousDragGestureThreshold = 0
            }
    }
    
//    MARK: Struct Methods
    private func makeZIndex(in index: Int) -> Double {
        currentNodeIndex == index ? Double(carouselLength + 1) : Double(carouselLength - abs(currentNodeIndex - index))
    }
    
    private func advanceCarousel(by count: Int = 1) {
        currentNodeIndex = min(currentNodeIndex + abs(count), carouselLength - 1)
    }
    
    private func reduceCarousel(by count: Int = 1) {
        currentNodeIndex = max(currentNodeIndex - abs(count), 0)
    }
    
//    MARK: Body
    var body: some View {
        
        GeometryReader { geo in
            VStack {
                ZStack {
                    
                    ForEach( 0..<carouselLength, id: \.self ) { i in
                        
                        let width: Double = geo.size.width * 0.8
                        
                        CarouselNode(i, in: width, currentNodeIndex: $currentNodeIndex)
                            .frame(width: width)
                            .zIndex(makeZIndex(in: i))
                            .animation(.spring(), value: currentNodeIndex)
                    }
                }
            }
        }
        .gesture(swipeGesture)
    }
}

#Preview {
    CactusLayout2()
}

