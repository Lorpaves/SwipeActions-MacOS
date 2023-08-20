//
//  PreferenceKeys.swift
//  
//
//  Created by Lorpaves on 2023/8/21.
//

import SwiftUI

public struct ContentSizeReaderPreferenceKey: PreferenceKey {
    public static var defaultValue: CGSize { return CGSize() }
    public static func reduce(value: inout CGSize, nextValue: () -> CGSize) { value = nextValue() }
}

public struct AllowSwipeToTriggerKey: PreferenceKey {
    public static var defaultValue: Bool? = nil
    public static func reduce(value: inout Bool?, nextValue: () -> Bool?) { value = nextValue() }
}
