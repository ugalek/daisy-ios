//
//  Response.swift
//  daisy
//
//  Created by Galina on 20/07/2020.
//  Copyright © 2020 Galina FABIO. All rights reserved.
//

import Foundation

public struct ResponseArray<T> {
    var model: [T]?
    var isSuccess: Bool = false
    var errorMsg: String?
}
