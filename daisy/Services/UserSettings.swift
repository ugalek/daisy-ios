//
//  UserData.swift
//  daisy
//
//  Created by Galina on 02/04/2020.
//  Copyright © 2020 Galina FABIO. All rights reserved.
//

import SwiftUI
import Combine

final class UserSettings: ObservableObject {    
    let objectWillChange = PassthroughSubject<Void, Never>()
    
    @Published var showReservedOnly = false   
}

