//
//  CactusComponent.swift
//  CactusComponents
//
//  Created by Brian Masse on 6/18/24.
//

import Foundation
import SwiftUI

@available(iOS 15.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
public class CactusComponent: Identifiable {
    public let name: String
    public let description: String
    
    required init( ) {
        self.name = ""
        self.description = ""
        self.id = UUID().uuidString
        self.preview = { _ in AnyView(EmptyView()) }
    }
    
    public init( name: String, description: String, @ViewBuilder previewBuilder: @escaping () -> some View ) {
        self.name = name
        self.description = description
        self.id = UUID().uuidString
        
        @ViewBuilder
        func preview(_ allowsHitTesting: Bool = true) -> AnyView {
            AnyView(
                previewBuilder()
                    .allowsHitTesting(allowsHitTesting)
            )
        }
        
        self.preview = preview
        
    }
    
    public var id: String
    public var preview: (Bool) -> AnyView
    
    static func == (lhs: CactusComponent, rhs: CactusComponent) -> Bool {
        lhs.id == rhs.id
    }
}

extension CactusComponent: SingleInstance {
    public static var shared: Self {
        self.init()
    }
}

public protocol SingleInstance {
    static var shared: Self {get}
}
