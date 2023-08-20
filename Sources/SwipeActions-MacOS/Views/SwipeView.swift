//
//  SwipeView.swift
//  
//
//  Created by Lorpaves on 2023/8/21.
//

import SwiftUI
@available(macOS 10.15, *)
public struct SwipeView<L: View, LeadingActions: View, TrailingActions: View>: View {
    // MARK: - Properties
    
    /// Options for configuring the swipe view.
    public var options = SwipePreferences()
    
    @ViewBuilder public var label: () -> L
    @ViewBuilder public var leadingActions: (SwipeContext) -> LeadingActions
    @ViewBuilder public var trailingActions: (SwipeContext) -> TrailingActions
    
    // MARK: - Environment
    
    /// Read the `swipeViewGroupSelection` from the parent `SwipeViewGroup` (if it exists).
    @Environment(\.swipeViewGroupSelection) private var swipeViewGroupSelection
    
    // MARK: - Internal state
    
    /// The ID of the view. Set `options.id` to override this.
    @State private var id = UUID()
    
    /// The size of the parent view.
    @State private var size = CGSize.zero
    
    // MARK: - Actions state
    
    /// The current side that's showing the actions.
    @State private var currentSide: SwipeSide?
    
    /// The `closed/expanded/triggering/triggered/none` state for the leading side.
    @State private var leadingState: SwipeState?
    
    /// The `closed/expanded/triggering/triggered/none` state for the trailing side.
    @State private var trailingState: SwipeState?
    
    /// These properties are set automatically via `SwipeActionsLayout`.
    @State private var numberOfLeadingActions = 0
    @State private var numberOfTrailingActions = 0
    
    /// Enable triggering the leading edge via a drag.
    @State private var swipeToTriggerLeadingEdge = false
    
    /// Enable triggering the trailing edge via a drag.
    @State private var swipeToTriggerTrailingEdge = false
    
    // MARK: - Gesture state
    
    /// When you touch down with a second finger, the drag gesture freezes, but `currentlyDragging` will be accurate.
    @State private var currentlyDragging = false
    
    /// Upon a gesture freeze / cancellation, use this to end the gesture.
    @State private var latestDragGestureValueBackup: SwipeGestureValue?
    
    /// The offset dragged in the current drag session.
    @State private var currentOffset = Double(0)
    
    /// The offset dragged in previous drag sessions.
    @State private var savedOffset = Double(0)
    public var body: some View {
        HStack {
            label()
                .offset(x: offset) /// Apply the offset here.
        }
        .readSize { size = $0 }
        
        .background(
            
            actionsView(side: .leading, state: $leadingState, numberOfActions: $numberOfLeadingActions, actions: { context in
                leadingActions(context)
                    .environment(\.swipeContext, context)
                    .onPreferenceChange(AllowSwipeToTriggerKey.self) { allow in
                        if let allow {
                            swipeToTriggerLeadingEdge = allow
                        }
                    }
            }),
            
            alignment: .leading
        )
        .swipeGesture(isSwiping: $currentlyDragging) { state in
            onChanged(value: state)
        } onEnded: { value in
            onEnded(value: value)
        }
       
        .background(
            
            actionsView(side: .trailing, state: $trailingState, numberOfActions: $numberOfTrailingActions, actions: { context in
                trailingActions(context)
                    .environment(\.swipeContext, context)
                    .onPreferenceChange(AllowSwipeToTriggerKey.self) { allow in
                        if let allow {
                            swipeToTriggerTrailingEdge = allow
                        }
                    }
            }),
            alignment: .trailing
        )
       
        .onChange(of: currentlyDragging) { newValue in
            if !currentlyDragging, let latestDragGestureValueBackup {
                end(value: latestDragGestureValueBackup)
            }
        }
        .onChange(of: leadingState) { newValue in
            if newValue == .closed, swipeViewGroupSelection.wrappedValue == id {
                swipeViewGroupSelection.wrappedValue = nil
            }
        }
        .onChange(of: trailingState) { newValue in
            if newValue == .closed, swipeViewGroupSelection.wrappedValue == id {
                swipeViewGroupSelection.wrappedValue = nil
            }
        }
        .onChange(of: swipeViewGroupSelection.wrappedValue) { newValue in
            if swipeViewGroupSelection.wrappedValue != id {
                currentSide = nil

                if leadingState != .closed {
                    leadingState = .closed
                    close(velocity: 0)
                }

                if trailingState != .closed {
                    trailingState = .closed
                    close(velocity: 0)
                }
            }
        }
    }
}

