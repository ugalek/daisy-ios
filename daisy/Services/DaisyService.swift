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
    static let apiUrl: URL = URL(string: UserDefaults.standard.string(forKey: "apiLink") ?? "/")!
    static let token: String = UserDefaults.standard.string(forKey: "token") ?? ""
    
    public enum Endpoint {
        case lists
        case items(id: String)
        
        public func path() -> String {
            switch self {
            case .lists:
                return "lists/"
            case let .items(id):
                return "lists/\(id)/items"
            }
        }
    }
    
    private static let decoder = JSONDecoder()
    
    public static func genericFetch<T: Decodable>(endpoint: Endpoint, completion: @escaping (T) -> ()) {
        let component = URLComponents(url: apiUrl.appendingPathComponent(endpoint.path()),
                                      resolvingAgainstBaseURL: false)!
        
        
        let session = URLSession(configuration: .default)
        var request = URLRequest(url: component.url!)
        request.setValue("Bearer " + token, forHTTPHeaderField: "Authorization")
        let task = session.dataTask(with: request) { (data, response, error) in
            guard let httpResponse = response as? HTTPURLResponse,
                (200...299).contains(httpResponse.statusCode) else {
                    return
            }
            guard let mime = response?.mimeType, mime == "application/json" else {
                print("Wrong MIME type!")
                return
            }
            if error == nil {
                if let safeData = data {
                    do {
                        let dec = JSONDecoder()
                        // dec.keyDecodingStrategy = .convertFromSnakeCase
                        let model = try dec.decode(T.self, from: safeData)
                        completion(model)
                    } catch let jsonErr {
                        print("Failed to decode, \(jsonErr)")
                    }
                }
            }
        }
        task.resume()
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
}
