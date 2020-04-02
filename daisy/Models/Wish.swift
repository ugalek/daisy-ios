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
    var price: String
    var description: String
}

extension Wish {
    var image: Image {
        ImageStore.shared.image(name: imageName)
    }
}
