//
//  DaisyUI.swift
//  daisy
//
//  Created by Galina on 16/06/2020.
//  Copyright © 2020 Galina FABIO. All rights reserved.
//

import SwiftUI

// From https://stackoverflow.com/questions/56491386/how-to-hide-keyboard-when-using-swiftui
struct DismissingKeyboardOnSwipe: ViewModifier {
    func body(content: Content) -> some View {
        #if os(macOS)
        return content
        #else
        return content.gesture(swipeGesture)
        #endif
    }
    
    private var swipeGesture: some Gesture {
        DragGesture(minimumDistance: 10, coordinateSpace: .global)
            .onChanged(endEditing)
    }
    
    private func endEditing(_ gesture: DragGesture.Value) {
        UIApplication.shared.connectedScenes
            .filter {$0.activationState == .foregroundActive}
            .map {$0 as? UIWindowScene}
            .compactMap({$0})
            .first?.windows
            .filter {$0.isKeyWindow}
            .first?.endEditing(true)
    }
}

struct DismissingKeyboardOnTapGesture: ViewModifier {
    func body(content: Content) -> some View {
        #if os(macOS)
        return content
        #else
        return content.gesture(tapGesture)
        #endif
    }
    
    private var tapGesture: some Gesture {
        TapGesture().onEnded(self.hideKeyboard)
    }
}
