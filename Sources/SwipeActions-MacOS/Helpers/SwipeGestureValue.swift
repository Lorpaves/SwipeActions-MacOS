//
//  SwipeGestureValue.swift
//  
//
//  Created by Lorpaves on 2023/8/21.
//

import AppKit

public struct SwipeGestureValue {
    public var offset: Offset = .zero
    public var phase: NSEvent.Phase = .ended
    public var translation: CGSize = .zero
    public var predictTranslation: CGSize = .zero
    public var velocity: CGVector = .zero
}
