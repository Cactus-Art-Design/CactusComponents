//
//  TicketShape.swift
//  CactusComponents
//
//  Created by Brian Masse on 6/18/24.
//

import Foundation
import SwiftUI

//MARK: Line
@available(iOS 15.0, *)
struct Line: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        path.move(to: .init(x: rect.minX, y: rect.midY))
        path.addLine(to: .init(x: rect.maxX, y: rect.midY))
        
        return path
    }
}

//MARK: Ticket Shape
@available(iOS 15.0, *)
struct TicketShape: Shape {
//    MARK: Corners
    static func Corner(in rect: CGRect) -> Path {
        let inset = TicketView.ticketCornerInset
        var path = Path()
        
        path.move(to: .init(x: rect.maxX - inset, y: rect.maxY))
        
        path.addLine(to: .init(x: rect.maxX - inset, y: rect.minY + inset))
        path.addLine(to: .init(x: rect.minX, y: rect.minY + inset))
        path.addLine(to: .init(x: rect.minX, y: rect.maxY))
        
        return path
    }
    
    static func InvertedRoundedCorner( in rect: CGRect ) -> Path {
        var path = Path()
        
        path.move(to: .init(x: rect.maxX, y: rect.minY))
        path.addArc(center: .init(x: rect.maxX, y: rect.minY),
                    radius: rect.height,
                    startAngle: .init(degrees: 180),
                    endAngle: .init(degrees: 90), clockwise: true)
        
        return path
    }

    var corner: ( CGRect ) -> Path
    
    init(  corner: @escaping (CGRect) -> Path ) {
        self.corner = corner
    }
    
//    MARK: Body
//    this creates the notches 80% down the card
    private func makeTicketStub(in rect: CGRect) -> Path {
        var path = Path()
        
        
        path.addArc(center: .init(x: rect.maxX, y: rect.minY + rect.height * TicketView.ticketStubHeight),
                    radius: TicketView.ticketCornerRadius,
                    startAngle: .degrees(-90), endAngle: .degrees(90),
                    clockwise: true)
        
        path.move(to: .init(x: rect.minX, y: rect.minY + rect.height * TicketView.ticketStubHeight))
        path.addArc(center: .init(x: rect.minX, y: rect.minY + rect.height * TicketView.ticketStubHeight),
                    radius: TicketView.ticketCornerRadius,
                    startAngle: .degrees(90), endAngle: .degrees(-90),
                    clockwise: true)
        
        return path
    }
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        
        let inset = TicketView.ticketCornerInset
        let radius = TicketView.ticketCornerRadius
        
        let xOffsets: [Double] = [ -1, 0, 0, -1 ]
        let yOffsets: [Double] = [ 0, 0, -1, -1 ]
        
        for i in 0..<4 {
            let baseX = xOffsets[i] == 0 ? rect.minX : rect.maxX
            let baseY = yOffsets[i] == 0 ? rect.minY : rect.maxY
            
            let cornerRect = CGRect(x: baseX + (xOffsets[i] * ( radius + inset )),
                                    y: baseY + (yOffsets[i] * ( radius + inset )),
                                    width: radius + inset,
                                    height: radius + inset)
            
            let rotation: Double = -90 * Double(i)
            let corner = self.corner( cornerRect )
                .rotation(.degrees(rotation)).path(in: cornerRect)
            
            path.addPath(corner)
        }
        
//        mark body
        let body = CGRect(x: rect.minX, y: rect.minY,
                          width: rect.width, height: rect.height)
        
        path.addRect(body)
        
//        mark ticket stub
        let stubs = makeTicketStub(in: rect)
        path.addPath(stubs)
        
        return path
    }
}
