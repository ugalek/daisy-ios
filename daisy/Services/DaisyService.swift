//
//  DaisyService.swift
//  daisy
//
//  Created by Galina on 04/06/2020.
//  Copyright © 2020 Galina FABIO. All rights reserved.
//

import Foundation
import Combine
import SwiftUI

struct DaisyService {
    static let apiUrl = URL(string: UserDefaults.standard.string(forKey: "apiLink") ?? "/")!
    static let token: String = UserDefaults.standard.string(forKey: "token") ?? ""
    
    public enum Endpoint {
        case image
        case images(userID: String)
        case lists
        case list(id: String)
        case items(listID: String)
        case item(listID: String, id: String)
        
        public func path() -> String {
            switch self {
            case .image:
                return "images/"
            case let .images(userID):
                return "images/\(userID)"
            case .lists:
                return "lists/"
            case let .list(id):
                return "lists/\(id)"
            case let .items(listID):
                return "lists/\(listID)/items"
            case let .item(listID, id):
                return "lists/\(listID)/items/\(id)"
            }
        }
    }
    
    private static let decoder = JSONDecoder()
    
    public static func getRequest<T: Codable>(endpoint: Endpoint) -> AnyPublisher<[T], APIError> {
        let component = URLComponents(url: apiUrl.appendingPathComponent(endpoint.path()),
                                      resolvingAgainstBaseURL: false)!
        
        var request = URLRequest(url: component.url!)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer " + token, forHTTPHeaderField: "Authorization")
        
        decoder.dateDecodingStrategy = .formatted(DateFormatter.iso8601Full)
        
        return URLSession.shared.dataTaskPublisher(for: request)
            .map { r in
//                print(endpoint)
//                print(String(data: r.data, encoding: .utf8)!);
//                print(r.response)
                return r.data
            } // Extract the Data object from response.
            .decode(type: [T].self, decoder: Self.decoder) // Decode Data to a model object using JSONDecoder
            .mapError{ APIError.parseError(reason: $0.localizedDescription) }
            .eraseToAnyPublisher()
    }
    
    public static func postRequest<T: Codable>(endpoint: Endpoint, body: Any) -> AnyPublisher<T, APIError> {
        let component = URLComponents(url: apiUrl.appendingPathComponent(endpoint.path()),
                                      resolvingAgainstBaseURL: false)!
        var finalBody: Data?
        
        // make sure this JSON is in the format we expect
        do {
            finalBody = try JSONSerialization.data(withJSONObject: body)
        } catch let error as NSError {
            print("Failed to load: \(error.localizedDescription)")
        }
        
        var request = URLRequest(url: component.url!)
        request.httpMethod = "POST"
        request.httpBody = finalBody
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer " + token, forHTTPHeaderField: "Authorization")
        
        return URLSession.shared.dataTaskPublisher(for: request)
            .map { $0.data } // Extract the Data object from response.
            .decode(type: T.self, decoder: Self.decoder) // Decode Data to a model object using JSONDecoder
            .mapError{ APIError.parseError(reason: $0.localizedDescription) }
            .eraseToAnyPublisher()
    }
    
    public static func uploadImageRequest<T: Codable>(endpoint: Endpoint, image: UIImage) -> AnyPublisher<T, APIError> {
        let component = URLComponents(url: apiUrl.appendingPathComponent(endpoint.path()),
                                      resolvingAgainstBaseURL: false)!
        
        let targetSize = CGSize(width: 100, height: 100)
        let scaledImage = image.scalePreservingAspectRatio(targetSize: targetSize)
        let boundaryID = UUID().uuidString
        var request = URLRequest(url: component.url!)
        var body = Data()
        
        request.httpMethod = "POST"
        request.setValue("Bearer " + token, forHTTPHeaderField: "Authorization")
        request.setValue("multipart/form-data; boundary=\(boundaryID)", forHTTPHeaderField: "Content-Type")
        
        // Add the image data to the raw http request data
        body.append(Data("--\(boundaryID)\r\n".utf8))
        body.append(Data("Content-Disposition: form-data; name=\"file\"; filename=\"image.png\"\r\n".utf8))
        body.append(Data("Content-Type: image/png\r\n".utf8))
        body.append(Data("\r\n".utf8))
        body.append(scaledImage.pngData()!)
        body.append(Data("\r\n".utf8))
        body.append(Data("--\(boundaryID)--".utf8))
        
        request.httpBody = body
  
        return URLSession.shared.dataTaskPublisher(for: request)
            .map { $0.data } // Extract the Data object from response.
            .decode(type: T.self, decoder: Self.decoder) // Decode Data to a model object using JSONDecoder
            .mapError{ APIError.parseError(reason: $0.localizedDescription) }
            .eraseToAnyPublisher()
    }
    
    public static func deleteRequest(endpoint: Endpoint, completion: @escaping (Bool) -> Void) {
        let component = URLComponents(url: apiUrl.appendingPathComponent(endpoint.path()),
                                      resolvingAgainstBaseURL: false)!
        
        var request = URLRequest(url: component.url!)
        request.httpMethod = "DELETE"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer " + token, forHTTPHeaderField: "Authorization")
        
        URLSession.shared.dataTask(with: request) { (_, response, error) in
            if let httpResponse = response as? HTTPURLResponse {
                if httpResponse.statusCode == 200 {
                    DispatchQueue.main.async {
                        completion(true)
                    }
                } else {
                    print("Delete error with statusCode: \(httpResponse.statusCode)")
                    DispatchQueue.main.async {
                        completion(false)
                    }
                }
                
            }
        }.resume()
    }
}

