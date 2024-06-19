//
//  ContentView.swift
//  BlurCardDemo
//
//  Created by Brian Masse on 5/25/24.
//

import SwiftUI

@available(iOS 15.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
public final class BlurCardComponent: CactusComponent, SingleInstance {
    private init() {
        super.init(name: "Blur Card",
                   description: "This is a styled, animated, interactable card") {
            BlurCardPreview()
        }
    }
    
    public static var shared: BlurCardComponent = BlurCardComponent()
}


@available(iOS 15.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
private struct BlurCardPreview: View {
//    MARK: Body
    var body: some View {
        ZStack {
            Image("Mojave")
                .resizable()
                .clipped()
                .blur(radius: 50)
                .scaleEffect(1.4)
            
            VStack {
                HStack { Spacer() }
                
                Spacer()
                
                Card()
                    .scaleEffect(0.8)
                
                Spacer()
            }
            
        }.background(Color(red: 0.3, green: 0.3, blue: 0.3))
    }
}

#Preview {
    ContentView()
}
