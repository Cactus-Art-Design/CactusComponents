//
//  CardTemplateView.swift
//  ScrollingCardsDemo
//
//  Created by Brian Masse on 5/27/24.
//

import Foundation
import SwiftUI

//  MARK: Constants
struct LocalConstants {
    static let smallHeight: CGFloat = 60
    static let cornerRadius: CGFloat = 15
    static let horizontalPadding: CGFloat = 10
    
    static let spacing: CGFloat = 10
}

//MARK: CardTemplate
@available(iOS 15.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
struct CardViewTemplate<Content: View>: View {
    
    let height: CGFloat
    let index: Int
    
    let content: (Binding<Bool>) -> Content
    
    @Binding var scrollPosition: CGFloat
    
    @State var showingFullCard = true
    @State var scaleModifier: CGFloat = 0
    @State var scale: CGFloat = 1
    @State var alpha: CGFloat = 1
    
    init( height: CGFloat, index: Int, scrollPosition: Binding<CGFloat>, content: @escaping (Binding<Bool>) -> Content ) {
        self.height = height
        self.index = index
        self._scrollPosition = scrollPosition
        self.content = content
    }
    
//    MARK: Struct Methods
    private func makeScale(in geo: GeometryProxy) {
        let invertedDistance = -distanceFromStart(in: geo)
        
        if checkOutOfScrollViewBounds(in: geo) {
            let input = (1/3500) * invertedDistance
            let scale = 1 / (input + 1)
            self.scale = scale
            withAnimation { self.alpha = scale * 0.80 }
        } else {
            let input: Double = Double(invertedDistance) + 170
            let bellCurve: Double = pow( 2, -pow((1/90) * input, 2) )
            
            let dampener: Double = (1/20)
            
            let scale = max(dampener * bellCurve + 1, 1)
            self.scale = scale
            withAnimation { self.alpha = scale * 1 }
        }
    }
    
    private func checkHalfContentToggle(in geo: GeometryProxy) {
        let distance = distanceFromStart(in: geo)
        
        if -distance > height * 0.55 {
            withAnimation { if showingFullCard { showingFullCard = false }}
        } else {
            withAnimation { if !showingFullCard { showingFullCard = true }}
        }
    }
    
    private func distanceFromStart(in geo: GeometryProxy) -> CGFloat {
        geo.frame(in: .named("scroll")).minY
    }
    
    private func checkOutOfScrollViewBounds(in geo: GeometryProxy) -> Bool {
        distanceFromStart(in: geo) <= 0 && distanceFromStart(in: geo) > -height - LocalConstants.spacing
    }
    
    private func makeHeight(in geo: GeometryProxy) -> CGFloat {
        let proposedHeight = height + distanceFromStart(in: geo)
        let height = min(max(proposedHeight, LocalConstants.smallHeight), height)
        
        return height
    }
    
    private func makeOffset(in geo: GeometryProxy) -> CGFloat {
        let selfOutOfView = checkOutOfScrollViewBounds(in: geo)
        
        if selfOutOfView {
            return -distanceFromStart(in: geo)
        } else {
            return 0
        }
    }
    
//    MARK: Body
    var body: some View {
        GeometryReader { geo in
            let height = makeHeight(in: geo)
            
            ZStack(alignment: .top) {
                Rectangle()
                    .foregroundStyle(.black)
                    .overlay {
                        Image( "noise" )
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .opacity(0.35)
                            .blendMode(.hardLight)
                            .frame(height: height)
                            .clipped()
                    }
                
                self.content( $showingFullCard )
                    .padding( showingFullCard ? 25 : 15)
            }
            .frame(height: height)
            .clipShape(RoundedRectangle(cornerRadius: LocalConstants.cornerRadius))

            .padding(.horizontal, LocalConstants.horizontalPadding)
            .shadow(color: .black.opacity(0.3), radius: 0.5, x: 1, y: 1)
            .shadow(color: .white.opacity(0.2), radius: 0.5, x: -1, y: -1)
            
            .scaleEffect( scale + scaleModifier )
            .animation( .easeInOut(duration: 0.2), value: scaleModifier)
            .onTapGesture {
                scaleModifier = 0.05
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { scaleModifier = 0 }
            }
        
            .onAppear { makeScale(in: geo) }
            .onChange(of: scrollPosition) { _ in
                makeScale(in: geo)
                checkHalfContentToggle(in: geo)
            }
            .offset(y: makeOffset(in: geo))
            
        }.frame(height: height)
        .opacity(alpha)
    }
}
