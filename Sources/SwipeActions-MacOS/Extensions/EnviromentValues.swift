//
//  EnviromentValues.swift
//  
//
//  Created by Lorpaves on 2023/8/20.
//

import SwiftUI

public extension EnvironmentValues {
   var swipeContext: SwipeContext {
       get { self[SwipeContextKey.self] }
       set { self[SwipeContextKey.self] = newValue }
   }

   var swipeViewGroupSelection: Binding<UUID?> {
       get { self[SwipeViewGroupSelectionKey.self] }
       set { self[SwipeViewGroupSelectionKey.self] = newValue }
   }
}
