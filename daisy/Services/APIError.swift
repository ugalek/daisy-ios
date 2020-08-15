//
//  APIError.swift
//  daisy
//
//  Created by Galina on 15/06/2020.
//  Copyright © 2020 Galina FABIO. All rights reserved.
//

import Foundation

public enum APIError: Error, LocalizedError {
    case unknown
    case message(reason: String), parseError(reason: String), networkError(reason: String)

    static func processResponse(response: URLResponse?) -> String? {
        
        guard let httpResponse = response as? HTTPURLResponse else {
            return "We've encountered an unknown error. If problem persist then send us feedback."
        }
        if (httpResponse.statusCode == 401) {
            return "Unauthorized"
        }
        if (httpResponse.statusCode == 403) {
            return "Resource forbidden"
        }
        if (httpResponse.statusCode == 404) {
            return "Resource not found"
        }
        if (405..<500 ~= httpResponse.statusCode) {
            return "Client error"
        }
        if (500..<600 ~= httpResponse.statusCode) {
            return "Server error"
        }
        
        return nil
    }
}
