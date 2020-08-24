//
//  Image.swift
//  daisy
//
//  Created by Galina on 05/07/2020.
//  Copyright © 2020 Galina FABIO. All rights reserved.
//

import SwiftUI

struct ImageResponse: Codable, Hashable {
    enum CodingKeys: String, CodingKey {
        // Map the JSON keys to the Swift property names
        case id = "id"
        case userID = "user_id"
        case ext = "extension"
        case size
        case contentType = "content_type"
        case url
        case createdAt = "created_at"
    }
    let id: String
    let userID: String
    let ext: String
    let size: Int
    let contentType: String
    let url: String
    let createdAt: Date?
}
