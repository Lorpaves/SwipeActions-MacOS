//
//  View.swift
//  
//
//  Created by Lorpaves on 2023/8/21.
//

import SwiftUI

public extension View {
    func readSize(size: @escaping (CGSize) -> Void) -> some View {
        background(
            GeometryReader { geometry in
                Color.clear
                    .preference(key: ContentSizeReaderPreferenceKey.self, value: geometry.size)
                    .onPreferenceChange(ContentSizeReaderPreferenceKey.self) { newSize in
                        size(newSize)
                    }
            }
        
        )
        
    }
    func swipeGesture(
        isSwiping: Binding<Bool>,
        onChanged: @escaping (SwipeGestureValue) -> Void,
        onEnded: @escaping (SwipeGestureValue) -> Void
    ) -> some View {
        modifier(SwipeViewModifier(isSwiping: isSwiping, onChanged: onChanged, onEnded: onEnded))
    }
   
}

public extension AnyTransition {
    /// Transition that mimics iOS's default delete transition (clipped to the top).
    static var swipeDelete: AnyTransition {
        .modifier(
            active: SwipeDeleteModifier(visibility: 0),
            identity: SwipeDeleteModifier(visibility: 1)
        )
    }
}

/// Modifier for a clipped delete transition effect.
public struct SwipeDeleteModifier: ViewModifier {
    var visibility: Double
    
    public func body(content: Content) -> some View {
        content
            .mask(
                Color.clear.overlay(
                    SwipeDeleteMaskShape(animatableData: visibility)
                        .padding(.horizontal, -100) /// Prevent horizontal clipping
                        .padding(.vertical, -10), /// Prevent vertical clipping
                    alignment: .top
                )
            )
    }
}
