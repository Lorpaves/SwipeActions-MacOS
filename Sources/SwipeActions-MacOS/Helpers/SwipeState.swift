//
//  SwipeState.swift
//  ColorStore
//
//  Created by Lorpaves on 2023/8/20.
//

import Foundation

public enum SwipeState {
    /// The default state.
    case closed
    
    /// All actions are shown.
    case expanded
    
    /// The last action is highlighted. Only applies if `swipeToTriggerLeadingEdge` / `swipeToTriggerTrailingEdge` are true.
    case triggering
    
    /// The last action is highlighted and fills the whole row. Only applies if `swipeToTriggerLeadingEdge` / `swipeToTriggerTrailingEdge` are true.
    case triggered
}
