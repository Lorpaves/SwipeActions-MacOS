//
//  SwipeDeleteMaskShape.swift
//  
//
//  Created by Lorpaves on 2023/8/21.
//

import SwiftUI

/// Custom shape that changes height as `animatableData` changes.
public struct SwipeDeleteMaskShape: Shape {
    public var animatableData: Double
    
    public func path(in rect: CGRect) -> Path {
        var maskRect = rect
        maskRect.size.height = rect.size.height * animatableData
        return Path(maskRect)
    }
}
