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

public struct Response<T> {
    var model: [T]?
    var isSuccess: Bool = false
    var errorMsg: String?
}

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

final public class DaisyService {
    public static let shared: DaisyService = DaisyService()
    
    let mainWidth = UIScreen.main.bounds.size.width
    let mainHeight = UIScreen.main.bounds.size.height
    
    let apiUrl = URL(string: UserDefaults.standard.string(forKey: "apiLink") ?? "/")!
    let token: String = UserDefaults.standard.string(forKey: "token") ?? ""
    
    private let decoder = JSONDecoder()
    
    private func getRequest<T: Codable>(type: T.Type, endpoint: Endpoint, completion: @escaping (Response<T>) -> Void) {
        let component = URLComponents(url: apiUrl.appendingPathComponent(endpoint.path()),
                                      resolvingAgainstBaseURL: false)!
        
        var request = URLRequest(url: component.url!)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer " + token, forHTTPHeaderField: "Authorization")
        
        decoder.dateDecodingStrategy = .formatted(DateFormatter.iso8601Full)
        
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let error = error {
                let response = Response<T>(model: nil, isSuccess: false, errorMsg: error.localizedDescription)
                completion(response)
                return
            }
            
            guard let data = data else {
                let response = Response<T>(model: nil, isSuccess: false, errorMsg: "Unable to unwrap data")
                completion(response)
                return
            }
            
            do {
                let value: [T] = try self.decoder.decode([T].self, from: data)
                DispatchQueue.main.async {
                    let response = Response<T>(model: value, isSuccess: true, errorMsg: nil)
                    completion(response)
                }
            } catch {
                let response = Response<T>(model: nil, isSuccess: false, errorMsg: error.localizedDescription)
                completion(response)
            }
        }.resume()
    }
    
    private func getRequestPublisher<T: Codable>(endpoint: Endpoint) -> AnyPublisher<[T], APIError> {
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
            .decode(type: [T].self, decoder: self.decoder) // Decode Data to a model object using JSONDecoder
            .mapError{ APIError.parseError(reason: $0.localizedDescription) }
            .eraseToAnyPublisher()
    }
    
    public func postRequest<T: Codable>(endpoint: Endpoint, body: Any) -> AnyPublisher<T, APIError> {
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
            .decode(type: T.self, decoder: self.decoder) // Decode Data to a model object using JSONDecoder
            .mapError{ APIError.parseError(reason: $0.localizedDescription) }
            .eraseToAnyPublisher()
    }
    
    public func uploadImageRequest<T: Codable>(endpoint: Endpoint, image: UIImage) -> AnyPublisher<T, APIError> {
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
            .decode(type: T.self, decoder: self.decoder) // Decode Data to a model object using JSONDecoder
            .mapError{ APIError.parseError(reason: $0.localizedDescription) }
            .eraseToAnyPublisher()
    }
    
    public func deleteRequest(endpoint: Endpoint, completion: @escaping (Bool) -> Void) {
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

extension DaisyService {
    public func searchItems(listID: String, completion: @escaping (Response<Item>) -> Void) {
        DaisyService.shared.getRequest(type: Item.self, endpoint: .items(listID: listID), completion: completion)
    }
    
    public func searchList(completion: @escaping (Response<UserList>) -> Void) {
        DaisyService.shared.getRequest(type: UserList.self, endpoint: .lists, completion: completion)
    }
}
