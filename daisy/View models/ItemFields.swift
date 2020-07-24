//
//  ItemFields.swift
//  daisy
//
//  Created by Galina on 20/07/2020.
//  Copyright © 2020 Galina FABIO. All rights reserved.
//

import SwiftUI
import Combine

class ItemFields: ObservableObject, Codable {
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
    
    var url: String = "http://ugalek.com" { didSet { update() } }
    var price: String = "" {
        didSet {
            if let value = price.double {
                if value.fractionalDigits > 2 {
                    price = oldValue
                }
            } else {
                price = oldValue
            }
            update()
        }
    }
    var description: String = "Description  dshjhgf sdgf hdgs sjhfdg sdhf jhsdg fhj gsdhfg hsdg fhdgsfhdshfg hdsgf  dgsfhgsdf" { didSet { update() } }
    var titleIsValid: Bool = true { didSet { update() } }
    
    var isValid: Bool {
        if title.isEmpty || url.isEmpty || !titleIsValid {
            return false
        }
        return true
    }
    
    func update() {
        objectWillChange.send(())
    }
}
