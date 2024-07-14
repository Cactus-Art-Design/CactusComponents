//
//  InteriorGlow.swift
//  CactusComponents
//
//  Created by Brian Masse on 7/13/24.
//

import Foundation
import SwiftUI

struct InteriorGlow: View {
    
    private struct Line: Shape {

        let horizontalAlignment1: Alignment
        let verticalAlignment1: Alignment
        
        let horizontalAlignment2: Alignment
        let verticalAlignment2: Alignment
        
        func path(in rect: CGRect) -> Path {
            Path{ path in
                
                path.move(to: .init(x: horizontalAlignment1 == .leading ? rect.minX : rect.maxX,
                                    y: verticalAlignment1 == .bottom ? rect.maxY : rect.minY))
                
                
                path.addLine(to: .init(x: horizontalAlignment2 == .leading ? rect.minX : rect.maxX,
                                    y: verticalAlignment2 == .bottom ? rect.maxY : rect.minY))
            }
        }
    }
    
    @ViewBuilder
    private func makeLine( horizontalAlignment1: Alignment, verticalAlignment1: Alignment,
                           horizontalAlignment2: Alignment, verticalAlignment2: Alignment,
                           primaryBlur: Double? = nil,
                           secondaryBlur: Double? = nil,
                           lineWidth: Double? = nil,
                           secondarLineWidth: Double? = nil) -> some View {
        
        ZStack {
            
            Line(horizontalAlignment1: horizontalAlignment1, verticalAlignment1: verticalAlignment1,
                 horizontalAlignment2: horizontalAlignment2, verticalAlignment2: verticalAlignment2)
            
            .stroke(lineWidth: lineWidth == nil ? self.lineWidth : lineWidth!)
            .blur(radius: primaryBlur == nil ? self.primaryBlur : primaryBlur!)
            .opacity(0.5)
            
            Line(horizontalAlignment1: horizontalAlignment1, verticalAlignment1: verticalAlignment1,
                 horizontalAlignment2: horizontalAlignment2, verticalAlignment2: verticalAlignment2)
            
            .stroke(lineWidth: secondarLineWidth == nil ? self.secondarLineWidth : secondarLineWidth!)
            .blur(radius: secondaryBlur == nil ? self.secondaryBlur: secondaryBlur!)
        }
        
    }
    
    let primaryBlur: Double = 35
    let secondaryBlur: Double = 10
    
    let lineWidth: Double = 30
    let secondarLineWidth: Double = 10
    
    var body: some View {
        
        let secondaryColor = Color(red: 255/255, green: 240/255, blue: 209/255 )
     
        Rectangle()
            .frame(width: 200, height: 200)
            .opacity(0.1)
        
            .overlay {
                RoundedRectangle(cornerRadius: 15)
                    .stroke(lineWidth: 3)
                
                
                makeLine(horizontalAlignment1: .leading, verticalAlignment1: .bottom,
                         horizontalAlignment2: .leading, verticalAlignment2: .top)
                .foregroundStyle(secondaryColor)
                
                makeLine(horizontalAlignment1: .leading, verticalAlignment1: .top,
                         horizontalAlignment2: .trailing, verticalAlignment2: .top)
                .foregroundStyle(secondaryColor)
                
                makeLine(horizontalAlignment1: .trailing, verticalAlignment1: .bottom,
                         horizontalAlignment2: .trailing, verticalAlignment2: .top)
                
                makeLine(horizontalAlignment1: .trailing, verticalAlignment1: .bottom,
                         horizontalAlignment2: .leading, verticalAlignment2: .bottom)
             
                
                
            }
            .clipShape(RoundedRectangle(cornerRadius: 15))
        
    }
}

#Preview {
    
    InteriorGlow()
    
}
