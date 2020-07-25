//
//  ListFields.swift
//  daisy
//
//  Created by Galina on 24/07/2020.
//  Copyright © 2020 Galina FABIO. All rights reserved.
//

import SwiftUI
import Combine

class ListFields: ObservableObject, Codable {
    enum CodingKeys: String, CodingKey {
        case title
    }
    
    let objectWillChange = PassthroughSubject<Void, Never>()
    
    var title: String = "" {
        didSet {
            self.titleIsValid = Validators.titleIsValid(title: self.title)
            update()
        }
    }
    var image: Image? = nil { didSet { update() } }
    var surprise: Bool = false { didSet { update() } }
    var titleIsValid: Bool = true { didSet { update() } }
    
    var isValid: Bool {
        if title.isEmpty || !titleIsValid {
            return false
        }
        return true
    }
    
    func update() {
        objectWillChange.send(())
    }
}
