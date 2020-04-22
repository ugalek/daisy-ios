//
//  List.swift
//  daisy
//
//  Created by Galina on 21/04/2020.
//  Copyright © 2020 Galina FABIO. All rights reserved.
//

import SwiftUI

struct ListResults: Decodable {
    let lists: [Listy]
}

struct Listy: Decodable, Identifiable {
    let id: String
    let userID: String?
    let createdAt: Date?
    let updatedAt: Date?
    let title: String
    let image: String
    let surprise: Bool
}

extension Listy {
    var imageStored: Image {
        ImageStore.shared.image(name: image)
    }
}
