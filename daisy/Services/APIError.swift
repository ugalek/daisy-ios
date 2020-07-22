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

    static func processResponse(data: Data, response: URLResponse) throws -> Data {
        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.unknown
        }
        if (httpResponse.statusCode == 401) {
            throw APIError.message(reason: "Unauthorized");
        }
        if (httpResponse.statusCode == 403) {
            throw APIError.message(reason: "Resource forbidden");
        }
        if (httpResponse.statusCode == 404) {
            throw APIError.message(reason: "Resource not found");
        }
        if (405..<500 ~= httpResponse.statusCode) {
            throw APIError.message(reason: "Client error");
        }
        if (500..<600 ~= httpResponse.statusCode) {
            throw APIError.message(reason: "server error");
        }
        return data
    }
}
