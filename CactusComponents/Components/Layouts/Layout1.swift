//
//  Layout1.swift
//  CactusComponents
//
//  Created by Brian Masse on 7/17/24.
//

import Foundation
import SwiftUI
import UIUniversals

struct CactusLayout1Model {
    
    struct CactusLayout1ProfileQuestionModel {
        let question: String
        let answer: String
    }
    
    let firstName: String
    let lastName: String
    
    let profilePhoto: String
    let coverPhoto: String
    
    let about: String
    let potentialMatchScore: Double
    
//    profile information
    let birthday: Date
    let sexuality: String
    let drinks: Bool
    let relationshipInterest: String
    
    let profileQuestions: [CactusLayout1ProfileQuestionModel]
    
    func getAge() -> Int {
        Int(Date.now.timeIntervalSince(birthday) / (365 * 24 * 60 * 60))
    }
}

//MARK: DatingProfileLayout
struct CactusLayout1: View {
    
    private struct LocalConstants {
        static let secondaryFontOpacity: Double = 0.8
        static let tertiaryFontOpacity: Double = 0.5
        
        static let fullProfilePicSize: Double = 75
        static let compactProfilePicSize: Double = 50
        
        static let fullNameSize: Double = 60
        static let compactNameSize: Double = 30
    }
    
    @Environment( \.colorScheme ) var colorScheme
    
    private let profilePicId = "profilePicId"
    private let fullNameId = "fullNameId"
    
    @Namespace private var layoutNamespace
    @State private var scrollPosition: CGPoint = .zero
    
    var scrolledBeyondLanding: Bool {
        scrollPosition.y < -50
    }
    
//    MARK: Filler Data
    static let bodyText = "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua."
    
    let profile = CactusLayout1Model(firstName: "Brian",
                                     lastName: "Masse",
                                     profilePhoto: "portrait",
                                     coverPhoto: "portrait2",
                                     about: bodyText,
                                     potentialMatchScore: 98.5,
                                     birthday: makeBirthday(),
                                     sexuality: "Bi",
                                     drinks: true,
                                     relationshipInterest: "Long term",
                                     profileQuestions: makeProfileQuestions())
    
    static func makeBirthday() -> Date {
        var comps = DateComponents()
        comps.day = 18
        comps.month = 05
        comps.year = 2005
        
        return Calendar.current.date(from: comps) ?? .now
    }
    
    static func makeProfileQuestions() -> [CactusLayout1Model.CactusLayout1ProfileQuestionModel ] {
        return [
            .init(question: "Favorite Activity", answer: bodyText),
            .init(question: "Something you should know about me", answer: bodyText),
            .init(question: "Favorite Activity", answer: bodyText)
        ]
    }
    
//    MARK: ConvenienceFunctions
    private func makeTopSpacing(in geo: GeometryProxy) -> Double {
        scrolledBeyondLanding ? geo.size.height * 0.05 : geo.size.height * 0.3
    }
    
//    MARK: MakeBackground
    @ViewBuilder
    private func makeBackground() -> some View {
        GeometryReader { geo in
            ZStack(alignment: .bottom) {
                Image( profile.coverPhoto )
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(height: geo.size.height)
                    .blur(radius: 30)
                
                VStack {
                    Spacer(minLength: geo.size.height * 0.15)
                    Image( profile.coverPhoto )
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(height: geo.size.height * 0.85)
                        .clipped()
                }

                LinearGradient(colors: [colorScheme == .dark ? .black : .white, .clear],
                               startPoint: .bottom,
                               endPoint: .init(x: 0.5, y: scrolledBeyondLanding ? -1 : 0.5))
            }
            .frame(width: geo.size.width)
        }
        .ignoresSafeArea()
    }
    
//    MARK: MakeHeader
    @ViewBuilder
    private func makeHeader() -> some View {
        VStack {
            if scrolledBeyondLanding {
                makeCompactHeader()
            } else {
                makeFullHeader()
            }
        }
        .padding(.horizontal, 35)
        .padding( .vertical)
        .foregroundStyle(.white)
//        .ignoresSafeArea()
        .background {
            RoundedRectangle(cornerRadius: 50)
                .foregroundStyle(.black)
        }
        .padding(10)
        .ignoresSafeArea()
    }
    
