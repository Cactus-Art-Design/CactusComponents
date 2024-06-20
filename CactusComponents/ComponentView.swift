//
//  ComponentView.swift
//  CactusComponents
//
//  Created by Brian Masse on 6/19/24.
//

import Foundation
import SwiftUI

struct CactusComponentPage: View {
    
//    let component: CactusComponent
    
    var body: some View {
        
        Rectangle()
            .frame(width: 200, height: 200)
            .holdLoadingWheel(message: "hello world") {
            }
            
    }
    
    
}

//MARK: HoldLoadingWheel
struct HoldLoadingWheel: ViewModifier {
    
    let size: CGFloat = 25
    let thickness: CGFloat = 12
    
    let threshold: Double
    let action: () -> Void
    
    let message: String
    let icon: String
    
    init( _ duration: Double, message: String, icon: String, action: @escaping () -> Void ) {
        self.threshold = duration * 100
        self.action = action
        self.message = message
        self.icon = icon
    }
    
    @State private var allowsGestureTesting: Bool = false
    
    @State var timer = Timer.publish(every: 5, on: .main, in: .common).autoconnect()
    @State var timerRunning: Bool = false
    @State var complete: Bool = false
    @State var count: Double = 0
    
    private func endTimer() {
        self.timer.upstream.connect().cancel()
        withAnimation {
            self.count = 0
            self.timerRunning = false
        }
    }
    
    private func startTimer() {
        self.timer = Timer.publish(every: 0.01, on: .main, in: .common).autoconnect()
        withAnimation {
            self.timerRunning = true
            self.count = 1
        }
    }
    
//    MARK: Gestures
    private var holdGesture: some Gesture {
        DragGesture(minimumDistance: 0)
            .onChanged { _ in
                if allowsGestureTesting {
                    if count == 0 && !complete {
                        self.startTimer()
                        self.allowsGestureTesting = false
                    }
                }
            }
            .onEnded { _ in
                self.endTimer()
                self.complete = false
            }
    }
    
    private var detectionGesture: some Gesture {
        LongPressGesture(minimumDuration: 0.05)
            .onChanged { _ in
                self.allowsGestureTesting = false
            }
            .onEnded { value in
                self.allowsGestureTesting = true
            }
    }

//    MARK: Arc
    private struct Arc: Shape {
        var angle: Double
        
        func path(in rect: CGRect) -> Path {
            var path = Path()
            
            path.move(to: .init(x: rect.maxX,
                                y: rect.midY))
            path.addArc(center: .init(x: rect.midX,
                                      y: rect.midY),
                        radius: rect.width / 2,
                        startAngle: .init(degrees: 0),
                        endAngle: .init(degrees: -angle),
                        clockwise: true)
            return path
        }
    }
    
//    MARK: Body
    func body(content: Content) -> some View {
        ZStack {
            content
                .onTapGesture {}
                .gesture( SimultaneousGesture(detectionGesture, holdGesture)  )
                .blur( radius: timerRunning ? max(count / 20, 0) : 0 )
                .opacity( timerRunning ? 0.75 : 1 )
            
            let angle: Double = 360 * ( self.count / self.threshold )
            if self.timerRunning && !complete {
                VStack {
                    ZStack {
                        Arc(angle: 360)
                            .stroke(style: .init(lineWidth: thickness, lineCap: .round))
                            .frame(width: size, height: size)
                            .opacity(0.3)
                        
                        Arc(angle: angle)
                            .stroke(style: .init(lineWidth: thickness, lineCap: .round))
                            .frame(width: size, height: size)
                            .shadow(color: .white.opacity(0.2), radius: 10)
                    }
                    .zIndex(10)
                    .transition(.asymmetric(insertion: .scale(scale: 0.1),
                                            removal:
                            .scale(scale: 1.8)
                            .combined(with: .opacity)))
                    .padding(.bottom)
                    
                    Image(systemName: icon)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: size)
                    
                    Text(message)
                        .multilineTextAlignment(.center)
                        .font(.subheadline)
                        .frame(width: size * 10)
                }
            }
        }
        .onReceive(timer) { _ in
            if self.timerRunning { self.count += 1 }
            if self.count >= threshold {
                self.endTimer()
                self.action()
                withAnimation {
                    self.complete = true
                }
            }
        }
    }
}

extension View {
    func holdLoadingWheel( _ duration: Double = 2,
                           message: String,
                           icon: String = "hand.point.up",
                           action: @escaping () -> Void ) -> some View {
        modifier(HoldLoadingWheel( duration, message: message, icon: icon, action: action ))
    }
}

#Preview {
    CactusComponentPage()
}
