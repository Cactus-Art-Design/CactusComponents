//
//  SlidingModal.swift
//  SlidingModalDemo
//
//  Created by Brian Masse on 5/28/24.
//

import Foundation
import SwiftUI

@available(iOS 15.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
internal struct SlidingModalLocalConstants {
        
    static let minCoverHeight: CGFloat = 275
    static let startingPeekHeight: CGFloat = 75
    static let slidingHandleHeight: CGFloat = 30
    
    static let slidingVisibleHandleHeight: CGFloat = 40
    static let slidingVisibleHandleWidth: CGFloat = 80
    
    static let minimizePeekThreshold: CGFloat = 10
    static let showFullCoverThreshold: CGFloat = 140
    
    static let lightColor           = Color(red: 1, green: 248/255, blue: 223/255)
    static let darkColor            = Color(red: 0, green: 0, blue: 0)
    static let secondaryLightColor  = Color(red: 0, green: 0, blue: 0)
    static let secondaryDarkColor   = Color(red: 15/255, green: 15/255, blue: 15/255)
    
    static let accentColor = Color(red: 190 / 255, green: 72 / 255, blue: 22 / 255)
    
    static let cornerRadius: CGFloat = 40
}

//MARK: SlidingModal
enum PeekState {
    case full
    case minimized
    case mid
}

@available(iOS 15.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
internal struct SlidingModal<C1:View, C2:View>: View {
    
    @Environment(\.colorScheme) var colorScheme
    
    let softImpact = UIImpactFeedbackGenerator(style: .soft)
    let lightImpact = UIImpactFeedbackGenerator(style: .light)
    let rigidImpact = UIImpactFeedbackGenerator(style: .rigid)
    
    private let coordinateSpaceName = "SlidingModalCoordinateSpaceName"
    
    @State var height: CGFloat = SlidingModalLocalConstants.startingPeekHeight
    
    @State var peekState: PeekState = .minimized
    @State var inDismissGesture = false
    
    @ViewBuilder var frontContentBuilder:   (Binding<PeekState>) -> C1
    @ViewBuilder var backContentBuilder:    (Binding<PeekState>) -> C2
    
    init( frontContentBuilder: @escaping (Binding<PeekState>) -> C1,
          backContentBuilder: @escaping (Binding<PeekState>) -> C2 ) {
        self.frontContentBuilder = frontContentBuilder
        self.backContentBuilder = backContentBuilder
    }
    
//    MARK: ShapeMask
    struct PeekMask: Shape {
        func path(in rect: CGRect) -> Path {
            
            let r = SlidingModalLocalConstants.cornerRadius
            
            return Path { path in
//                left curve
                path.addArc(center: .init(x: r, y: rect.maxY - r),
                            radius: r,
                            startAngle: Angle(degrees: 180),
                            endAngle: Angle(degrees: 90),
                            clockwise: true)
                
                path.addLine(to: .init(x: r, y: rect.maxY))
                path.addLine(to: .init(x: 0, y: rect.maxY))
                
//                right curve
                path.move(to: .init( x: rect.maxX - r, y:  rect.maxY - r))
                path.addArc(center: .init(x: rect.maxX - r, y: rect.maxY - r),
                            radius: r,
                            startAngle: Angle(degrees: 90),
                            endAngle: Angle(degrees: 0),
                            clockwise: true)
                
                path.addLine(to: .init(x: rect.maxX,        y: rect.maxY))
                path.addLine(to: .init(x: rect.maxX - r,    y: rect.maxY))
            }
        }
    }
    
//    MARK: PeekToggleMask
    struct PeekToggleMask: Shape {
        func path(in rect: CGRect) -> Path {
            let height = SlidingModalLocalConstants.slidingVisibleHandleHeight
            let width = SlidingModalLocalConstants.slidingVisibleHandleWidth
            
            let r = height / 2
            
            return Path { path in
                
//                topLeft
                var center: CGPoint = .init(x: rect.midX - r - width / 2, y: rect.minY + r)
                path.move(to: center)
                path.addArc(center: center,
                            radius: r,
                            startAngle: Angle(degrees: -90),
                            endAngle:  Angle(degrees: 0),
                            clockwise: false)
                
                path.addLine(to: .init( x: rect.midX - width / 2 + r, y: rect.minY + r ))
                path.addLine(to: .init( x: rect.midX - width / 2 + r, y: rect.minY))
                path.addLine(to: .init( x: rect.midX - r - width / 2, y: rect.minY ))
                
//                bottomLeft
                path.move(to: .init(x: rect.midX + r - width / 2, y: rect.minY + r))
                path.addArc(center: .init(x: rect.midX + r - width / 2, y: rect.minY + r),
                            radius: r,
                            startAngle: Angle(degrees: 180),
                            endAngle:  Angle(degrees: 90),
                            clockwise: true)
                
//                topRight
                center = .init(x: rect.midX + r + width / 2, y: rect.minY + r)
                path.move(to: center)
                path.addArc(center: center,
                            radius: r,
                            startAngle: Angle(degrees: -90),
                            endAngle:  Angle(degrees: -180),
                            clockwise: true)
                
                path.addLine(to: .init( x: rect.midX + width / 2 - r, y: rect.minY + r ))
                path.addLine(to: .init( x: rect.midX + width / 2 - r, y: rect.minY))
                path.addLine(to: .init( x: rect.midX + r + width / 2, y: rect.minY ))
                
//                bottomLeft
                path.move(to: .init(x: rect.midX - r + width / 2, y: rect.minY + r))
                path.addArc(center: .init(x: rect.midX - r + width / 2, y: rect.minY + r),
                            radius: r,
                            startAngle: Angle(degrees: 0),
                            endAngle:  Angle(degrees: 90),
                            clockwise: false)
                
//                rectn
                path.move(to: .init(x: rect.midX + r - width / 2, y: rect.minY))
                path.addLine(to: .init(x: rect.midX - r + width / 2, y: rect.minY))
                path.addLine(to: .init(x: rect.midX - r + width / 2, y: rect.minY + height))
                path.addLine(to: .init(x: rect.midX + r - width / 2, y: rect.minY + height))
                
            }
        }
    }
    
//    MARK: Gestures
    func dragGesture(geo: GeometryProxy) -> some Gesture {
        DragGesture(coordinateSpace: .named(coordinateSpaceName))
            .onChanged { value in
                if peekState == .full {
                    inDismissGesture = true
                }
                
                if inDismissGesture {
                    if value.translation.height > 40 {
                        withAnimation {
                            self.peekState = .mid
                            self.makeHeight(in: geo, dragPosition: value.location.y)
                        }
                    }
                } else {
                    withAnimation {
                        makeHeight(in: geo, dragPosition: value.location.y)
                    }
                }
            }
            .onEnded { value in
                inDismissGesture = false
                
                let velocity = value.velocity.height / 14
                let maximum = peekState != .full ? SlidingModalLocalConstants.minCoverHeight : 0
                let proposedHeight = value.location.y + velocity

                withAnimation {
                    makeHeight(in: geo, dragPosition: max( proposedHeight, maximum ))
                }
            }
    }

//    MARK: Struct Methods
    private var baseColor: Color {
        colorScheme == .dark ? SlidingModalLocalConstants.secondaryDarkColor : SlidingModalLocalConstants.lightColor
    }
    
    private var secondaryColor: Color {
        colorScheme == .dark ? SlidingModalLocalConstants.darkColor : SlidingModalLocalConstants.secondaryLightColor
    }
    
    private func makeHeight(in geo: GeometryProxy, dragPosition: CGFloat) {
        if peekState == .full { return }
        
        let minimum = SlidingModalLocalConstants.startingPeekHeight
        let maximum = geo.size.height - SlidingModalLocalConstants.minCoverHeight
        
        let proposedHeight = geo.size.height - abs(dragPosition)
        let newHeight = min(max( proposedHeight, minimum), maximum)
        
        if proposedHeight > newHeight {
            softImpact.impactOccurred(intensity: (proposedHeight - newHeight) / SlidingModalLocalConstants.showFullCoverThreshold)
        }
        
        if proposedHeight - newHeight > SlidingModalLocalConstants.showFullCoverThreshold {
            if self.peekState != .full { rigidImpact.impactOccurred() }
            self.peekState = .full
            self.height = geo.size.height
            return
        }
        
        if proposedHeight <= SlidingModalLocalConstants.startingPeekHeight + SlidingModalLocalConstants.minimizePeekThreshold {
            if self.peekState != .minimized { rigidImpact.impactOccurred() }
            self.peekState = .minimized
            self.height = SlidingModalLocalConstants.startingPeekHeight
            return
        }
        
        self.peekState = .mid
        self.height = newHeight
    }
    
    private func makeShrinkingWidth(in geo: GeometryProxy) -> CGFloat {
        (self.height - SlidingModalLocalConstants.startingPeekHeight) / 45
    }
    
//    MARK: ViewBuilder
    @ViewBuilder
    private func makeBackground(in geo: GeometryProxy) -> some View {
        VStack(spacing: 0) {
            Rectangle()
                .foregroundStyle(secondaryColor)
                .frame(height: SlidingModalLocalConstants.cornerRadius)
                .clipShape(PeekMask())
                .offset(y: 0.8)
                .frame(width: geo.size.width - makeShrinkingWidth(in: geo) )
            
            VStack {
                Spacer()
                
                ZStack {
                    Rectangle()
                        .contentShape(Rectangle())
                        .foregroundStyle(.clear)
                        .gesture(dragGesture(geo: geo))
                    
                    backContentBuilder($peekState)
                        .padding(.top, peekState != .full ? SlidingModalLocalConstants.slidingVisibleHandleHeight : 0)
                }
                
                Spacer()
            }
            .ignoresSafeArea()
            .frame(width: geo.size.width, height: self.height)
            .foregroundStyle( SlidingModalLocalConstants.lightColor )
            .background( secondaryColor )
            .overlay(makeToggle(in: geo), alignment: .top)
        }
    }
    
    @ViewBuilder
    private func makeForeground(in geo: GeometryProxy) -> some View {
        VStack {
            Spacer()
            
            if peekState != .full {
                frontContentBuilder($peekState)
            }
            
            Spacer()
        }
        .frame(width: geo.size.width - makeShrinkingWidth(in: geo))
        .background( baseColor )
        .clipShape(RoundedRectangle(cornerRadius: SlidingModalLocalConstants.cornerRadius))
        .ignoresSafeArea()
    }
    
    @ViewBuilder
    private func makeToggle(in geo: GeometryProxy) -> some View {
        ZStack {
            Rectangle()
                .foregroundStyle( baseColor )
            
            if peekState != .full {
                Image(systemName: "chevron.up")
            }
        }
        .clipShape(PeekToggleMask())
        .frame(width: SlidingModalLocalConstants.slidingVisibleHandleWidth + SlidingModalLocalConstants.slidingHandleHeight,
               height: SlidingModalLocalConstants.slidingVisibleHandleHeight)
        .gesture(dragGesture(geo: geo))
        .offset(y: -1)
        .offset(y: peekState == .full ? -SlidingModalLocalConstants.slidingHandleHeight * 2 : 0)
    }
    
//    MARK: Body
    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .bottom) {
                
                ZStack(alignment: .top) {
                    Rectangle()
                        .foregroundStyle(secondaryColor)
                        .ignoresSafeArea()
                    
                    makeForeground(in: geo)
                        .frame(height: geo.size.height - SlidingModalLocalConstants.startingPeekHeight)
                }
                
                makeBackground(in: geo)
            }
            .onAppear { self.height = SlidingModalLocalConstants.startingPeekHeight }
        }
        .coordinateSpace(name: coordinateSpaceName)
    }
}
