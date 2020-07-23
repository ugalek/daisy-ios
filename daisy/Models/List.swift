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
    enum CodingKeys: String, CodingKey {
        // Map the JSON keys to the Swift property names
        case id
        case userID = "user_id"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case title
        case image
        case imageID = "image_id"
        case surprise
    }
    
    public let id: String
    let userID: String?
    let createdAt: Date?
    let updatedAt: Date?
    let title: String
    let image: String?
    let imageID: String?
    let surprise: Bool
}

public let staticList = UserList(id: "0",
                                      userID: "1",
                                      createdAt: Date(),
                                      updatedAt: Date(),
                                      title: "Static list",
                                      image: "turtlerock",
                                      imageID: "turtlerock",
                                      surprise: false)
public let staticSurpriseList = UserList(id: "1",
                                 userID: "1",
                                 createdAt: Date(),
                                 updatedAt: Date(),
                                 title: "Static surprise list",
                                 image: "silversalmoncreek",
                                 imageID: "turtlerock",
                                 surprise: true)
