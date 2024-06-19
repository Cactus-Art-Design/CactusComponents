//
//  ContentView.swift
//  CactusComponents
//
//  Created by Brian Masse on 6/18/24.
//

import SwiftUI

//This allows the view to render as it would with full screen access
//then it is up to the children of the layout to apply the proper scaleEffect
//Because of that, this view should likely be wrapped in a geometryReader
fileprivate struct FitLayout: Layout {
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        return UIScreen.main.bounds.size
    }
    
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        
        let proposal: ProposedViewSize = .init( UIScreen.main.bounds.size )
        
        subviews.first!.place(at: .init(x: bounds.midX, y: bounds.midY), anchor: .center, proposal: proposal)
    }
}

//MARK: ContentView
struct ContentView: View {
    
    let components: [ CactusComponent ] = [ TicketComponent.shared,
                                            BlurCardComponent.shared,
                                            ScrollingCardComponent.shared,
                                            SlidingModalComponent.shared,
                                            LoadingWaveComponent.shared,
                                            LoadingBlurComponent.shared,
//                                            TicketComponent.shared
    ]
    
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
                FitLayout {
                    
                    let scale = geo.size.width / UIScreen.main.bounds.width
                    
                    VStack(spacing: 0) {
                        component.preview()
                        
                        HStack { Spacer() }
                    }
                    .background(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 25))
                    .shadow(color: .black.opacity(0.2), radius: 10, y: 10)
                    .shadow(color: .black.opacity(0.5), radius: 0.1, x: 0.4, y: 0.4)
                    .padding(.vertical, 30)
                    .scaleEffect(scale, anchor: .topLeading)
                }
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
