//
//  Helpers.swift
//  daisy
//
//  Created by Galina on 18/04/2020.
//  Copyright © 2020 Galina FABIO. All rights reserved.
//

import Foundation
import UIKit

struct Helpers {
    func isValid(email: String) -> Bool {
        let regex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let predicate = NSPredicate(format:"SELF MATCHES %@", regex)
        return predicate.evaluate(with: email)
    }
}
