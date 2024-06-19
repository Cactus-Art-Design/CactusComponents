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

@available(iOS 15.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
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
//            .bold(bold)
    }
}

@available(iOS 15.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
struct Divider: View {
    var body: some View {
        Rectangle()
            .frame(height: 1)
            .opacity(0.6)
    }
}
