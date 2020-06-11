//
//  List.swift
//  daisy
//
//  Created by Galina on 21/04/2020.
//  Copyright © 2020 Galina FABIO. All rights reserved.
//

import SwiftUI

struct ListResults: Decodable {
    let lists: [UserList]
}

public struct UserList: Decodable, Identifiable, Hashable {
    public let id: String
    let userID: String?
    let createdAt: Date?
    let updatedAt: Date?
    let title: String
    let image: String
    let surprise: Bool
}

extension UserList {
    var imageStored: Image {
        ImageStore.shared.image(name: image)
    }
}
