//
//  CardView.swift
//  ScrollingCardsDemo
//
//  Created by Brian Masse on 5/26/24.
//

import Foundation
import SwiftUI

//MARK: Card
@available(iOS 15.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
internal struct ScrollingCard: Identifiable {
    let title: String
    let description: String
    let date: Date
    let name: String
    
    func formatDate() -> String {
        date.formatted(date: .abbreviated, time: .omitted)
    }
    
    var id: String {
        title + description + date.formatted() + name
    }
}

//MARK: CardView
@available(iOS 15.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
internal struct ScrollingCardView: View {
    
    enum CardViewType: CGFloat {
        case standard   = 275
        case small      = 125
        case full       = 350
        
        static func getType() -> CardViewType {
            let index = Int.random(in: 0...2)
            
            switch index {
            case 0: return .small
            case 1: return .standard
            case 2: return .full
            default: break
            }
            return .standard
        }
    }
    
    let card: ScrollingCard
    let cardType: CardViewType
    
    @Binding var showingFullCard: Bool
    
//    MARK: ViewBuilders
    @ViewBuilder
    private func makeGradient() -> some View {
        if cardType != .standard {
            LinearGradient(colors: [.red, .orange], startPoint: .leading, endPoint: .trailing)
                .frame(height: 20)
        }
    }
    
    @ViewBuilder
    private func makeHeader() -> some View {
        HStack {
            StyledText(card.title, size: 20, bold: true)
            
            Spacer()
            
            Image(systemName: "circle.slash")
        }
    }
    
    @ViewBuilder
    private func makeBody() -> some View {
        VStack(alignment: .leading) {
            if cardType != .small {
                Divider()
                
                StyledText( "Description", size: 15 )
                
                StyledText( card.description, size: 10 )
                    .padding(.trailing, 50)
                    .padding(.bottom)
                
                StyledText( "Time", size: 15 )
                StyledText( card.formatDate(), size: 12 )
            }
        }
    }
    
    @ViewBuilder
    private func makeFooter() -> some View {
        HStack {
            Image(systemName: "questionmark.app.dashed")
            
            Spacer()
            
            StyledText( card.name, size: 12 )
        }
    }
    
//    MARK: Body
    var body: some View {
        VStack(alignment: .leading) {
            makeHeader()
            
            if showingFullCard {
                Image(systemName: "arrow.right")
                
                Spacer()
                
                makeBody()
                    .minimumScaleFactor(0.5)
                
                makeGradient()
                
                makeFooter()
                    .minimumScaleFactor(0.5)
            }
        }
        .foregroundStyle( Color(red: 1, green: 245 / 255, blue: 222 / 255) )
    }
}
