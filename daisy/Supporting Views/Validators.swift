//
//  Validators.swift
//  daisy
//
//  Created by Galina on 18/04/2020.
//  Copyright © 2020 Galina FABIO. All rights reserved.
//

import Foundation
import UIKit

struct Validators {
    static func emailIsValid(email: String) -> Bool {
        let regex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let predicate = NSPredicate(format:"SELF MATCHES %@", regex)
        return predicate.evaluate(with: email)
    }
    
    static func titleIsValid(title: String) -> Bool {
        if title.count < 3 && title.count > 255 {
            return false
        }
        
        return true
    }
    
    static func nameIsValid(name: String) -> Bool {
        if name.count > 200 {
            return false
        }
        
        return true
    }
    
    func urlIsValid(urlString: String?) -> Bool {
        if let urlString = urlString {
            if let url = NSURL(string: urlString) {
                return UIApplication.shared.canOpenURL(url as URL)
            }
        }
        return false
    }
}
