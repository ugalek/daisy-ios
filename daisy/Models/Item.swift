//
//  Item.swift
//  daisy
//
//  Created by Galina on 16/04/2020.
//  Copyright © 2020 Galina FABIO. All rights reserved.
//

import SwiftUI

struct ItemResults: Decodable {
    let items: [Item]
}

struct Item: Decodable, Identifiable {
    let id: String
    let listID: String?
    let createdAt: Date?
    let updatedAt: Date?
    let title: String
    let image: String
    let url: String?
    let price: Float64
    let description: String
    let status: uint
}

extension Item {
    var imageStored: Image {
        ImageStore.shared.image(name: image)
    }
}
