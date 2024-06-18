//
//  CactusComponent.swift
//  CactusComponents
//
//  Created by Brian Masse on 6/18/24.
//

import Foundation
import SwiftUI

class CactusComponent: Identifiable {
    let name: String
    let description: String
    
    init( name: String, description: String ) {
        self.name = name
        self.description = description
        self.id = ""
    }
    
    var id: String
    
    @ViewBuilder var preview: AnyView { AnyView( EmptyView() ) }
    
    static func == (lhs: CactusComponent, rhs: CactusComponent) -> Bool {
        lhs.id == rhs.id
    }
}
