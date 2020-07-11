//
//  Double.swift
//  daisy
//
//  Created by Galina on 03/07/2020.
//  Copyright © 2020 Galina FABIO. All rights reserved.
//

import Foundation

extension Double {
    var fractionalDigits: Int {
        return "\(String(self).split(separator: ".")[1])".count
    }
}
