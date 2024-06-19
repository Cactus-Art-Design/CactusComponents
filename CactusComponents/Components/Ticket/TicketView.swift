//
//  ContentView.swift
//  TicketDemo
//
//  Created by Brian Masse on 6/17/24.
//

import SwiftUI

//MARK: Component Conformance
@available(iOS 15.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
public final class TicketComponent: CactusComponent, SingleInstance {
    private init() {
        super.init(name: "Ticket Demo",
                   description: "This is a styled and interactable Museum Ticket") {
            TicketViewPreview()
        }
    }
    
    public static var shared: TicketComponent = TicketComponent()
}

@available(iOS 15.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
internal struct TicketViewPreview: View {
    var body: some View {
        
        let ticket = Ticket(title: "Full Access BMFA",
                            description: "This ticket gives access to all the exhibitis at the MFA",
                            name: "Brian Masse",
                            phoneNumber: "(781) 315 3811",
                            date: .now,
                            price: "9.99")
        
        TicketView(ticket: ticket)
    }
}

//MARK: Ticket
@available(iOS 15.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
internal struct Ticket {
    let id: String = UUID().uuidString
    
    let title: String
    let description: String
    
    let name: String
    let phoneNumber: String
    
    let image: String = "painting"
    
    let date: Date
    let price: String
    
    public init(title: String, description: String, name: String, phoneNumber: String, date: Date, price: String) {
        self.title = title
        self.description = description
        self.name = name
        self.phoneNumber = phoneNumber
        self.date = date
        self.price = price
    }
}

//MARK: TicketView
@available(iOS 15.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
internal struct TicketView: View {
//    the position of where the ticket should be 'seperable' into the ticket stub
//    normalized from the top
    static let ticketStubHeight: CGFloat = 0.75
    static let ticketImageHeight: CGFloat = 200
    
    static let ticketCornerInset: CGFloat = 0
    static let ticketCornerRadius: CGFloat = 20
    
    static let lightColor: Color = .init(red: 252/255, green: 251/255, blue: 245/255)
    
    let ticket: Ticket
    
    private func formatDate() -> String {
        "\(ticket.date.formatted(date: .abbreviated, time: .omitted))\n \(ticket.date.formatted(date: .omitted, time: .shortened))"
    }
    
//    MARK: ViewBuilders
    @ViewBuilder
    private func makeCutLine() -> some View {
        VStack(spacing: 5) {
            Spacer()
            Rectangle()
                .stroke(style: .init(lineWidth: 1, lineCap: .round, dash: [3, 5]))
                .frame(height: 1)
                .padding(.horizontal)
            
            Line()
                .stroke(style: .init(lineWidth: 3, lineCap: .round, dash: [10, 10] ))
                .frame(height: 1)
                .opacity(0.3)
                .padding(.horizontal)
            
            Spacer()
        }
    }
    
    
    @ViewBuilder
    private func makeTopContent(fullContent: Bool = true) -> some View {
        VStack {
            HStack(spacing: 10) {
                Group {
                    Text( ticket.id )
                        .font(.footnote)
                        .frame(width: 7)
                    
                    Rectangle()
                        .frame(width: 3)
                }.padding(.bottom, 30)
                
                VStack(alignment: .leading) {
                    Text( ticket.title )
                        .textCase(.uppercase)
                        .font(.title)
//                        .bold()
                    
                    Text( ticket.description )
                        .padding(.bottom, 15)
                    
                    Text( formatDate() )
//                        .bold()
                        .font(.caption)
                    Spacer()
                }
            }
            Spacer()
            
            if fullContent {
                HStack {
                    VStack(alignment: .leading) {
                        Text( ticket.name )
//                            .bold()
                        Text( ticket.phoneNumber )
                    }
                    
                    Spacer()
                    
                    Text( "$\(ticket.price)" )
                        .font(.headline)
//                        .bold()
                }
            }
        }
        .padding( .top, TicketView.ticketCornerRadius + 10 )
        .padding( .horizontal, TicketView.ticketCornerRadius )
    }
    
    @ViewBuilder
    private func makeTicketImage() -> some View {
        ZStack {
            Image( ticket.image )
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(height: TicketView.ticketImageHeight)
        }
    }
    
    internal init(ticket: Ticket) {
        self.ticket = ticket
    }
    
//    MARK: Body
    public var body: some View {
        GeometryReader { geo in
            ZStack {
                TicketView.lightColor
                
                Image(ticket.image)
                    .resizable()
                    .blur(radius: 60)
                    .opacity(0.2)
                    .clipped()
                
                VStack(spacing: 0) {
                    makeTopContent()
                        .padding(.bottom)
                        .frame(height: geo.size.height * TicketView.ticketStubHeight
                               - TicketView.ticketImageHeight
                               - TicketView.ticketCornerRadius )
                    
                    makeTicketImage()
                    
                    makeCutLine()
                        .frame(height: TicketView.ticketCornerRadius * 2)
                    
                    makeTopContent(fullContent: false)
                }
                .foregroundStyle(.black)
            }
        }
        .aspectRatio(17/40, contentMode: .fit)
        .overlay {
            TicketShape(corner: TicketShape.InvertedRoundedCorner)
                .stroke(lineWidth: 1)
                .opacity(0.5)
        }
        .clipShape(TicketShape( corner: TicketShape.InvertedRoundedCorner ))
//        .shadow(color: .black.opacity(0.2), radius: 15, x: 0, y: 10)
        .padding()
    }
}