public extension SwipeView {
    
    @ViewBuilder
    func actionsView<Actions: View>(
        side: SwipeSide,
        state: Binding<SwipeState?>,
        numberOfActions: Binding<Int>,
        @ViewBuilder actions: (SwipeContext) -> Actions
    ) -> some View {
        let draggedLength = offset * Double(side.signWhenDragged)
        let visibleWidth: Double = {
            var width = draggedLength
            width -= options.spacing
            width = max(0, width)
            return width
        }()
        
        let opacity: Double = {
            let offset = max(0, draggedLength - options.actionsVisibleStartPoint)
            
            let percent = offset / (options.actionsVisibleEndPoint - options.actionsVisibleStartPoint)
            
            let opacity = min(1, percent)
            
            return opacity
        }()
        
        _VariadicView.Tree(
            SwipeActionsLayout(
                numberOfActions: numberOfActions,
                side: side,
                options: options,
                state: state.wrappedValue,
                visibleWidth: visibleWidth
            )) {
                let stateBinding = Binding {
                    state.wrappedValue
                } set: { newValue in
                    state.wrappedValue = newValue
                    
                    if newValue == .closed {
                        currentSide = nil /// If closed, set `currentSide` to nil.
                    } else {
                        currentSide = side /// Set the current side to the action's side.
                    }
                    
                    /// Update the visual state to the client's new selection.
                    updateOffset(side: side, to: newValue)
                }
                
                let context = SwipeContext(
                    state: stateBinding,
                    numberOfActions: numberOfActions.wrappedValue,
                    side: side,
                    opacity: opacity,
                    currentlyDragging: currentlyDragging
                )
                
                actions(context) /// Call the `actions` view and pass in context.
            }
            .mask(
                Color.clear.overlay(
                    /// Clip the swipe actions as they're being revealed.
                    RoundedRectangle(cornerRadius: options.actionsMaskCornerRadius, style: .continuous)
                        .frame(width: visibleWidth),
                    alignment: side.alignment
                )
            )
        
    }
}

struct SwipeView_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            
            SwipeView {
                Text("Group 1")
            } leadingActions: { context in
                SwipeAction {
                    print("Tapped")
                } label: { _ in
                    Text("233")
                } background: { highlighted in
                    Color.red
                        .opacity(highlighted ? 0.4 : 1)
                }
                .frame(height: 40)
               

                SwipeAction("233") {
                    print("Tapped")
                }
                
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        

    }
}

// MARK: - State

public extension SwipeView {
    /// Call this after programmatically setting the state to update the view's offset.
    func updateOffset(side: SwipeSide, to state: SwipeState?) {
        guard let state else { return }
        switch state {
        case .closed:
            close(velocity: 0)
        case .expanded:
            expand(side: side, velocity: 0)
        case .triggering:
            break
        case .triggered:
            trigger(side: side, velocity: 0)
        }
    }
    
    func close(velocity: Double) {
        withAnimation(.interpolatingSpring(stiffness: options.offsetTriggerAnimationStiffness, damping: options.offsetTriggerAnimationDamping, initialVelocity: velocity)) {
            savedOffset = 0
            currentOffset = 0
        }
    }
    
    func trigger(side: SwipeSide, velocity: Double) {
        withAnimation(.interpolatingSpring(stiffness: options.offsetTriggerAnimationStiffness, damping: options.offsetTriggerAnimationDamping, initialVelocity: velocity)) {
            switch side {
            case .leading:
                savedOffset = leadingTriggeredOffset
            case .trailing:
                savedOffset = trailingTriggeredOffset
            }
            currentOffset = 0
        }
    }
    
    func expand(side: SwipeSide, velocity: Double) {
        withAnimation(.interpolatingSpring(stiffness: options.offsetExpandAnimationStiffness, damping: options.offsetExpandAnimationDamping, initialVelocity: velocity)) {
            switch side {
            case .leading:
                savedOffset = leadingExpandedOffset
            case .trailing:
                savedOffset = trailingExpandedOffset
            }
            currentOffset = 0
        }
    }
    
}

// MARK: - Gestures

