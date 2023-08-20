//
//  SwipeSide.swift
//  
//
//  Created by Lorpaves on 2023/8/20.
//

import SwiftUI

public enum SwipeSide {
    case leading, trailing
    
    public var alignment: Alignment {
        switch self {
        case .leading:
            return .leading
        case .trailing:
            return .trailing
        }
    }
    /// Used when there's only one action.
    public var edgeTriggerAlignment: Alignment {
        switch self {
        case .leading:
            return .trailing
        case .trailing:
            return .leading
        }
    }
    
    /// When leading actions are shown, the offset is positive. It's the opposite for trailing actions.
    public var signWhenDragged: Int {
        switch self {
        case .leading:
            return 1
        case .trailing:
            return -1
        }
    }
}
