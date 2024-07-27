//
//  CactusRibbonDemoView.swift
//  CactusComponents
//
//  Created by Brian Masse on 7/24/24.
//

import Foundation
import SwiftUI

//MARK: RibbonViewDemo
struct RibbonViewDemo: View {
    
    let nodes: [RotationNodeData] = [ .init(in: 150, at: 10, perspective: -3),
                                      .init(in: 420, at: 45, perspective: 5, alignment: .leading),
                                      .init(in: 200, at: 20, perspective: 7, alignment: .trailing),
                                      .init(in: 350, at: 45, perspective: 5, alignment: .leading),
                                      .init(in: 200, at: 20, perspective: 11, alignment: .trailing),
                                      .init(in: 600, at: 20, perspective: 4, alignment: .trailing),
                                      .init(in: 350, at: 45, perspective: -8, alignment: .leading),
                                      .init(in: 250, at: 45, perspective: -5, alignment: .trailing),
                                      .init(in: 650, at: 45, perspective: -8, alignment: .leading) ]
    
//    MARK: Segments
    @ViewBuilder
    private func makeFirstSegment() -> some View {
        
        VStack(alignment: .leading) {
            HStack {
                Text("Route")
                Image(systemName: "arrow.forward")
                
                Spacer()
            }
            .font(.title)
            .bold()
            
            Text( "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum." )
                .font(.caption2)
                .padding(.bottom, 50)
        }
    }
    
    @ViewBuilder
    private func makeSecondSegment() -> some View {
        VStack(alignment: .leading) {
            HStack {
                Text("INTO THE WILD")
                Spacer()
            }
            .font(.largeTitle)
            .bold()
            .scaleEffect(1.5, anchor: .topLeading)
            .padding(.bottom)
            
            Text( "Design By Brian Masse" )
                .bold()
            
            Spacer()
        }
    }
    
    @ViewBuilder
    private func makeThirdSegment() -> some View {
        VStack(alignment: .trailing) {
            Spacer()
            
            Text("wow this took a long time")
            
            HStack {
                Spacer()
                Text("Leap of Faith")
            }
            .font(.largeTitle)
            .bold()
            .padding(.bottom)
        }
    }
    
    @ViewBuilder
    private func makeLastSegment() -> some View {
        HStack(alignment: .top) {
            Text("Safety")
                .font(.largeTitle)
                .bold()
            
            Text("Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat.")
                .font(.caption2)
                .padding(.trailing, 50)
            
            Text("About us")
                .font(.largeTitle)
                .bold()
            
            Text("Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat.")
                .font(.caption2)
                .padding(.trailing)
            
            
            VStack(alignment: .leading) { Spacer() }
            
            Spacer()
        }.padding(.bottom, 50 )
    }
    
//    MARK: RibbonViewDemo
    var body: some View {
        
        ZStack(alignment: .bottomLeading) {
            GeometryReader { geo in
                VStack {
                    
                    Spacer()
                    
                    CactusRibbon( nodes, height: 150, perspective: 0.3, shadowOpacity: 0.1) { i in
                        
                        Rectangle()
                            .foregroundStyle(.white)
                        
                        Group {
                            if i == 0 { makeFirstSegment() }
                            if i == 1 { makeSecondSegment() }
                            if i == 3 { makeThirdSegment() }
                            if i == 5 { makeLastSegment() }
                            
                        }
                        .padding(7)
                    }
                    .shadow(color: .white.opacity(0.2), radius: 15)
                    .foregroundColor(.black)
                    .offset(y: geo.size.height / 5)
                    
                    Spacer()
                }
            }
            
            Text("BRIAN \nMASSE")
                .font(.title2)
                .bold()
                .foregroundStyle(.yellow)
                .padding(30)
        }
        .background {
            Image( "farm" )
                .resizable()
                .aspectRatio(contentMode: .fill)
                .clipShape(Rectangle())
        }
        .ignoresSafeArea()
    }
}

#Preview {
    RibbonViewDemo()
}

