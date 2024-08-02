//
//  CactusContextMenu.swift
//  CactusComponents
//
//  Created by Brian Masse on 7/31/24.
//

import Foundation
import SwiftUI

struct CactusContextMenu<C: View>: View {
    
//    MARK: Vars
    let count: Int
    let radius: Double
    let threshold: Double
    
    let guideCount: Int
    
    @State private var currentAngle: Double = -100
    @State private var selectedIndex: Int = -1
    
    private let unselectedAngle: Double = 100
    private let unselectedIndex: Int = -1
    
    @ViewBuilder let contentBuilder: (Int) -> C
    let action: (Int) -> Void
    
    init( for count: Int, in radius: Double = 120,
          threshold: Double = 20, guideCount: Int = 20,
          @ViewBuilder contentBuilder: @escaping (Int) -> C, action: @escaping (Int) -> Void ) {
        self.count = count
        self.radius = radius
        self.threshold = threshold
        self.guideCount = guideCount
        
        self.contentBuilder = contentBuilder
        self.action = action
    }
    
    private func degToRad( _ angle: Double ) -> Double {
        (Double.pi * angle) / 180
    }
    
//    MARK: Gesture
//    based on the current position of the drag gesture, what is the index of the button you are likely to select
    private func getIndex(from position: CGPoint) -> Int {
        
        let measuredAngle = atan( (radius - position.y) / (position.x - radius) )
        self.currentAngle = measuredAngle < 0 ? Double.pi + measuredAngle : measuredAngle
        
        let segmentArcLength: Double = Double.pi / Double(count - 1)
        let proposedIndex = round(self.currentAngle / segmentArcLength)
        
        return Int(proposedIndex)
    }
    
//    get the distance form the current drag gesture position to the center of the gesture
    private func getLength(from pos: CGPoint) -> Double {
        if pos.y > radius { return 0 }
        return sqrt( pow( pos.x - radius, 2 ) + pow( Double(radius - pos.y), 2 ) )
    }
    
//    check whether you are close enough to the selected button to trigger its action
    private func checkSelection(in pos: CGPoint, and translation: CGSize) {
        if getLength(from: pos) > threshold {
            self.selectedIndex = getIndex(from: pos)
        } else {
            self.resetGesture()
        }
    }
    
//    when the gesture fails, deselect the button
    private func resetGesture() {
        self.selectedIndex = unselectedIndex
        self.currentAngle = unselectedAngle
    }
    
    private var dragGesture: some Gesture {
        DragGesture(minimumDistance: 10)
            .onChanged { value in
                
                checkSelection(in: value.location, and: value.translation)
            }
        
            .onEnded { _ in
                if selectedIndex != unselectedIndex { self.action( self.selectedIndex ) }
                self.resetGesture()
            }
        
    }
    
//    MARK: Guides
    private func makeOpacity(in angle: Double) -> Double {
        let proposedDifference = abs(angle - currentAngle)
        let difference = proposedDifference == 0 ? 0.01 : proposedDifference
        return 1 /  (10 * difference)
    }
    
    @ViewBuilder
    private func makeGuides() -> some View {
        
        ZStack {
            ForEach(0..<guideCount, id: \.self) { i in
                    
                let angle = Double(i) / Double(guideCount) * Double.pi
                
                RoundedRectangle(cornerRadius: 25)
                    .frame(width: 3, height: 7  )
                    .opacity(makeOpacity(in: angle))
                    .rotationEffect(.init(radians: -angle + Double.pi / 2))
                    .offset(x: radius * cos(angle), y: radius * -sin(angle))
            }
        }
    }
    
//    MARK:
    @ViewBuilder
    private func makeButtons() -> some View {
        ZStack {
            ForEach( 0..<count, id: \.self ) { i in
                
                let angle: Double = (Double.pi / Double(count - 1)) * Double(i)
                
                contentBuilder(i)
                    .frame(width: 50, height: 50)
                    .scaleEffect( i == selectedIndex ? 1.5 : 1 )
                    .offset(x: radius * cos(angle), y: -radius * sin(angle))
                    .opacity(makeOpacity(in: angle) + 0.5)
                
                    .onTapGesture {
                        action(i)
                        self.selectedIndex = i
                        self.currentAngle = angle
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                            self.resetGesture()
                        }
                    }
            }
        }
    }
    
//    MARK: Body
    var body: some View {
        
        ZStack {
            makeGuides()
            
            makeButtons()
        }
        .offset(y: radius / 2)
        .frame(width: radius * 2, height: radius)
        
        .animation(.spring, value: currentAngle)
        .animation(.spring, value: selectedIndex)
        
        .contentShape(Rectangle())
        
        .gesture(dragGesture)
    }
    
}


//MARK: Demo View
struct CactusContextMenuDemoView: View {
    
    let icons = [ "scribble", "doc.richtext", "shareplay", "sportscourt", "lightspectrum.horizontal" ]
    
    var body: some View {
        
        CactusContextMenu(for: 5) { i in
            ZStack {
                Image(systemName: icons[i])
                    .font(.title3)
                    .frame(width: 40, height: 40)
                    .padding(5)
                    .background {
                        RoundedRectangle(cornerRadius: 50)
                            .foregroundStyle( Color(red: 0.16, green: 0.16, blue: 0.16)  )
                    }
            }
        } action: { i in
            print(i)
        }
    }
    
}

#Preview {
    CactusContextMenuDemoView()
}
