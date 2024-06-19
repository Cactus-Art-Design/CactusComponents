//
//  ContentView.swift
//  CactusComponents
//
//  Created by Brian Masse on 6/18/24.
//

import SwiftUI

//MARK: ContentView
struct ContentView: View {
    
    let components: [ CactusComponent ] = [ BlurCardComponent.shared,
                                            ScrollingCardComponent.shared,
                                            SlidingModalComponent.shared,
                                            LoadingWaveComponent.shared,
                                            LoadingBlurComponent.shared,
                                            TicketComponent.shared]
    
//    MARK: ComponentView
    @ViewBuilder
    private func makeComponentView(_ component: CactusComponent) -> some View {
        VStack(alignment: .leading) {
            Text( component.name )
                .font(.title)
                .bold()
                .lineLimit(1, reservesSpace: true)
                .padding(.trailing)
            
            Text( component.description )
                .lineLimit(2, reservesSpace: true)
                .padding(.bottom, -15)
            
            GeometryReader { geo in
                VStack(spacing: 0) {
                    component.preview()

                    HStack { Spacer() }
                }
                .background(.white)
                .clipShape(RoundedRectangle(cornerRadius: 25))
                .shadow(color: .black.opacity(0.2), radius: 10, y: 10)
                .shadow(color: .black.opacity(0.5), radius: 0.1, x: 0.4, y: 0.4)
                .padding(.vertical, 30)
            }
        }
        .padding(.horizontal, 5)
    }
    
//    MARK: Body
    var body: some View {
        VStack(spacing: 0) {
            GeometryReader { geo in
                ScrollView(.horizontal, showsIndicators: false) {
                    LazyHStack {
                        ForEach( 0..<components.count, id: \.self ) { i in
                            let component = components[i]
                            
                            makeComponentView(component)
                                .frame(width: geo.size.width - 80)
                        }
                    }
                    .scrollTargetLayout()
                }
                .scrollTargetBehavior(.viewAligned)
                .safeAreaPadding(.horizontal, 40)
            }
        }
        .padding(.vertical)
    }
}

#Preview {
    ContentView()
}
