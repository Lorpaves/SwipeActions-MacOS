//
//  SwipePreferences.swift
//  
//
//  Created by Lorpaves on 2023/8/20.
//

import SwiftUI

/// Options for configuring the swipe view.
public struct SwipePreferences {
    /// If swiping is currently enabled.
    var swipeEnabled = true

    /// The minimum distance needed to drag to start the gesture. Should be more than 0 for best compatibility with other gestures/buttons.
    var swipeMinimumDistance: Double = 2

    /// The style to use (`mask`, `equalWidths`, or `cascade`).
    var actionsStyle:SwipeActionStyle = .mask

    /// The corner radius that encompasses all actions.
    var actionsMaskCornerRadius: Double = 10

    /// At what point the actions start becoming visible.
    var actionsVisibleStartPoint: Double = 0

    /// At what point the actions become fully visible.
    var actionsVisibleEndPoint: Double = 50

    /// The corner radius for each action.
    var actionCornerRadius: Double = 10

    /// The width for each action.
    var actionWidth: Double = 50

    /// Spacing between actions and the label view.
    var spacing: Double = 8

    /// The point where the user must drag to expand actions.
    var readyToExpandPadding: Double = 15

    /// The point where the user must drag to enter the `triggering` state.
    var readyToTriggerPadding: Double = 10

    /// Ensure that the user must drag a significant amount to trigger the edge action, even if the actions' total width is small.
    var minimumPointToTrigger: Double = 200

    /// Applies if `swipeToTriggerLeadingEdge/swipeToTriggerTrailingEdge` is true.
    var enableTriggerHaptics: Bool = true

    /// Applies if `swipeToTriggerLeadingEdge/swipeToTriggerTrailingEdge` is false, or when there's no actions on one side.
    var stretchRubberBandingPower: Double = 0.7

    /// If true, you can change from the leading to the trailing actions in one single swipe.
    var allowSingleSwipeAcross: Bool = false

    /// The animation used for adjusting the content's view when it's triggered.
    var actionContentTriggerAnimation: Animation = .spring()

    /// The animation used at the start of the gesture, after dragging the `swipeMinimumDistance`.
//    var swipeMinimumDistanceAnimation = Animation.spring(response: 0.3, dampingFraction: 1, blendDuration: 1)
//    var asd = ""

    /// Values for controlling the close animation.
    var offsetCloseAnimationStiffness: Double = 160, offsetCloseAnimationDamping: Double = 160

    /// Values for controlling the expand animation.
    var offsetExpandAnimationStiffness: Double = 160, offsetExpandAnimationDamping: Double = 160

    /// Values for controlling the trigger animation.
    var offsetTriggerAnimationStiffness: Double = 160, offsetTriggerAnimationDamping: Double = 160
}

