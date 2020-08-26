//
//  UserFields.swift
//  daisy
//
//  Created by Galina on 02/08/2020.
//  Copyright © 2020 Galina FABIO. All rights reserved.
//

import SwiftUI
import Combine

class UserFields: ObservableObject, Codable {
    enum CodingKeys: String, CodingKey {
        case name
    }
    
    let objectWillChange = PassthroughSubject<Void, Never>()
    
    var name: String = "" {
        didSet {
            self.nameIsValid = Validators.nameIsValid(name: self.name)
            update()
        }
    }
    
    var birthdayDate: Date = Date() { didSet { update() } }
    
    var email: String = "" {
        didSet {
            self.emailIsValid = Validators.emailIsValid(email: self.email)
            update()
        }
    }
    var image: Image? = nil { didSet { update() } }
    
    var nameIsValid: Bool = true { didSet { update() } }
    var emailIsValid: Bool = true { didSet { update() } }
    
    var isValid: Bool {
        if name.isEmpty && !emailIsValid && !nameIsValid {
            return false
        }
        return true
    }
    
    func update() {
        objectWillChange.send(())
    }
}