public extension SwipeView {
    func onChanged(value: SwipeGestureValue) {
        /// Back up the value.
        latestDragGestureValueBackup = value
        
        /// Set the current side.
        if currentSide == nil {
            let dx = value.offset.x
            if dx > 0 {
                currentSide = .leading
            } else {
                currentSide = .trailing
            }
            
            /// The gesture just started, so animate the change (in case `swipeMinimumDistance > 0`).
            //            withAnimation(options.swipeMinimumDistanceAnimation) {
            //                change(value: value)
            //            }
        } else {
            change(value: value)
        }
    }
    
    func change(value: SwipeGestureValue) {
        /// The total offset of the swipe view.
        let totalOffset = savedOffset + value.translation.width

        /// Get the disallowed side if it exists.
        let disallowedSide = getDisallowedSide(totalOffset: totalOffset)
        
        /// Apply rubber banding if an empty side is reached, or if a side is disallowed.
        if numberOfLeadingActions == 0 || disallowedSide == .leading, totalOffset > 0 {
            let constrainedExceededOffset = pow(totalOffset, options.stretchRubberBandingPower)
            currentOffset = constrainedExceededOffset - savedOffset
            leadingState = nil
            trailingState = nil
        } else if numberOfTrailingActions == 0 || disallowedSide == .trailing, totalOffset < 0 {
            let constrainedExceededOffset = -pow(-totalOffset, options.stretchRubberBandingPower)
            currentOffset = constrainedExceededOffset - savedOffset
            leadingState = nil
            trailingState = nil
        } else { /// Otherwise, attempt to trigger the swipe actions.
            /// Flag to keep track of whether `currentOffset` was set or not — if `false`, then set to the default of `value.translation.width`.
            var setCurrentOffset = false
            
            if totalOffset > leadingReadyToTriggerOffset {
                setCurrentOffset = true
                if swipeToTriggerLeadingEdge {
                    currentOffset = value.translation.width
                    leadingState = .triggering
                    trailingState = nil
                } else {
                    let exceededOffset = totalOffset - leadingReadyToTriggerOffset
                    let constrainedExceededOffset = pow(exceededOffset, options.stretchRubberBandingPower)
                    let constrainedTotalOffset = leadingReadyToTriggerOffset + constrainedExceededOffset
                    currentOffset = constrainedTotalOffset - savedOffset
                    leadingState = nil
                    trailingState = nil
                }
            }
            
            if totalOffset < trailingReadyToTriggerOffset {
                setCurrentOffset = true
                if swipeToTriggerTrailingEdge {
                    currentOffset = value.translation.width
                    trailingState = .triggering
                    leadingState = nil
                } else {
                    let exceededOffset = totalOffset - trailingReadyToTriggerOffset
                    let constrainedExceededOffset = -pow(-exceededOffset, options.stretchRubberBandingPower)
                    let constrainedTotalOffset = trailingReadyToTriggerOffset + constrainedExceededOffset
                    currentOffset = constrainedTotalOffset - savedOffset
                    leadingState = nil
                    trailingState = nil
                }
            }
            
            /// If the offset wasn't modified already (due to rubber banding), use `value.translation.width` as the default.
            if !setCurrentOffset {
                currentOffset = value.translation.width
                leadingState = nil
                trailingState = nil
            }
        }
    }
    
    func onEnded(value: SwipeGestureValue) {
        latestDragGestureValueBackup = nil
       
        end(value: value)
    }
    
    /// Represents the end of a gesture.
    func end(value: SwipeGestureValue) {
        let totalOffset = value.translation.width
        let totalPredictedOffset = (savedOffset + value.predictTranslation.width) * 0.5
        
        let velocity = value.velocity.dx
        if getDisallowedSide(totalOffset: totalOffset) != nil {
         
            currentSide = nil
            leadingState = .closed
            trailingState = .closed
            close(velocity: velocity)
            return
        }
        
        if trailingState == .triggering {
          
            trailingState = .triggered
            trigger(side: .trailing, velocity: velocity)
        } else if leadingState == .triggering {
          
            leadingState = .triggered
            trigger(side: .leading, velocity: velocity)
        } else {
            if totalPredictedOffset > leadingReadyToExpandOffset, numberOfLeadingActions > 0 {
                leadingState = .expanded
                expand(side: .leading, velocity: velocity)
            
            } else if totalPredictedOffset < trailingReadyToExpandOffset, numberOfTrailingActions > 0 {
                trailingState = .expanded
                expand(side: .trailing, velocity: velocity)
              
            } else {
                currentSide = nil
                leadingState = .closed
                trailingState = .closed
                let draggedPastTrailingSide = totalOffset > 0
                if draggedPastTrailingSide { /// if the finger is on the right of the view, make the velocity negative to return to closed quicker.
                    close(velocity: velocity * -0.1)
                } else {
                    close(velocity: velocity)
                }
            }
        }
    }
}
public extension SwipeView {
    
