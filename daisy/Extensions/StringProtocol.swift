//
//  StringProtocol.swift
//  daisy
//
//  Created by Galina on 03/07/2020.
//  Copyright © 2020 Galina FABIO. All rights reserved.
//

import Foundation

extension StringProtocol {
    var double: Double? { Double(self) }
    var float: Float? { Float(self) }
    var integer: Int? { Int(self) }
}
