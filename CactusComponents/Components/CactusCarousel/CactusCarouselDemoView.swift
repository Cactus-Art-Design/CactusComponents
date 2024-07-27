//
//  CactusCarouselDemoView.swift
//  CactusComponents
//
//  Created by Brian Masse on 7/24/24.
//

import Foundation
import SwiftUI

//MARK: CarouselDemoView
struct CactusCarouselDemoView: View {
    
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
    CactusCarouselDemoView()
    
}