    /// If `allowSwipeAcross` is disabled, make sure the user can't swipe from one side to the other in a single swipe.
    func getDisallowedSide(totalOffset: Double) -> SwipeSide? {
        guard !options.allowSingleSwipeAcross else { return nil }
        if let currentSide {
            switch currentSide {
            case .leading:
                if totalOffset < 0 {
                    /// Disallow showing trailing actions.
                    return .trailing
                }
            case .trailing:
                if totalOffset > 0 {
                    /// Disallow showing leading actions.
                    return .leading
                }
            }
        }
        return nil
    }
    /// Calculate the total width for actions.
    func actionsWidth(numberOfActions: Int) -> Double {
        let count = Double(numberOfActions)
        let totalWidth = count * options.actionWidth
        let totalSpacing = (count - 1) * options.spacing
        let actionsWidth = totalWidth + totalSpacing
        
        return actionsWidth
    }
    /// The total offset of the content.
    var offset: Double {
        currentOffset + savedOffset
    }
    
    // MARK: - Trailing
    
    var trailingReadyToExpandOffset: Double {
        -options.readyToExpandPadding
    }
    
    var trailingExpandedOffset: Double {
        let expandedOffset = -(actionsWidth(numberOfActions: numberOfTrailingActions) + options.spacing)
        return expandedOffset
    }
    
    var trailingReadyToTriggerOffset: Double {
        var readyToTriggerOffset = trailingExpandedOffset - options.readyToTriggerPadding
        let minimumOffsetToTrigger = -options.minimumPointToTrigger /// Sometimes if there's only one action, the trigger drag distance is too small. This makes sure it's big enough.
        if readyToTriggerOffset > minimumOffsetToTrigger {
            readyToTriggerOffset = minimumOffsetToTrigger
        }
        return readyToTriggerOffset
    }
    
    var trailingTriggeredOffset: Double {
        let triggeredOffset = -(size.width + options.spacing)
        return triggeredOffset
    }
    
    // MARK: - Leading
    
    var leadingReadyToExpandOffset: Double {
        options.readyToExpandPadding
    }
    
    var leadingExpandedOffset: Double {
        let expandedOffset = actionsWidth(numberOfActions: numberOfLeadingActions) + options.spacing
        return expandedOffset
    }
    
    var leadingReadyToTriggerOffset: Double {
        var readyToTriggerOffset = leadingExpandedOffset + options.readyToTriggerPadding
        let minimumOffsetToTrigger = options.minimumPointToTrigger
        
        if readyToTriggerOffset < minimumOffsetToTrigger {
            readyToTriggerOffset = minimumOffsetToTrigger
        }
        return readyToTriggerOffset
    }
    
    var leadingTriggeredOffset: Double {
        let triggeredOffset = size.width + options.spacing
        return triggeredOffset
    }
}






public extension SwipeView {
    /// If swiping is currently enabled.
    func swipeEnabled(_ value: Bool) -> SwipeView {
        var view = self
        view.options.swipeEnabled = value
        return view
    }
    
    /// The minimum distance needed to drag to start the gesture. Should be more than 0 for best compatibility with other gestures/buttons.
    func swipeMinimumDistance(_ value: Double) -> SwipeView {
        var view = self
        view.options.swipeMinimumDistance = value
        return view
    }
    
    /// The style to use (`mask`, `equalWidths`, or `cascade`).
    func swipeActionsStyle(_ value: SwipeActionStyle) -> SwipeView {
        var view = self
        view.options.actionsStyle = value
        return view
    }
    
    /// The corner radius that encompasses all actions.
    func swipeActionsMaskCornerRadius(_ value: Double) -> SwipeView {
        var view = self
        view.options.actionsMaskCornerRadius = value
        return view
    }
    
    /// At what point the actions start becoming visible.
    func swipeActionsVisibleStartPoint(_ value: Double) -> SwipeView {
        var view = self
        view.options.actionsVisibleStartPoint = value
        return view
    }
    
    /// At what point the actions become fully visible.
    func swipeActionsVisibleEndPoint(_ value: Double) -> SwipeView {
        var view = self
        view.options.actionsVisibleEndPoint = value
        return view
    }
    
