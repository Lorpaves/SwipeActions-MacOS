//
//  SwipeActionStyle.swift
//  
//
//  Created by Lorpaves on 2023/8/20.
//

import Foundation

/// The style to reveal actions.
public enum SwipeActionStyle {
    /// Fully render actions, but reveal them using a mask.
    case mask

    /// All actions have equal widths, taking up all available space together.
    case equalWidths

    /// A "overlapping" style.
    case cascade
}
