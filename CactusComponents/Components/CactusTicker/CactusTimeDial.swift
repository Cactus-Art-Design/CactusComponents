//
//  CactusTimeDial.swift
//  CactusComponents
//
//  Created by Brian Masse on 9/10/24.
//

import Foundation
import SwiftUI
import UIUniversals


struct CactusTimeDial: View {
    
    
    @State private var time: Date = .now
    
    @State private var postMeridian: Bool = false
    @State private var currentMeridianSwitch: Int = 0
    
    @State private var selectingHour: Bool = true
    
//    MARK: Convenience Vars
    private var currentDay: Date {
        time.resetToStartOfDay()
    }
    
    private var currentHour: Double {
        Double(Calendar.current.component(.hour, from: time))
    }
    
    private var currentMinute: Double {
        Double(Calendar.current.component(.minute, from: time))
    }
    
//    MARK: Angles and Translations
    ///measured in radians
    private func getHourAngle(of time: Double) -> Double { (time.truncatingRemainder(dividingBy: 12) / 12) * Double.pi }
    
    private func getMinuteAngle(of time: Double) -> Double { (time / 60) * Double.pi }
    
    private func getTranslation(in radius: Double, using angle: Double) -> CGSize {
        let x = cos(angle) * radius
        let y = sin(angle) * (radius)
        return .init(width: -x, height: -y)
    }

    private func roundMinute(_ minute: Double) -> Double { round(minute / 5) * 5 }
    
//    MARK: Setters
    private func setHour( _ hour: Double ) {
        let hourValue = (Int(hour) % 12) + ( !postMeridian ? 0 : 12 )
        let minuteValue = Calendar.current.component(.minute, from: time)
            
        self.time = Calendar.current.date(bySettingHour: hourValue, minute: minuteValue, second: 0, of: time)!
    }
    
    private func setMinute( _ minute: Double ) {
        let minuteValue = Int(roundMinute(minute)) % 60
        
        self.time = Calendar.current.date(bySettingHour: Int(currentHour),
                                          minute: minuteValue,
                                          second: 0, of: time)!
    }
    
    
//    MARK: TimeMarker
    @ViewBuilder
    private func makeTimeMarker(in radius: Double) -> some View {
        
        let angle = selectingHour ? getHourAngle(of: currentHour) : getMinuteAngle(of: currentMinute)

        VStack {
            Circle()
                .frame(width: 10, height: 10)
            
            Rectangle()
                .frame(width: 2)
        }
        .rotationEffect(.radians(angle - (Double.pi / 2)), anchor: .bottom)
        
    }
    
//    MARK: Labels
    @ViewBuilder
    private func makeHourLabel(_ hour: Double, in radius: Double) -> some View {
        
        let translation = getTranslation(in: radius, using: getHourAngle(of: hour))
        
        Text("\(Int(hour))")
            .offset(x: translation.width, y: translation.height)
            .transition(.scale)
            .onTapGesture {
                withAnimation {
                    setHour(hour)
                    selectingHour = false
                }
            }
    }
    
    @ViewBuilder
    private func makeHourLabels( in radius: Double ) -> some View {
        let offset = !postMeridian ? 0 : 12
        
        ZStack {
            ForEach( 0..<12, id: \.self ) { i in
                let hour = offset + i
                
                makeHourLabel(Double(hour), in: radius)
                    .id(hour)
            }
        }
    }
    
//    MARK: MinuteLabels
    @ViewBuilder
    private func makeMinuteLabel(_ minute: Double, in radius: Double) -> some View {
        let translation = getTranslation(in: radius, using: getMinuteAngle(of: minute))
        
        Text("\(Int(minute))")
            .offset(x: translation.width, y: translation.height)
            .onTapGesture { withAnimation {
                setMinute(minute)
            }
            }
    }
    
