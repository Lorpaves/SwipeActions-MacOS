//
//  EnvironmentKeys.swift
//  
//
//  Created by Lorpaves on 2023/8/21.
//

import SwiftUI
// MARK: - EnvironmentKeys

public struct SwipeViewGroupSelectionKey: EnvironmentKey {
    public static let defaultValue: Binding<UUID?> = .constant(nil)
}


public struct SwipeContextKey: EnvironmentKey {
    public static let defaultValue = SwipeContext(state: .constant(nil), side: .leading)
}
