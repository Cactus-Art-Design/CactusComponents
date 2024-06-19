//
//  UIConstants.swift
//  ScrollingCardsDemo
//
//  Created by Brian Masse on 5/26/24.
//

import Foundation
import SwiftUI

struct Constants {
    static let mainFont: String = "Neutral Face"
}

struct StyledText: View {
    let text: String
    let size: Double
    let bold: Bool
    
    init( _ text: String, size: Double, bold: Bool = false ) {
        self.text = text
        self.size = size
        self.bold = bold
    }
    
    var body: some View {
        Text(text)
            .font(Font.custom(Constants.mainFont, size: size))
            .bold(bold)
    }
}

struct Divider: View {
    var body: some View {
        Rectangle()
            .frame(height: 1)
            .opacity(0.6)
    }
}
