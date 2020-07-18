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
    
    enum CodingKeys: String, CodingKey {
        // Map the JSON keys to the Swift property names
        case id
        case listID = "list_id"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case title
        case imageID = "image_id"
        case image
        case url
        case price
        case description
        case status
    }
    
    public let id: String
    let listID: String
    let createdAt: Date?
    let updatedAt: Date?
    let title: String
    let imageID: String?
    var image: ImageResponse?
    let url: String?
    let price: Float64?
    let description: String?
    let status: uint
    
    init(id: String = "", listID: String = "", createdAt: Date? = nil, updatedAt: Date? = nil,
         title: String = "", imageID: String? = "", image: ImageResponse? = nil, url: String? = nil, price: Float64? = nil, description: String? = "", status: uint = 1) {
        self.id = id
        self.listID = listID
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.title = title
        self.imageID = imageID
        self.image = image
        self.url = url
        self.price = price
        self.description = description
        self.status = status
    }
    
    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        
        id = try values.decode(String.self, forKey: .id)
        listID = try values.decode(String.self, forKey: .listID)
        createdAt = try values.decodeIfPresent(Date.self, forKey: .createdAt)
        updatedAt = try values.decodeIfPresent(Date.self, forKey: .updatedAt)
        title = try values.decode(String.self, forKey: .title)
        imageID = try? values.decodeIfPresent(String.self, forKey: .imageID)
        image = try values.decodeIfPresent(ImageResponse.self, forKey: .image)
        url = try? values.decodeIfPresent(String.self, forKey: .url)
        price = try? values.decodeIfPresent(Float64.self, forKey: .price)
        description = try? values.decodeIfPresent(String.self, forKey: .description)
        status = try values.decode(uint.self, forKey: .status)
     }
}

public let staticItem = Item(id: "1001",
                             listID: "1",
                             createdAt: Date(),
                             updatedAt: Date(),
                             title: "My static Item with long and long title",
                             imageID: "1",
                             image: nil,
                             url: "http://ugalek.com",
                             price: 10.1,
                             description: "Mi, tellus fermentum class. Molestie id eget sem neque et condimentum pharetra penatibus luctus morbi et parturient. Purus imperdiet libero penatibus vivamus est lacinia montes nam tincidunt convallis? Maecenas nec placerat gravida bibendum ultricies nisi, lobortis lacinia. Venenatis ad leo potenti vel, molestie elementum. Penatibus purus cras auctor dolor etiam natoque tristique bibendum magnis. Viverra natoque. Eros hac quis tempor dolor mi. Morbi porttitor sit natoque enim facilisi! Cursus, elementum gravida metus luctus auctor justo. Nostra vel aptent vel risus iaculis felis consectetur bibendum duis. Tellus in tellus neque tristique eget cubilia ultricies nostra. Mattis nascetur pharetra imperdiet. Placerat dapibus sapien himenaeos ultrices, euismod dui mattis eros lorem. Natoque tempus in parturient. Leo at quis facilisi dapibus convallis primis est ultrices sit?",
                             status: 1)

public let staticReservedItem = Item(id: "1002",
                                     listID: "1",
                                     createdAt: Date(),
                                     updatedAt: Date(),
                                     title: "My reserved Item with long and long title",
                                     imageID: "2",
                                     image: nil,
                                     url: "http://ugalek.com",
                                     price: 20.2,
                                     description: "Mi, tellus fermentum class. Molestie id eget sem neque et condimentum pharetra penatibus luctus morbi et parturient. Purus imperdiet libero penatibus vivamus est lacinia montes nam tincidunt convallis? Maecenas nec placerat gravida bibendum ultricies nisi, lobortis lacinia. Venenatis ad leo potenti vel, molestie elementum. Penatibus purus cras auctor dolor etiam natoque tristique bibendum magnis. Viverra natoque. Eros hac quis tempor dolor mi. Morbi porttitor sit natoque enim facilisi! Cursus, elementum gravida metus luctus auctor justo. Nostra vel aptent vel risus iaculis felis consectetur bibendum duis. Tellus in tellus neque tristique eget cubilia ultricies nostra. Mattis nascetur pharetra imperdiet. Placerat dapibus sapien himenaeos ultrices, euismod dui mattis eros lorem. Natoque tempus in parturient. Leo at quis facilisi dapibus convallis primis est ultrices sit?",
                                     status: 2)

public let staticTakenItem = Item(id: "1003",
                                 listID: "1",
                                 createdAt: Date(),
                                 updatedAt: Date(),
                                 title: "My taken Item",
                                 imageID: "1",
                                 image: nil,
                                 url: "http://ugalek.com",
                                 price: 30.3,
                                 description: "Mi, tellus fermentum class. Molestie id eget sem neque et condimentum pharetra penatibus luctus morbi et parturient. Purus imperdiet libero penatibus vivamus est lacinia montes nam tincidunt convallis? Maecenas nec placerat gravida bibendum ultricies nisi, lobortis lacinia. Venenatis ad leo potenti vel, molestie elementum. Penatibus purus cras auctor dolor etiam natoque tristique bibendum magnis. Viverra natoque. Eros hac quis tempor dolor mi. Morbi porttitor sit natoque enim facilisi! Cursus, elementum gravida metus luctus auctor justo. Nostra vel aptent vel risus iaculis felis consectetur bibendum duis. Tellus in tellus neque tristique eget cubilia ultricies nostra. Mattis nascetur pharetra imperdiet. Placerat dapibus sapien himenaeos ultrices, euismod dui mattis eros lorem. Natoque tempus in parturient. Leo at quis facilisi dapibus convallis primis est ultrices sit?",
                                 status: 3)

extension Item {
    static func getRawStatus(status: uint) -> String {
        switch status {
        case 2:
            return "Reserved"
        case 3:
            return "Taken"
        default:
            return ""
        }
    }
    
    static func getPriceString(price: Float64?) -> String {
        if let price = price {
            return String(format: "%.2f", price)
        }
        return "0.00"
    }
}
