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
    
    @UserDefault("apiLink", defaultValue: "/")
    public var apiLink: String {
        willSet {
            objectWillChange.send()
        }
    }
    
    @UserDefault("token", defaultValue: "")
    public var token: String {
        willSet {
            objectWillChange.send()
        }
    }
}

@propertyWrapper
public struct UserDefault<T> {
    let key: String
    let defaultValue: T
    
    init(_ key: String, defaultValue: T) {
        self.key = key
        self.defaultValue = defaultValue
    }
    
    public var wrappedValue: T {
        get {
            return UserDefaults.standard.object(forKey: key) as? T ?? defaultValue
        }
        set {
            UserDefaults.standard.set(newValue, forKey: key)
        }
    }
}
