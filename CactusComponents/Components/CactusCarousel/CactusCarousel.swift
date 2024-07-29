//
//  Layout2.swift
//  CactusComponents
//
//  Created by Brian Masse on 7/22/24.
//

import Foundation
import SwiftUI

//    MARK: CarouselNode
private struct CarouselNode<T: View>: View {
    
    let index: Int
    
    let width: Double
    let content: T
    
    @Binding var currentNodeIndex: Int
    
    init( _ index: Int, in width: Double, currentNodeIndex: Binding<Int>, @ViewBuilder contentBuilder: () -> T ) {
        self.index = index
        self.width = width
        self.content = contentBuilder()
        self._currentNodeIndex = currentNodeIndex
    }
    
    private func makeOffset() -> Double {
        let difference = index - currentNodeIndex
        
        if abs( difference ) >= 1 { return (250 * Double(difference)) }
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
                .foregroundStyle(.clear)
            
            content
            
            Rectangle()
                .foregroundStyle(.background)
                .opacity((1 - makeScale()) *  8)
        }
            .scaleEffect(makeScale() )
            .offset(x: makeOffset())
    }
}


//MARK: Carousel

struct CactusCarousel<C: View>: View {
    
//    MARK: Vars
    let carouselLength: Int
    
    @State private var currentNodeIndex: Int = 0
    
    @State private var previousDragGestureThreshold: Double = 0
    
    private let contentBuilder: (Int) -> C
    
    init( carouselLength: Int, @ViewBuilder contentBuilder: @escaping (Int) -> C ) {
        self.carouselLength = carouselLength
        self.contentBuilder = contentBuilder
    }
    
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
        
        let modifier: Double = index <= currentNodeIndex ? Double(carouselLength) : 0
        let proposedIndex = currentNodeIndex == index ? Double(carouselLength + 1) : Double(carouselLength - abs(index - currentNodeIndex))
        
        return proposedIndex + modifier
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
                        
                        let width: Double = geo.size.width * 0.85
                        
                        
                        CarouselNode(i, in: width, currentNodeIndex: $currentNodeIndex) {
                            contentBuilder(i)
                        }
                            .frame(width: width)
                            .zIndex(makeZIndex(in: i))
                            .animation(.spring(), value: currentNodeIndex)
                    }
                }
            }
        }
        .highPriorityGesture(swipeGesture)
    }
}
