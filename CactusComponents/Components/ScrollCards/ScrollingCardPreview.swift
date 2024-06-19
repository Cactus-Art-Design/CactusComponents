//
//  ContentView.swift
//  ScrollingCardsDemo
//
//  Created by Brian Masse on 5/26/24.
//

import SwiftUI

@available(iOS 15.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
public final class ScrollingCardComponent: CactusComponent, SingleInstance {
    private init() {
        super.init(name: "Scrolling Cards",
                   description: "A styled scroll view that animates the opacity and size of cards as they move") {
            ScrollingCardPreview()
        }
    }
    
    public static var shared: ScrollingCardComponent = ScrollingCardComponent()
}

@available(iOS 15.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
private struct ScrollingCardPreview: View {
    let card = ScrollingCard(title: "The MOMA series",
                    description: "We all benefit from better craftsmanship. Products that are thoughtfully conceptualized, ideated upon, and ultimately sculpted by artists are more reliable, functional, and enjoyable to use. ",
                    date: Date.now,
                    name: "Brian Masse")
    
    var body: some View {
        ZStack {
            Image("Ventura")
                .resizable()
                .saturation(0.7)
                .ignoresSafeArea()
                .scaleEffect(1.5)
                .blur(radius: 50)
                
            
            StyledScrollView(cards: [ card, card, card, card, card, card, card ])
                .padding(.horizontal,7)
        }
    }
}
    
