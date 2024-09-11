//
//  CactusComponentsApp.swift
//  CactusComponents
//
//  Created by Brian Masse on 6/18/24.
//

import SwiftUI
import UIUniversals

@main
struct CactusComponentsApp: App {
    
    
//    This sets all the important constants for the UIUniversals Styled to match recall
//    These are initialized on the spot, (as opposed to be constant variables)
//    because they should only be invoked from UIUniversals after this point
    private func setupUIUniversals() {
        Colors.setColors(baseLight:         .init(255, 255, 255),
                         secondaryLight:    .init(240, 240, 240),
                         baseDark:          .init(0, 0, 0),
                         secondaryDark:     .init(25.5, 25.5, 25.5),
                         lightAccent:       .init(63, 45, 64),
                         darkAccent:        .init(212, 178, 214))
        
        Constants.UIDefaultCornerRadius = 20
        
        Constants.setFontSizes(UILargeTextSize: 35,
                               UITitleTextSize: 45,
                               UIMainHeaderTextSize: 35,
                               UIHeaderTextSize: 30,
                               UISubHeaderTextSize: 20,
                               UIDefeaultTextSize: 15,
                               UISmallTextSize: 11)
        
//        This registers all the fonts provided by UIUniversals
        FontProvider.registerFonts()
    }
    
//    before anything is done in the app, make sure UIUniversals is properly initialized
    init() { setupUIUniversals() }
    
    var body: some Scene {
        WindowGroup {
            CactusTextHaloDemoView()
        }
    }
}
