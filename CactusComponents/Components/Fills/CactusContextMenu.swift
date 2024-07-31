//
//  CactusContextMenu.swift
//  CactusComponents
//
//  Created by Brian Masse on 7/31/24.
//

import Foundation
import SwiftUI

struct CactusContextMenu<C: View>: View {
    
    @ViewBuilder let contentBuilder: () -> C
    
    
    var body: some View {
        
        HStack {
            contentBuilder()
                .background(.red)
                .overlay {
                    Text(  )
                }
        }
        
//        Text("hi")
//             
//        Menu("test") {
//            Button("1") { }
//            
//            Button("2") { }
//            
//            Button("3") { }
//        }
        
    }
    
}


struct CactusContextMenuDemoView: View {
    
    var body: some View {
        
        CactusContextMenu {
            Text("hello!")
            Text("hello!")
            Text("hello!")
            Text("hello!")
            
        }
    }
    
}

#Preview {
    CactusContextMenuDemoView()
}
