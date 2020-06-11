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

public struct Item: Codable, Identifiable, Hashable {
    public let id: String
    let listID: String?
    let createdAt: Date?
    let updatedAt: Date?
    let title: String
    let image: String
    let url: String?
    let price: Float64?
    let description: String
    let status: uint
    
    init(id: String = "", listID: String = "", createdAt: Date? = nil, updatedAt: Date? = nil,
         title: String = "", image: String = "", url: String? = nil, price: Float64? = nil, description: String = "", status: uint = 1) {
        self.id = id
        self.listID = listID
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.title = title
        self.image = image
        self.url = url
        self.price = price
        self.description = description
        self.status = status
    }
}

extension Item {
    var imageStored: Image {
        ImageStore.shared.image(name: image)
    }
}
