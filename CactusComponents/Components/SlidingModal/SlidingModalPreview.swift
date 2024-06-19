//
//  ContentView.swift
//  SlidingModalDemo
//
//  Created by Brian Masse on 5/28/24.
//

import SwiftUI

@available(iOS 15.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
public final class SlidingModalComponent: CactusComponent, SingleInstance {
    private init() {
        super.init(name: "Sliding Modal",
                   description: "A dynamic modal with haptic feedback and animated gestures") {
            SlidingModalPreview()
        }
    }
    
    public static var shared: SlidingModalComponent = SlidingModalComponent()
}

@available(iOS 15.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
private struct SlidingModalPreview: View {
    var body: some View {
        SlidingModal { peekState in
            SlidingFrontContent()
        } backContentBuilder: { peekState in
            SlidingBackContent(peekState: peekState)
        }
    }
}
