//
//  Wish.swift
//  daisy
//
//  Created by Galina on 01/04/2020.
//  Copyright © 2020 Galina FABIO. All rights reserved.
//

import SwiftUI

struct Wish: Hashable, Codable, Identifiable {
    var id: String
    var title: String
    fileprivate var imageName: String
    var path: String
    var category: Category
    var price: String
    var description: String
    var isTaken: Bool
    var isReserved: Bool
    
    var takenImage: Image? {
        guard isTaken else { return nil }
        
        return Image(
            ImageStore.loadImage(name: "\(imageName)_taken"),
            scale: 2,
            label: Text(title))
    }
    
    enum Category: String, CaseIterable, Codable, Hashable {
        case featured = "Party"
        case lakes = "Day J"
    }
}

extension Wish {
    var image: Image {
        ImageStore.shared.image(name: imageName)
    }
}
