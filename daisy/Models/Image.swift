//
//  Image.swift
//  daisy
//
//  Created by Galina on 05/07/2020.
//  Copyright © 2020 Galina FABIO. All rights reserved.
//

import SwiftUI

//{
//    "content_type": "image/png",
//    "created_at": "2020-07-13T20:44:47.876968+02:00",
//    "extension": ".png",
//    "id": "01ED4QWT44XDX9KR14RKBBYX2M",
//    "path": "upload/1/01ED4QWT44XDX9KR14RKBBYX2M.png",
//    "size": 312400,
//    "url": "http://localhost:3000/upload/1/01ED4QWT44XDX9KR14RKBBYX2M.png",
//    "user_id": "1"
//}

struct ImageResponse: Codable {
    enum CodingKeys: String, CodingKey {
        // Map the JSON keys to the Swift property names
        case ID = "id"
        case userID = "user_id"
        case ext = "extension"
        case size
        case contentType = "content_type"
        case url
        case createdAt = "created_at"
    }
    let ID: String
    let userID: String
    let ext: String
    let size: Int
    let contentType: String
    let url: String
    let createdAt: Date?
}