    @ViewBuilder
    private func makeMinuteLabels( in radius: Double ) -> some View {
        ZStack {
            ForEach( 0..<12, id: \.self ) { i in
                
                let minute = i * ( 60 / 12 )
                
                makeMinuteLabel(Double(minute), in: radius)
                
            }
        }
    }
    
//    MARK: Time Preview
    @ViewBuilder
    private func makeTimePreview() -> some View {
        
        let hourLabel = time.formatted(Date.FormatStyle().hour(.twoDigits(amPM: .omitted)) )
        let minuteLabel = time.formatted( Date.FormatStyle().minute() )
        
        VStack {
            Text("\(time.formatted())")
            
            HStack {
                
                Text( hourLabel )
                    .padding()
                    .background(.gray)
                    .onTapGesture { withAnimation { selectingHour = true } }
                
                Text(":")
                
                Text( minuteLabel )
                    .padding()
                    .background(.gray)
                    .onTapGesture { withAnimation { selectingHour = false } }
                
                VStack {
                    Text("AM")
                        .padding()
                        .background(.gray)
                        .onTapGesture { withAnimation { postMeridian = false } }
                        .opacity(!postMeridian ? 1 : 0.5)
                    
                    Text("PM")
                        .padding()
                        .background(.gray)
                        .onTapGesture { withAnimation { postMeridian = true } }
                        .opacity(!postMeridian ? 0.5 : 1)
                }
            }
        }
    }
    
//    MARK: Plane Gesture
    private func togglePlaneGestureMeridian(from position: Double) {
        if position > 0 && currentMeridianSwitch != 0  {
            postMeridian.toggle()
            currentMeridianSwitch = 0
        }
        if position < 0 && currentMeridianSwitch != 1 {
            postMeridian.toggle()
            currentMeridianSwitch = 1
        }
    }
    
    private func planeGesture(in radius: Double) -> some Gesture {
        DragGesture()
            .onChanged { value in
                let x = value.location.x - radius
                let y = radius - value.location.y
                
                let measuredAngle = atan( y / x )
                let angle = measuredAngle < 0 ? Double.pi + measuredAngle : measuredAngle
                let fraction = angle / Double.pi
                
                if selectingHour {
                    togglePlaneGestureMeridian(from: y)
                    let hourValue = 12 - fraction * 12
                    self.setHour(hourValue)
                    
                } else {
                    let minuteValue = 60 - fraction * 60
                    self.setMinute(minuteValue)
                }
            }
        
            .onEnded { _ in
                self.selectingHour = false
                self.currentMeridianSwitch = 0
            }
    }
    
//    MARK: LinearGesture
    private func toggleLinearGestureMeridian(from fraction: Double) {
        if fraction > 0.5 && !postMeridian { postMeridian = true }
        if fraction < 0.5 && postMeridian { postMeridian = false }
    }
    
    private func linearGesture(in radius: Double) -> some Gesture {
        DragGesture()
            .onChanged { value in
                let fraction = value.location.x / (radius * 2)
                
                if selectingHour {
                    toggleLinearGestureMeridian(from: fraction)
                    let hourValue = ( fraction * 24 )
                    self.setHour(hourValue)
                    
                } else {
                    let minuteValue = ( fraction * 60 )
                    self.setMinute(minuteValue)
                }
            }
        
            .onEnded { _ in
                self.selectingHour = false
            }
    }
    
//    MARK: Body
    var body: some View {
        
        VStack {
            GeometryReader { geo in
                let radius = geo.size.width / 2
                
                ZStack(alignment: .bottom) {
                    Rectangle()
                        .foregroundStyle(.clear)
                        .contentShape(Rectangle())
                    
                    makeTimePreview()
                    
                    makeTimeMarker(in: radius)
                    
                    if selectingHour {
                        makeHourLabels(in: radius)
                        
                    } else {
                        makeMinuteLabels(in: radius)
                    }
                }
                .gesture(planeGesture(in: radius ))
            }
            .animation(.easeInOut, value: postMeridian)
            .animation(.easeInOut(duration: 0.25), value: time)
            .animation(.easeInOut, value: selectingHour)
            
            .border(.red)
            .aspectRatio(2, contentMode: .fit)
            
            
            GeometryReader { geo in
                Rectangle()
                    .gesture(linearGesture(in: geo.size.width / 2))
            }.frame(height: 50)
        }
    }
}

#Preview {
    CactusTimeDial()
}
