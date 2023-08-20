//
//  SwipeActionButtonStyle.swift
//  
//
//  Created by Lorpaves on 2023/8/21.
//

import SwiftUI

/// A style to remove the "press" effect on buttons.
public struct SwipeActionButtonStyle: ButtonStyle {
    @Binding var pressed: Bool
    
    
    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            
            .onChange(of: configuration.isPressed) { newValue in
                self.pressed = newValue
            }
    }
}
