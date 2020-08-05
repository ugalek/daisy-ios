//
//  User.swift
//  daisy
//
//  Created by Galina on 31/07/2020.
//  Copyright © 2020 Galina FABIO. All rights reserved.
//

import SwiftUI

struct UserResults: Decodable {
    let users: [User]
}

public struct User: Codable, Identifiable, Hashable {
    enum CodingKeys: String, CodingKey {
        // Map the JSON keys to the Swift property names
        case id
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case name
        case birthday
        case birthdayDate
        case email
        case role
        case image
        case imageID
    }
    
    public let id: String
    let createdAt: Date?
    let updatedAt: Date?
    let name: String
    let birthday: String
    let birthdayDate: Date
    let email: String
    let role: uint
    let image: ImageResponse?
    let imageID: String?
    
    private let dateFormatter = DateFormatter()
    
    init(id: String = "", createdAt: Date? = nil, updatedAt: Date? = nil,
         name: String = "", birthday: String = "", email: String = "", role: uint = 1, imageID: String? = "", image: ImageResponse? = nil) {
        self.id = id
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.name = name
        self.birthday = birthday
        self.email = email
        self.role = role
        self.imageID = imageID
        self.image = image
        self.birthdayDate = birthday.toDate()
    }
    
    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        
        id = try values.decode(String.self, forKey: .id)
        createdAt = try values.decodeIfPresent(Date.self, forKey: .createdAt)
        updatedAt = try values.decodeIfPresent(Date.self, forKey: .updatedAt)
        name = try values.decode(String.self, forKey: .name)
        birthday = try values.decode(String.self, forKey: .birthday)
        email = try values.decode(String.self, forKey: .email)
        role = try values.decode(uint.self, forKey: .role)
        imageID = try? values.decodeIfPresent(String.self, forKey: .imageID)
        image = try values.decodeIfPresent(ImageResponse.self, forKey: .image)
        birthdayDate = birthday.toDate()
     }
}

public let staticUser = User(id: "1",
                             createdAt: Date(),
                             updatedAt: Date(),
                             name: "Test user",
                             birthday: "1990-07-13",
                             email: "example@email.com",
                             role: 1,
                             imageID: nil,
                             image: nil)
