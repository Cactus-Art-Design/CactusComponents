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
                .opacity((1 - makeScale()) *  5)
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
        .gesture(swipeGesture)
    }
}

//MARK: CarouselDemoView
struct CarouselDemoView: View {
    
    let images = ["Mojave", "Sonoma", "JTree", "Goat", "Abstract", "Metal"]
    
//    MARK: ViewBuilders
    @ViewBuilder
    private func makeImage( _ name: String, aspectRatio: Double ) -> some View {
        Image(name)
            .resizable()
    }
    
    @ViewBuilder
    private func makeRepeatingIndex(from index: Int) -> some View {
        VStack(spacing: -10) {
            ForEach( 0...8, id: \.self ) { _ in
                HStack(spacing: 0) {
                    ForEach( 0...16, id: \.self ) { _ in
                        Text("\(index)")
                            .font( .largeTitle )
                            .bold()
                    }
                }
            }
        }
    }
    
    @ViewBuilder
    private func makeFirstContent(_ index: Int) -> some View {
        VStack {
            ZStack(alignment: .topLeading) {
                makeImage(images[index], aspectRatio: 1)
                
                Group {
                    Text("Explore \(images[index])")
                        .font(.title)
                        .bold()
                    
                }.padding()
            }
            .aspectRatio(1, contentMode: .fit)
            .clipShape(RoundedRectangle(cornerRadius: 25) )
            .offset(x: 20)
            
            Spacer()
            
            ZStack {
                makeImage(images[index], aspectRatio: 1)
                makeRepeatingIndex(from: index)
                    .opacity(0.8)
            }
            .aspectRatio(1, contentMode: .fit)
            .clipShape(RoundedRectangle(cornerRadius: 25) )
            .padding(.top)
        }
    }
    
    @ViewBuilder
    private func makeOddContent( _ index: Int ) -> some View {
        ZStack(alignment: .topLeading) {
            makeImage(images[index], aspectRatio: 1)
            
            VStack(alignment:  .leading) {
                makeRepeatingIndex(from: index)
                    .opacity(0.8)
                    .clipped()
                
                Spacer()
                
                Text("Explore \(images[index])")
                    .font(.title)
                    .bold()
            }
            .padding()
        }
        .clipShape(RoundedRectangle(cornerRadius: 25) )
    }
    
    
//    MARK: Body
    var body: some View {
        GeometryReader { geo in
            VStack(alignment: .leading) {
                
                Text("Carousel \nDemonstration")
                    .font( .title )
                    .bold()
                
                Text("Explore content effortlessly with a custom SwiftUI Carousel")
                    .font(.callout)
                    .padding([.trailing, .bottom])

                
                CactusCarousel(carouselLength: 6) { i in
                    if i % 2 == 0 {
                    makeFirstContent(i)
                    } else {
                        makeOddContent(i)
                    }
//                    else {
//                        Image(images[i])
//                            .resizable()
//                            .aspectRatio(2/3, contentMode: .fill)
//                            .clipped()
//                        
//                    }
                }
            }
        }
        .padding()
        .ignoresSafeArea(edges: .bottom)
    }
}

#Preview {
    CarouselDemoView()
    
}

