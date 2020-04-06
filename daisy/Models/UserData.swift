//
//  UserData.swift
//  daisy
//
//  Created by Galina on 02/04/2020.
//  Copyright © 2020 Galina FABIO. All rights reserved.
//

import SwiftUI
import Combine

final class UserData: ObservableObject  {
    @Published var showReservedOnly = false
    @Published var wishes = wishData
}
