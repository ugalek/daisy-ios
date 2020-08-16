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

public enum Endpoint {
    case images
    case image(imageID: String)
    case user(id: String)
    case lists
    case list(id: String)
    case items(listID: String)
    case item(listID: String, id: String)
    
    public func path() -> String {
        switch self {
        case .images:
            return "images/"
        case let .image(imageID):
            return "images/\(imageID)"
        case let .user(id):
            return "users/\(id)"
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

protocol APIDataTaskPublisher {
    func dataTaskPublisher(for request: URLRequest) -> URLSession.DataTaskPublisher
}

class APISessionDataPublisher: APIDataTaskPublisher {
    
    func dataTaskPublisher(for request: URLRequest) -> URLSession.DataTaskPublisher {
        return session.dataTaskPublisher(for: request)
    }
    
    var session: URLSession
    
    init(session: URLSession = URLSession.shared) {
        self.session = session
    }
}

final public class DaisyService {
    public static let shared: DaisyService = DaisyService()
    static var publisher: APIDataTaskPublisher = APISessionDataPublisher()
    
    let mainWidth = UIScreen.main.bounds.size.width
    let mainHeight = UIScreen.main.bounds.size.height
    
    let apiUrl = URL(string: UserDefaults.standard.string(forKey: "apiLink") ?? "/")!
    let token: String = UserDefaults.standard.string(forKey: "token") ?? ""
    let userID: String = UserDefaults.standard.string(forKey: "userID") ?? ""
    
    private let decoder = JSONDecoder()
    private let session: URLSession
    
    init(session: URLSession = URLSession.shared) {
        self.session = session
    }
    
    fileprivate func processResponse<T: Codable>(_ data: Data?,
                                                 _ resp: URLResponse?,
                                                 _ error: Error?,
                                                 statusCode: Int,
                                                 completion: @escaping (Response<T>) -> Void) {
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
        
        if let httpResponse = resp as? HTTPURLResponse {
            if httpResponse.statusCode == statusCode {
                do {
                    let value: T = try self.decoder.decode(T.self, from: data)
                    DispatchQueue.main.async {
                        let response = Response<T>(model: value, isSuccess: true, errorMsg: nil)
                        completion(response)
                    }
                } catch {
                    let response = Response<T>(model: nil, isSuccess: false, errorMsg: error.localizedDescription)
                    completion(response)
                }
            } else {
                DispatchQueue.main.async {
                    if let message = APIError.responseError(response: resp) {
                        let response = Response<T>(model: nil, isSuccess: false, errorMsg: message)
                        completion(response)
                    } else {
                        let response = Response<T>(model: nil, isSuccess: false, errorMsg: "Unknown error")
                        completion(response)
                    }
                }
            }
        }
    }
    
    fileprivate func setHeaders(_ endpoint: Endpoint) -> URLRequest {
        let component = URLComponents(url: apiUrl.appendingPathComponent(endpoint.path()),
                                      resolvingAgainstBaseURL: false)!
        
        var request = URLRequest(url: component.url!)
        
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer " + token, forHTTPHeaderField: "Authorization")
        decoder.dateDecodingStrategy = .formatted(DateFormatter.iso8601Full)
        
        return request
    }
    
    fileprivate func setPostHeaders(_ endpoint: Endpoint, httpMethod: String, body: Any) -> URLRequest {
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
        request.httpMethod = httpMethod
        request.httpBody = finalBody
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer " + token, forHTTPHeaderField: "Authorization")
        
        decoder.dateDecodingStrategy = .formatted(DateFormatter.iso8601Full)
        
        return request
    }
    
    private func getRequest<T: Codable>(type: T.Type, endpoint: Endpoint, completion: @escaping (Response<T>) -> Void) {
        let request = setHeaders(endpoint)
            
        session.dataTask(with: request) { (data, resp, error) in
            self.processResponse(data, resp, error, statusCode: 200, completion: completion)
        }.resume()
    }
    
    private func getRequestArray<T: Codable>(type: T.Type, endpoint: Endpoint, completion: @escaping (ResponseArray<T>) -> Void) {
        let request = setHeaders(endpoint)
        
        session.dataTask(with: request) { (data, resp, error) in
            if let error = error {
                let response = ResponseArray<T>(model: nil, isSuccess: false, errorMsg: error.localizedDescription)
                completion(response)
                return
            }
            
            guard let data = data else {
                let response = ResponseArray<T>(model: nil, isSuccess: false, errorMsg: "Unable to unwrap data")
                completion(response)
                return
            }
            
            if let httpResponse = resp as? HTTPURLResponse {
                if httpResponse.statusCode == 200 {
                    do {
                        let value: [T] = try self.decoder.decode([T].self, from: data)
                        DispatchQueue.main.async {
                            let response = ResponseArray<T>(model: value, isSuccess: true, errorMsg: nil)
                            completion(response)
                        }
                    } catch {
                        let response = ResponseArray<T>(model: nil, isSuccess: false, errorMsg: error.localizedDescription)
                        completion(response)
                    }
                } else {
                    DispatchQueue.main.async {
                        if let message = APIError.responseError(response: resp) {
                            let response = ResponseArray<T>(model: nil, isSuccess: false, errorMsg: message)
                            completion(response)
                        } else {
                            let response = ResponseArray<T>(model: nil, isSuccess: false, errorMsg: "Unknown error")
                            completion(response)
                        }
                    }
                }
            }
        }.resume()
    }
    
    private func postRequest<T: Codable>(type: T.Type, endpoint: Endpoint, body: Any, completion: @escaping (Response<T>) -> Void) {
        let request = setPostHeaders(endpoint, httpMethod: "POST", body: body)
        
        session.dataTask(with: request) { (data, resp, error) in
            self.processResponse(data, resp, error, statusCode: 201, completion: completion)
        }.resume()
    }
    
    private func patchRequest<T: Codable>(type: T.Type, endpoint: Endpoint, body: Any, completion: @escaping (Response<T>) -> Void) {
        let request = setPostHeaders(endpoint, httpMethod: "PATCH", body: body)
        
        session.dataTask(with: request) { (data, resp, error) in
            self.processResponse(data, resp, error, statusCode: 201, completion: completion)
        }.resume()
    }
    
    internal static func uploadImageDTP(image: UIImage) -> URLSession.DataTaskPublisher {
        let apiUrl = URL(string: UserDefaults.standard.string(forKey: "apiLink") ?? "/")!
        let token: String = UserDefaults.standard.string(forKey: "token") ?? ""
        
        let component = URLComponents(url: apiUrl.appendingPathComponent(Endpoint.images.path()),
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
        
        return publisher.dataTaskPublisher(for: request)
    }
    
    static func uploadImage(image: UIImage) -> AnyPublisher<ImageResponse, APIError> {
        return uploadImageDTP(image: image)
            .map { $0.data } // Extract the Data object from response.
            .decode(type: ImageResponse.self, decoder: JSONDecoder()) // Decode Data to a model object using JSONDecoder
            .mapError{ APIError.parseError(reason: $0.localizedDescription) }
            .eraseToAnyPublisher()
    }
    
    public func deleteRequest(endpoint: Endpoint, completion: @escaping (Bool, String?) -> Void) {
        let component = URLComponents(url: apiUrl.appendingPathComponent(endpoint.path()),
                                      resolvingAgainstBaseURL: false)!
        
        var request = URLRequest(url: component.url!)
        request.httpMethod = "DELETE"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer " + token, forHTTPHeaderField: "Authorization")
        
        session.dataTask(with: request) { (_, response, error) in
            if let httpResponse = response as? HTTPURLResponse {
                if httpResponse.statusCode == 200 {
                    DispatchQueue.main.async {
                        completion(true, nil)
                    }
                } else {
                    print("Delete error with statusCode: \(httpResponse.statusCode)")
                    DispatchQueue.main.async {
                        if let message = APIError.responseError(response: response) {
                            completion(false, message)
                        } else {
                            completion(false, "Unknown error")
                        }
                    }
                }
            }
        }.resume()
    }
}

extension DaisyService {
    public func searchUser(userID: String, completion: @escaping (Response<User>) -> Void) {
        getRequest(type: User.self, endpoint: .user(id: userID), completion: completion)
    }
    
    public func editUser(userID: String, body: Any, completion: @escaping (Response<User>) -> Void) {
        patchRequest(type: User.self, endpoint: .user(id: userID), body: body, completion: completion)
    }
    
    public func searchLists(completion: @escaping (ResponseArray<UserList>) -> Void) {
        getRequestArray(type: UserList.self, endpoint: .lists, completion: completion)
    }
    
    public func newList(body: Any, completion: @escaping (Response<UserList>) -> Void) {
        postRequest(type: UserList.self, endpoint: .lists, body: body, completion: completion)
    }
    
    public func editList(listID: String, body: Any, completion: @escaping (Response<UserList>) -> Void) {
        patchRequest(type: UserList.self, endpoint: .list(id: listID), body: body, completion: completion)
    }
    
    public func searchItems(listID: String, completion: @escaping (ResponseArray<Item>) -> Void) {
        getRequestArray(type: Item.self, endpoint: .items(listID: listID), completion: completion)
    }
    
    public func newItem(listID: String, body: Any, completion: @escaping (Response<Item>) -> Void) {
        postRequest(type: Item.self, endpoint: .items(listID: listID), body: body, completion: completion)
    }
    
    public func editItem(listID: String, itemID: String, body: Any, completion: @escaping (Response<Item>) -> Void) {
        patchRequest(type: Item.self, endpoint: .item(listID: listID, id: itemID), body: body, completion: completion)
    }
}
