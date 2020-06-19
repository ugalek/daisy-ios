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

public struct UserList: Codable, Identifiable, Hashable {
    public let id: String
    let userID: String?
    let createdAt: Date?
    let updatedAt: Date?
    let title: String
    let image: String
    let surprise: Bool
}

public let staticList = UserList(id: "0",
                                      userID: "1",
                                      createdAt: Date(),
                                      updatedAt: Date(),
                                      title: "Static list",
                                      image: "turtlerock",
                                      surprise: false)
extension UserList {
    var imageStored: Image {
        ImageStore.shared.image(name: image)
    }
}
