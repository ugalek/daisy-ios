//
//  View.swift
//  daisy
//
//  Created by Galina on 31/07/2020.
//  Copyright © 2020 Galina FABIO. All rights reserved.
//

import SwiftUI

#if canImport(UIKit)
extension ViewModifier {
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
#endif
