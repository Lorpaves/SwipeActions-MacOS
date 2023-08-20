//
//  NSSwipeView.swift
//  
//
//  Created by Lorpaves on 2023/8/21.
//

import AppKit


private protocol NSSwipeViewProtocol: AnyObject {
    
    var swipeDelegate: NSSwipeViewDelegate? { get set }
    
    var scrollMultiplier: CGFloat { get set }
    
    var lastScrollTimestamp: TimeInterval? { get set }
    
    var startScrollTimestamp: TimeInterval? { get set }
    
    var swipeState: SwipeGestureValue { get set }
    
    var lastScrollDeltaX: CGFloat { get set }
    
    var lastScrollDeltaY: CGFloat { get set }
    
    func scrollWheel(with event: NSEvent)
    
    func calculateScrollMultiplier(_ event: NSEvent) -> CGFloat
    
}

private extension NSSwipeViewProtocol where Self: NSView {
    
    func calculateScrollMultiplier(_ event: NSEvent) -> CGFloat {
        guard let lastTimestamp = lastScrollTimestamp else {
            return 1
        }
        
        let currentTime = event.timestamp
        let deltaTime = currentTime - lastTimestamp
        lastScrollTimestamp = currentTime
        
        let momentumPhase = max(0, event.phase.rawValue) // 动量滚动阶取段最大值，确保非负数
        
        if momentumPhase > 0 {
            return (deltaTime * CGFloat(momentumPhase)).squareRoot() // 使用平方根作为乘数
        } else {
            return 1 // 如果没有动量滚动者或动量滚动结束，乘数为1.0
        }
    }
}


private extension NSSwipeViewProtocol where Self: NSView {
    
    func _scrollWheel(with event: NSEvent) {
        
        guard event.phase == .changed || event.phase == .ended else {
            return
        }
        
        if event.phase == .changed {
            self.window?.makeFirstResponder(nil)
            guard startScrollTimestamp != nil, lastScrollTimestamp != nil else {
                lastScrollTimestamp = event.timestamp
                startScrollTimestamp = event.timestamp
                return
            }
            
            
        } else if event.phase == .ended {
            swipeDelegate?.updating(self.swipeState)
            scrollMultiplier = 1 // 重置乘数为1.0
            
            
        }
        
        let currentTime = event.timestamp
        
        let deltaY = event.scrollingDeltaY
        let deltaX = event.scrollingDeltaX
        let scrollXLength = deltaX * scrollMultiplier
        let scrollYLength = deltaY * scrollMultiplier
        let offset = Offset(x: scrollXLength, y: scrollYLength)
        var size = self.swipeState.translation
        
        size += CGSize(width: scrollXLength, height: scrollYLength)
        
        self.swipeState.offset = offset
        self.swipeState.phase = event.phase
        self.swipeState.translation = size
        
        let duration: CGFloat
        if let lastScrollTimestamp = lastScrollTimestamp {
            duration = currentTime - lastScrollTimestamp
            
        } else {
            duration = 1
        }
        
        let dx: CGFloat
        let dy: CGFloat
        if lastScrollDeltaX == 0 {
            dx = deltaX
        } else {
            dx = deltaX - lastScrollDeltaX
        }
        if lastScrollDeltaY == 0 {
            dy = deltaY
        } else {
            dy = deltaY - lastScrollDeltaY
        }
        
        let velocity = CGVector(dx: abs(dx / duration).squareRoot(), dy: abs(dy / duration).squareRoot())
        
        self.swipeState.predictTranslation = CGSize(width: size.width + velocity.dx / 2 , height: size.height + velocity.dy / 2)
        if velocity != .zero {
            swipeState.velocity = velocity
        }
        
        scrollMultiplier = calculateScrollMultiplier(event)
        lastScrollTimestamp = currentTime
        swipeDelegate?.updating(self.swipeState)
        if event.phase == .ended {
            self.swipeState = .init()
            startScrollTimestamp = nil
            lastScrollTimestamp = nil
        }
    }
}

import SwiftUI

private class NSSwipeHostingView<Content: View>: NSView, NSSwipeViewProtocol {
    
    internal var startScrollTimestamp: TimeInterval? = nil
    
    weak var swipeDelegate: NSSwipeViewDelegate?
    
    internal var scrollMultiplier: CGFloat = 0.2
    
    internal var lastScrollDeltaX: CGFloat = 0
    
    internal var lastScrollDeltaY: CGFloat = 0
    
    internal var lastScrollTimestamp: TimeInterval? = nil
    
    internal var swipeState: SwipeGestureValue = .init(offset: .zero, phase: .ended, translation: .zero)
    
    var hostingView: NSHostingView<Content>
    
    required init(rootView: Content) {
        hostingView = NSHostingView(rootView: rootView)
        
        super.init(frame: .zero)
        
        self.addSubview(hostingView)
        
        hostingView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            hostingView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            hostingView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            hostingView.topAnchor.constraint(equalTo: self.topAnchor),
            hostingView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            
        ])
    }
    
    @objc required dynamic init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func scrollWheel(with event: NSEvent) {
        self._scrollWheel(with: event)
        
    }
    
}

private struct NSSwipeViewRepresentable<Content: View>: NSViewRepresentable {
    
    @Binding var isSwiping: Bool
    @ViewBuilder var content: Content
    
    var onChanged: (SwipeGestureValue) -> Void
    var onEnded: (SwipeGestureValue) -> Void
    
    internal func makeNSView(context: Context) -> NSSwipeHostingView<Content> {
        let hostingView = NSSwipeHostingView(rootView: content)
        hostingView.swipeDelegate = context.coordinator
        return hostingView
    }
    
    internal func updateNSView(_ nsView: NSSwipeHostingView<Content>, context: Context) {
        
        nsView.hostingView.rootView = content
        
        context.coordinator.parent = self
    }
    
    func makeCoordinator() -> Coordinator<Content> {
        Coordinator(self)
    }
    
    class Coordinator<Content: View>: NSObject, NSSwipeViewDelegate {
        
        
        var parent: NSSwipeViewRepresentable<Content>
        init(_ parent: NSSwipeViewRepresentable<Content>) {
            self.parent = parent
        }
        
        func updating(_ state: SwipeGestureValue) {
            switch state.phase {
                
            case .changed:
                DispatchQueue.main.async {
                    withAnimation(.spring()) {
                        if !self.parent.isSwiping { self.parent.isSwiping = true }
                        self.parent.onChanged(state)
                    }
                }
                
            case .ended:
                DispatchQueue.main.async {
                    withAnimation(.spring()) {
                        
                        self.parent.onEnded(state)
                        self.parent.isSwiping = false
                    }
                    
                }
                
            default: break
                
            }
        }
        
    }
    
    
}

struct SwipeViewModifier: ViewModifier {
    
    @Binding var isSwiping: Bool
    
    var onChanged: (SwipeGestureValue) -> Void
    
    var onEnded: (SwipeGestureValue) -> Void
    
    func body(content: Content) -> some View {
        
        NSSwipeViewRepresentable(isSwiping: $isSwiping) {
            content
        } onChanged: { value in
            onChanged(value)
        } onEnded: { value in
            onEnded(value)
        }
        
        
    }
}
