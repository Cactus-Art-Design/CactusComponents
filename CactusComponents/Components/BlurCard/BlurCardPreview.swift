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
        super.init(name: "Loading Blur Demo",
                   description: "This is a styled, animated loading background") {
            BlurCardPreview()
        }
    }
    
    public static var shared: BlurCardComponent = BlurCardComponent()
}

@available(iOS 15.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
private struct BlurCardPreview: View {
    let images = ["Mojave", "Sonoma", "JTree", "Goat", "Abstract", "Metal"]
    
    @State var selectedImage: Int = 0
    @State var photoBackground: Bool = true
    
    private func cycleImage(forward: Bool = true) {
        if forward {
            self.selectedImage = selectedImage >= images.count - 1 ? 0 : selectedImage + 1
        } else {
            self.selectedImage = selectedImage == 0 ? images.count - 1 : selectedImage - 1
        }
    }
    
//    MARK: Body
    var body: some View {
        VStack {
            HStack {
                VStack(alignment: .leading) {
                    Text("Frosted Glass Card Demo")
                        .font( Font.custom(BlurCard.LocalConstants.titleFont, size: 20) )
                        .textCase(.uppercase)
                    
                    HStack {
                        Button(action: { withAnimation { cycleImage(forward: false) } }, label: {
                            Image( systemName: "chevron.left" )
                        }).buttonStyle(.plain)
                        
                        Text(images[selectedImage])
                            .font( Font.custom(BlurCard.LocalConstants.mainFont, size: 16) )
                            .textCase(.uppercase)
                        
                        Button(action: { withAnimation { cycleImage() } }, label: {
                            Image( systemName: "chevron.right" )
                        }).buttonStyle(.plain)
                    }
                }
                
                Spacer()
                
                Button(action: { withAnimation { photoBackground.toggle() } }, label: {
                    Image( systemName: photoBackground ? "livephoto" : "livephoto.slash" )
                }).buttonStyle(.plain)
            }
            .padding(.horizontal, 30)
            
            Spacer()
        
            BlurCard(image: images[selectedImage])
                .padding(.bottom)
            
            Spacer()
        }
        .background {
            if photoBackground {
                Image( images[ selectedImage ] )
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .blur(radius: 6)
                    .ignoresSafeArea()
                    .scaleEffect(1.2)
                    .overlay {
                        Image("noise")
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .ignoresSafeArea()
                            .blendMode(.overlay)
                            .opacity(0.1)
                    }
            }
        }
    }
}
