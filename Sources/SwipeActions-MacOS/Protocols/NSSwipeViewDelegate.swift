//
//  NSSwipeViewDelegate.swift
//  
//
//  Created by Lorpaves on 2023/8/21.
//


import AppKit

public protocol NSSwipeViewDelegate: AnyObject {
    
    func updating(_ state: SwipeGestureValue)
    
}