    @ViewBuilder
    private func makeFullHeader() -> some View {
        HStack(spacing: 20) {
            VStack(alignment: .leading) {
                Text( "potential Match Score" )
                    .textCase(.uppercase)
                    .font(.callout)
                    .opacity(LocalConstants.secondaryFontOpacity)
                    
                Text( profile.potentialMatchScore.removeTrailingZero() )
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
    }
    
    @ViewBuilder
    private func makeCompactHeader() -> some View {
        HStack(spacing: 20) {
            Text( profile.potentialMatchScore.removeTrailingZero() )
                .font(.title3)
                .bold()
            
            Spacer()
            
            Rectangle()
                .frame(width: 1, height: 30)
                .opacity(LocalConstants.tertiaryFontOpacity)
            
            Image(systemName: "text.bubble")
                .font(.title3)
        }
    }
    
//    MARK: MakeOverview
    @ViewBuilder
    private func makeOverview() -> some View {
        if scrolledBeyondLanding {
            makeCompactOVerview()
        } else {
            makeFullOverview()
        }
    }
    
    @ViewBuilder
    private func makeFullOverview() -> some View {
        VStack(alignment: .leading) {
            Image(profile.profilePhoto)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: LocalConstants.fullProfilePicSize, height: LocalConstants.fullProfilePicSize)
                .clipShape(Circle())
                .shadow(color: .black.opacity(0.5), radius: 20)
                .matchedGeometryEffect(id: profilePicId, in: layoutNamespace)
            
            HStack(alignment: .bottom) {
                VStack(alignment: .leading, spacing: -15) {
                    Text(profile.firstName)
                    Text(profile.lastName)
                }
                .bold()
                .font(.custom("helvetica", size: LocalConstants.fullNameSize))
                .shadow(color: .black.opacity(0.6), radius: 20)
                .matchedGeometryEffect(id: fullNameId, in: layoutNamespace)
                    
                Image(systemName: "checkmark.seal.fill")
                    .font(.title)
                    .padding(.bottom, 10)
                
                Spacer()
            }.foregroundStyle(.white)
        }
    }
    
    @ViewBuilder
    private func makeCompactOVerview() -> some View {
        HStack {
            Image(profile.profilePhoto)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: LocalConstants.compactProfilePicSize, height: LocalConstants.compactProfilePicSize)
                .clipShape(Circle())
                .shadow(color: .black.opacity(0.5), radius: 20)
                .padding(.trailing)
                .matchedGeometryEffect(id: profilePicId, in: layoutNamespace)
            
            Text("\(profile.firstName) \(profile.lastName)")
                .foregroundStyle(.white)
                .shadow(color: .black.opacity(0.7), radius: 15)
                .matchedGeometryEffect(id: fullNameId, in: layoutNamespace)
            
            Spacer()
        }
        .bold()
        .font(.custom("helvetica", size: LocalConstants.compactNameSize))
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
                .foregroundStyle(.background)
                .opacity(0.4)
        }
        
        .padding(.horizontal, 7)
    }
    
    @ViewBuilder
    private func makeStats() -> some View {
        VStack(alignment: .leading) {
            
            Text("About")
                .textCase(.uppercase)
                .font(.callout)
                .opacity(LocalConstants.secondaryFontOpacity)
            
            Text(profile.about)
                .lineLimit(2)
                .padding([.bottom, .trailing])
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack {
                    
                    makeStat(icon: "birthday.cake", information: "\(profile.getAge()) Yrs")
                    
                    makeVerticalDivider()
                    
                    makeStat(icon: "flag.filled.and.flag.crossed", information: profile.sexuality)
                    
                    makeVerticalDivider()
                    
                    makeStat(icon: "person.line.dotted.person", information: profile.relationshipInterest)
                    
                    makeVerticalDivider()
                    
                    makeStat(icon: "wineglass", information: profile.drinks ? "drinks" : "doesnt Drink")
                }
            }
        }
    }
    
//    MARK: MakeQuestions
    @ViewBuilder
    private func makeQuestionAndAnswer(_ model: CactusLayout1Model.CactusLayout1ProfileQuestionModel) -> some View {
        VStack(alignment: .leading) {
            Text( model.question )
                .font(.title3)
                .bold()
            
            Text( model.answer )
                .font(.callout)
                .opacity(0.7)
        }
        .padding(.horizontal)
        .padding()
        .background {
            
            RoundedRectangle(cornerRadius: 30)
                .foregroundStyle(.background)
        }
    }
    
    @ViewBuilder
    private func makeBody() -> some View {
        
        VStack(alignment: .leading) {
            Text("get to know \(profile.firstName)")
                .font(.callout)
                .textCase(.uppercase)
                .opacity(LocalConstants.secondaryFontOpacity)
            
            ForEach( profile.profileQuestions.indices, id: \.self ) { i in
                makeQuestionAndAnswer( profile.profileQuestions[i] )
            }
        }
    }
    
//    MARK: Body
    var body: some View {
        
        ZStack(alignment: .top) {
            
            makeBackground()
            
            GeometryReader { geo in
                VStack {
                    Spacer(minLength: makeTopSpacing(in: geo))
                    
                    makeOverview()
                    
                    ScrollReader($scrollPosition, showingIndicator: false) {
                        VStack {
                            
                            makeStats()
                                .padding(.bottom)
                            
                            makeBody()
                                .padding(.bottom, 150)
                        }
                    }.clipShape(RoundedRectangle(cornerRadius: 25))
                }
                .padding(.horizontal)
            }
            
            makeHeader()
        }
        .statusBar(hidden: true)
    }
}

#Preview {
    
    CactusLayout1()
    
}


//TODO: Collect Extension into UIUniverslas
extension Double {
    func removeTrailingZero() -> String {
        let tempVar = String(format: "%g", self)
        return tempVar
    }
}
