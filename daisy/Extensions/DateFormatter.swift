//
//  DateFormatter.swift
//  daisy
//
//  Created by Galina on 12/07/2020.
//  Copyright © 2020 Galina FABIO. All rights reserved.
//

import Foundation

extension DateFormatter {
    static let iso8601Full: DateFormatter = {
        let formatter = DateFormatter()
        //"2020-07-11T22:13:42.558053+02:00"
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZZZZZ"
        formatter.calendar = Calendar(identifier: .iso8601)
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter
    }()
}

extension Date {
    func toDateString(withFormat format: String = "yyyy-MM-dd") -> String {
        //"1990-07-13"
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .iso8601)
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        
        formatter.dateFormat = format
        let str = formatter.string(from: self)
        
        return str
    }
}

extension String {
    func toDate(withFormat format: String = "yyyy-MM-dd") -> Date {
        //"1990-07-13"
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .iso8601)
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.locale = Locale(identifier: "en_US_POSIX")
    
        formatter.dateFormat = format
        guard let date = formatter.date(from: self) else {
            return Date()
        }
        
        return date
    }
}
