//
//  Layout1.swift
//  CactusComponents
//
//  Created by Brian Masse on 7/17/24.
//

import Foundation
import SwiftUI

struct DatingProfileLayout: View {
    
    private struct LocalConstants {
        static let secondaryFontOpacity: Double = 0.8
        static let tertiaryFontOpacity: Double = 0.5
    }
    
    private let bodyText = "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua."
    
    
//    MARK: MakeBackground
    @ViewBuilder
    private func makeBackground() -> some View {
        GeometryReader { geo in
            ZStack {
                Image( "profilePic" )
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                
                LinearGradient(colors: [.black, .clear],
                               startPoint: .bottom,
                               endPoint: .center)
            }
            .frame(width: geo.size.width)
        }
        .ignoresSafeArea()
    }
    
//    MARK: MakeHeader
    @ViewBuilder
    private func makeHeader() -> some View {
        
        HStack(spacing: 20) {
            VStack(alignment: .leading) {
                Text( "potential Match Score" )
                    .textCase(.uppercase)
                    .font(.callout)
                    .opacity(LocalConstants.secondaryFontOpacity)
                    
                Text("98")
                    .font(.largeTitle)
                    .bold()
            }
            
            Spacer()
            
            Rectangle()
                .frame(width: 1, height: 60)
                .opacity(LocalConstants.tertiaryFontOpacity)
            
            VStack {
               
                Image(systemName: "text.bubble")
                    .font(.title)
                    .padding(.bottom, 5)
                
                Text("2 new Notifications")
                    .font(.caption)
                    .multilineTextAlignment(.center)
                    .opacity(LocalConstants.secondaryFontOpacity)
                    .frame(width: 100)
                
            }
            
        }
        .padding( [.bottom, .horizontal ], 35)
        .background {
            RoundedRectangle(cornerRadius: 50)
                .foregroundStyle(.black)
                .padding(10)
                .ignoresSafeArea()
        }
    }
    
//    MARK: MakeOverview
    @ViewBuilder
    private func makeOverview() -> some View {
        
        VStack(alignment: .leading) {
            
            Image("portrait")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 75, height: 75)
                .clipShape(Circle())
                .shadow(color: .black.opacity(0.5), radius: 20)
            
            HStack(alignment: .bottom) {
                VStack(alignment: .leading, spacing: -15) {
                    Text("Brian")
                    Text("Masse")
                }
                .bold()
                .font(.custom("helvetica", size: 60))
                    
                Image(systemName: "checkmark.seal.fill")
                    .font(.title)
                    .padding(.bottom, 10)
                
                Spacer()
            }
            .padding(.bottom)
            
            Text("About me")
                .textCase(.uppercase)
                .font(.callout)
                .opacity(LocalConstants.secondaryFontOpacity)
            
            Text(bodyText)
                .padding(.trailing)
        }
    }
    
//    MARK: makeStats
    @ViewBuilder
    private func makeVerticalDivider() -> some View {
        Rectangle()
            .frame(width: 1, height: 25)
    }
    
    @ViewBuilder
    private func makeStat(icon: String, information: String) -> some View {
        HStack {
            Image(systemName: icon)
            
            Text( information )
        }
        .padding(.vertical, 7)
        .padding(.horizontal)
        .background {
            RoundedRectangle(cornerRadius: 10)
                .opacity(0.3)
        }
        
        .padding(.horizontal, 7)
    }
    
    @ViewBuilder
    private func makeStats() -> some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack {
                
                makeStat(icon: "birthday.cake", information: "18 Yrs")
                
                makeVerticalDivider()
                
                makeStat(icon: "flag.filled.and.flag.crossed", information: "Bi")
                
                makeVerticalDivider()
                
                makeStat(icon: "wineglass", information: "Drinks")
            }
        }
    }
    
    
//    MARK: Body
    var body: some View {
        
        ZStack {
            
            makeBackground()
            
            VStack {
                
                makeHeader()
                
                Spacer()
                
                VStack {
                    makeOverview()
                    
                    makeStats()
                }
                .padding()
                
                Spacer()
            }
        }
    }
}

#Preview {
    
    DatingProfileLayout()
    
}
