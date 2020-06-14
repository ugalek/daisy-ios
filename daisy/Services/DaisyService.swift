//
//  DaisyService.swift
//  daisy
//
//  Created by Galina on 04/06/2020.
//  Copyright © 2020 Galina FABIO. All rights reserved.
//

import Foundation
import Combine

struct DaisyService {
    static let apiLink: String = UserDefaults.standard.string(forKey: "apiLink") ?? ""
    static let token: String = UserDefaults.standard.string(forKey: "token") ?? ""
    
    public enum Endpoint {
        case list
        case items(id: String)
        
        public func path() -> String {
            switch self {
            case .list:
                return "list"
            case let .items(id):
                return "lists/\(id)/items"
            }
        }
    }
    
    private static let decoder = JSONDecoder()
    
    enum GameError: Error {
      case statusCode
      case decoding
      case invalidImage
      case invalidURL
      case other(Error)
      
      static func map(_ error: Error) -> GameError {
        return (error as? GameError) ?? .other(error)
      }
    }
    
    public static func postRequestItem(endpoint: Endpoint, body: Any) -> AnyPublisher<Item, APIError> {
        print("Post item to db")
        let apiUrl = URL(string: apiLink)!
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

//        return URLSession.shared.dataTaskPublisher(for: request)
//            .map { print(String(data: $0.data, encoding: .utf8)!); return $0.data } // $0.data Extract the Data object from response.
//           // .receive(on: RunLoop.main)
//            .decode(type: Item.self, decoder: Self.decoder) // Decode Data to a model object using JSONDecoder
//            .mapError{ APIError.parseError(reason: $0.localizedDescription) }
//            .eraseToAnyPublisher()
        
        return URLSession.shared.dataTaskPublisher(for: request)
            .tryMap { response -> Data in
                guard let httpURLResponse = response.response as? HTTPURLResponse,
                    httpURLResponse.statusCode == 200
                    else { throw GameError.statusCode }
                return response.data
        }
        .tryMap { data in
            print(data)
            return data
        }
       // .receive(on: DispatchQueue.main)
        .decode(type: Item.self, decoder: JSONDecoder())
        .mapError { APIError.parseError(reason: $0.localizedDescription) }
        .eraseToAnyPublisher()
    }
  
    public static func postRequest<T: Codable>(endpoint: Endpoint, body: Any) -> AnyPublisher<T, APIError> {
        let apiUrl = URL(string: apiLink)!
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
            .receive(on: DispatchQueue.main)
            .decode(type: T.self, decoder: Self.decoder) // Decode Data to a model object using JSONDecoder
            .mapError{ APIError.parseError(reason: $0.localizedDescription) }
            .eraseToAnyPublisher()
        
    }
    
    public static func postData<T: Codable>(endpoint: Endpoint, body: Any) -> AnyPublisher<T, APIError> {
        
        let apiUrl = URL(string: apiLink)!
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
            .tryMap{ data, response in
                let resp =  try APIError.processResponse(data: data, response: response)
                print(String(data: resp, encoding: .utf8)!);
                return resp
               // let rr = try? JSONDecoder().decode(T.self, from: resp)
              //  print(rr)
               //return rr
        }
        .decode(type: T.self, decoder: Self.decoder)
        .mapError{ APIError.parseError(reason: $0.localizedDescription) }
        .map({ result in
            return result
        })
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
}

public enum APIError: Error {
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
