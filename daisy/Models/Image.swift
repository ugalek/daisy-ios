//
//  Image.swift
//  daisy
//
//  Created by Galina on 05/07/2020.
//  Copyright © 2020 Galina FABIO. All rights reserved.
//

import SwiftUI

struct ImageRequest: Encodable {
    let userID: String
    let data: String
    let ext: String
    let contentType: String
    let length: Int
}

struct ImageResponse: Decodable {
    let response: String
}
