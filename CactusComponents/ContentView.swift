//
//  ContentView.swift
//  CactusComponents
//
//  Created by Brian Masse on 6/18/24.
//

import SwiftUI

//MARK: ContentView
struct ContentView: View {
    
    let components: [ CactusComponent ] = [ TicketComponent.shared,
                                            TicketComponent.shared,
                                            TicketComponent.shared,
                                            TicketComponent.shared]
    
    @ViewBuilder
    private func makeComponentView(_ component: CactusComponent) -> some View {
        VStack(alignment: .leading) {
            Text( component.name )
            
            GeometryReader { geo in
                VStack {
                    Spacer()
                    
                    component.preview
                        .clipShape(RoundedRectangle(cornerRadius: 25))
                        .allowsTightening(false)
                    
                    
                    Spacer()
                    
                    HStack { Spacer() }
                }
            }
            Text( component.description )
        }
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
        .padding()
    }
}

#Preview {
    ContentView()
}