    /// The corner radius for each action.
    func swipeActionCornerRadius(_ value: Double) -> SwipeView {
        var view = self
        view.options.actionCornerRadius = value
        return view
    }
    
    /// The width for each action.
    func swipeActionWidth(_ value: Double) -> SwipeView {
        var view = self
        view.options.actionWidth = value
        return view
    }
    
    /// Spacing between actions and the label view.
    func swipeSpacing(_ value: Double) -> SwipeView {
        var view = self
        view.options.spacing = value
        return view
    }
    
    /// The point where the user must drag to expand actions.
    func swipeReadyToExpandPadding(_ value: Double) -> SwipeView {
        var view = self
        view.options.readyToExpandPadding = value
        return view
    }
    
    /// The point where the user must drag to enter the `triggering` state.
    func swipeReadyToTriggerPadding(_ value: Double) -> SwipeView {
        var view = self
        view.options.readyToTriggerPadding = value
        return view
    }
    
    /// Ensure that the user must drag a significant amount to trigger the edge action, even if the actions' total width is small.
    func swipeMinimumPointToTrigger(_ value: Double) -> SwipeView {
        var view = self
        view.options.minimumPointToTrigger = value
        return view
    }
    
    /// Applies if `swipeToTriggerLeadingEdge/swipeToTriggerTrailingEdge` is true.
    func swipeEnableTriggerHaptics(_ value: Bool) -> SwipeView {
        var view = self
        view.options.enableTriggerHaptics = value
        return view
    }
    
    /// Applies if `swipeToTriggerLeadingEdge/swipeToTriggerTrailingEdge` is false, or when there's no actions on one side.
    func swipeStretchRubberBandingPower(_ value: Double) -> SwipeView {
        var view = self
        view.options.stretchRubberBandingPower = value
        return view
    }
    
    /// If true, you can change from the leading to the trailing actions in one single swipe.
    func swipeAllowSingleSwipeAcross(_ value: Bool) -> SwipeView {
        var view = self
        view.options.allowSingleSwipeAcross = value
        return view
    }
    
    /// The animation used for adjusting the content's view when it's triggered.
    func swipeActionContentTriggerAnimation(_ value: Animation) -> SwipeView {
        var view = self
        view.options.actionContentTriggerAnimation = value
        return view
    }
    
    /// The animation used at the start of the gesture, after dragging the `swipeMinimumDistance`.
    //    func swipeMinimumDistanceAnimation(_ value: Animation) -> SwipeView {
    //        var view = self
    //        view.options.swipeMinimumDistanceAnimation = value
    //        return view
    //    }
    
    /// Values for controlling the close animation.
    func swipeOffsetCloseAnimation(stiffness: Double, damping: Double) -> SwipeView {
        var view = self
        view.options.offsetCloseAnimationStiffness = stiffness
        view.options.offsetCloseAnimationDamping = damping
        return view
    }
    
    /// Values for controlling the expand animation.
    func swipeOffsetExpandAnimation(stiffness: Double, damping: Double) -> SwipeView {
        var view = self
        view.options.offsetExpandAnimationStiffness = stiffness
        view.options.offsetExpandAnimationDamping = damping
        return view
    }
    
    /// Values for controlling the trigger animation.
    func swipeOffsetTriggerAnimation(stiffness: Double, damping: Double) -> SwipeView {
        var view = self
        view.options.offsetTriggerAnimationStiffness = stiffness
        view.options.offsetTriggerAnimationDamping = damping
        return view
    }
}



/// A `SwipeView` with leading actions only.
public extension SwipeView where TrailingActions == EmptyView {
    init(
        @ViewBuilder label: @escaping () -> L,
        @ViewBuilder leadingActions: @escaping (SwipeContext) -> LeadingActions
    ) {
        self.init(label: label, leadingActions: leadingActions) { _ in }
    }
}

/// A `SwipeView` with trailing actions only.
public extension SwipeView where LeadingActions == EmptyView {
    init(
        @ViewBuilder label: @escaping () -> L,
        @ViewBuilder trailingActions: @escaping (SwipeContext) -> TrailingActions
    ) {
        self.init(label: label, leadingActions: { _ in }, trailingActions: trailingActions)
    }
}

/// A `SwipeView` with no actions.
public extension SwipeView where LeadingActions == EmptyView, TrailingActions == EmptyView {
    init(@ViewBuilder label: @escaping () -> L) {
        self.init(label: label) { _ in } trailingActions: { _ in }
    }
}
