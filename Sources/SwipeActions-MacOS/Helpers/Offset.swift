//
//  Offset.swift
//  
//
//  Created by Lorpaves on 2023/8/21.
//

import Foundation

public struct Offset {
    let x: CGFloat
    let y: CGFloat
}

public extension Offset {
    static let zero = Offset(x: 0, y: 0)
}
