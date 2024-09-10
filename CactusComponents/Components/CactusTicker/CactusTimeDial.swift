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
    @State private var inAM: Bool = true
    
    @State private var selectingHour: Bool = true
    
    private var currentDay: Date {
        time.resetToStartOfDay()
    }
    
    private var halfDay: Date {
        Calendar.current.date(byAdding: .hour, value: 12, to: time.resetToStartOfDay())!
    }
    
    private var currentMinute: Double {
        Double(Calendar.current.component(.minute, from: time))
    }
    
    private var timeBinding: Binding<Float> {
        Binding { Float(time.getHoursFromStartOfDay().round(to: 2)) }
        set: { newValue, _ in
            time = time.dateBySetting(hour: Double(newValue))
        }
    }

    
//    MARK: Convenience Functions
    ///measured in radians
    private func getAngle(of time: Date) -> Double {
        let beginningOfDay = time.resetToStartOfDay()
        let timeInterval = time.timeIntervalSince(beginningOfDay)
        let fraction = (timeInterval / Constants.DayTime * 2).truncatingRemainder(dividingBy: 1)
        
        return fraction * Double.pi
    }
    
    private func getTranslation(of time: Date, in radius: Double) -> CGSize {
        let angle = getAngle(of: time)
        let x = cos(angle) * radius
        let y = sin(angle) * (radius)
        return .init(width: -x, height: -y)
    }
    
    private func getMinuteAngle(of time: Double) -> Double {
        (time / 60) * Double.pi
    }
    
    private func getMinuteTranslation(of time: Double, in radius: Double) -> CGSize {
        let angle = getMinuteAngle(of: time)
        let x = cos(angle) * radius
        let y = sin(angle) * (radius)
        return .init(width: -x, height: -y)
    }
    
    @ViewBuilder
    private func makeTimeMarker(in radius: Double) -> some View {
        
        let angle = selectingHour ? getAngle(of: time) : getMinuteAngle(of: currentMinute)

        VStack {
            Circle()
                .frame(width: 10, height: 10)
//                .offset(x: translation.width, y: translation.height)
            
            Rectangle()
                .frame(width: 2)
        }
        .rotationEffect(.radians(angle - (Double.pi / 2)), anchor: .bottom)
        
    }
    
//    MARK: Setters
    private func setHour( using hour: Date ) {
        let hourValue = Calendar.current.component(.hour, from: hour)
        self.setHourWithoutCompletion(hourValue)
        self.selectingHour = false
    }
    
    private func setHourWithoutCompletion( _ hour: Int ) {
        let hourValue = (hour % 12) + ( inAM ? 0 : 12 )
        let minuteValue = Calendar.current.component(.minute, from: time)
            
        self.time = Calendar.current.date(bySettingHour: hourValue, minute: minuteValue, second: 0, of: time)!
    }
    
    private func setMinute( _ minute: Double ) {
        self.time = Calendar.current.date(bySetting: .minute, value: Int(minute), of: time)!
    }
    
//    MARK: Labels
    @ViewBuilder
    private func makeHourLabel(_ hour: Date, in radius: Double) -> some View {
        
        let translation = getTranslation(of: hour, in: radius)
        let label = hour.formatted(Date.FormatStyle().hour(.twoDigits(amPM: .omitted)) )
        
        Text("\(label)")
            .offset(x: translation.width, y: translation.height)
            .transition(.scale)
            .onTapGesture {
                withAnimation {
                    setHour(using: hour)
                }
            }
    }
    
    @ViewBuilder
    private func makeHourLabels( in radius: Double ) -> some View {
        
        let day = time.resetToStartOfDay()
        let offset = inAM ? 0 : 12
        
        ZStack {
            ForEach( 0..<12, id: \.self ) { i in
                let hour = offset + i
                let date = Calendar.current.date(byAdding: .hour, value: hour, to: day)!
                
                makeHourLabel(date, in: radius)
                    .id(hour)
            }
        }
    }
    
//    MARK: MinuteLabels
    @ViewBuilder
    private func makeMinuteLabel(_ minute: Double, in radius: Double) -> some View {
        let translation = getMinuteTranslation(of: minute, in: radius)
        
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
                        .onTapGesture { withAnimation { inAM = true } }
                        .opacity(inAM ? 1 : 0.5)
                    
                    Text("PM")
                        .padding()
                        .background(.gray)
                        .onTapGesture { withAnimation { inAM = false } }
                        .opacity(inAM ? 0.5 : 1)
                }
            }
        }
    }
    
//    MARK: Gestures
    private func planeGesture(in radius: Double) -> some Gesture {
        DragGesture()
            .onChanged { value in
//                print(value.location)
                
                let x = value.location.x - radius
                let y = radius - value.location.y
                
                let measuredAngle = atan( y / x )
                let angle = measuredAngle < 0 ? Double.pi + measuredAngle : measuredAngle
                
                if y < 0 {
                    withAnimation {
                        self.inAM = false
                    }
                } else {
                    withAnimation {
                        self.inAM = true
                    }
                }
                
                let hourValue = 12 - round( angle / Double.pi * 12 )
                self.setHourWithoutCompletion(Int(hourValue))
                
//                self.time = Calendar.current.date(bySetting: .hour, value: Int(hourValue), of: time) ?? self.time
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
                    
//                    Text("\(time.formatted())")
                    
                    makeTimePreview()
                    
                    makeTimeMarker(in: radius)
                    
                    if selectingHour {
                        makeHourLabels(in: radius)
                        
                    } else {
                        makeMinuteLabels(in: radius)
                    }
                }
                .gesture(planeGesture(in: radius))
            }
            
            .border(.red)
            .aspectRatio(2, contentMode: .fit)
            
//            .onChange(of: time) { withAnimation {
//                if time > halfDay { inAM = false }
//                else { inAM = true }
//            } }
            
            Slider(value: timeBinding, in: 0...24)
        }
    }
}

#Preview {
    CactusTimeDial()
}
