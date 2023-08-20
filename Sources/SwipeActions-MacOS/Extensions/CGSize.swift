//
//  CGSize.swift
//  
//
//  Created by Lorpaves on 2023/8/21.
//

import Foundation

public extension CGSize {
    
    static func += (a: inout Self, b: Self) {
        a.width += b.width
        a.height += b.height
    }
    
}
