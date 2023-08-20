//
//  SwipeContext.swift
//  ColorStore
//
//  Created by Lorpaves on 2023/8/20.
//

import SwiftUI

public struct SwipeContext {
    /// The current state.
    public var state: Binding<SwipeState?>

    /// How many actions are provided.
    public var numberOfActions = 0

    /// The side that this context applies to.
    public var side: SwipeSide

    /// The opacity of the swipe actions, determined by `actionsVisibleStartPoint` and `actionsVisibleEndPoint`.
    public var opacity: Double = 0

    /// If the user is swiping or not.
    public var currentlyDragging = false
}


