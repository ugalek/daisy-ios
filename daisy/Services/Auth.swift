//
//  Auth.swift
//  daisy
//
//  Created by Galina on 16/04/2020.
//  Copyright © 2020 Galina FABIO. All rights reserved.
//

import Foundation
import Combine

struct ServerMessage: Decodable {
    let expired_at, token, user_id: String
}

typealias DataTaskResult = (Data?, URLResponse?, Error?) -> Void

class HttpAuth: ObservableObject {
    @Published var authenticated = false
    @Published var errorMessage = ""
    @Published var showAlert = false
    
    private let session: URLSession
    
    init(session: URLSession = URLSession.shared) {
        self.session = session
    }
    
    func login(email: String, password: String, completion: @escaping (String?, APIError?) -> Void) {
        let apiUrl = URL(string: UserDefaults.standard.string(forKey: "apiLink") ?? "/")!
        let component = URLComponents(url: apiUrl.appendingPathComponent("auth"),
                                             resolvingAgainstBaseURL: false)!
        
        guard let url = component.url else { return }
        
        let body: [String: String] = ["email": email, "password": password]
        
        do {
            // make sure this JSON is in the format we expect
            let finalBody = try JSONSerialization.data(withJSONObject: body)
            
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.httpBody = finalBody
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            
            session.dataTask(with: request) { (data, response, error) in
                if let error = error {
                    completion(nil, APIError.networkError(reason: error.localizedDescription))
                    DispatchQueue.main.async {
                        self.errorMessage = error.localizedDescription
                        self.showAlert = true
                    }
                    return
                }
                guard let data = data else { return }
                
                if let httpResponse = response as? HTTPURLResponse {
                    if httpResponse.statusCode == 200 {
                        do {
                            let finalData = try JSONDecoder().decode(ServerMessage.self, from: data)
                            DispatchQueue.main.async {
                                self.authenticated = true
                                completion(finalData.user_id, nil)
                                UserDefaults.standard.set(finalData.token, forKey: "token")
                                UserDefaults.standard.set(finalData.user_id, forKey: "userID")
                                print(finalData.token)
                            }
                        } catch {
                            DispatchQueue.main.async {
                                completion(nil, APIError.message(reason: "Cannot decode server message"))
                                self.errorMessage = "Cannot decode server message"
                                self.showAlert = true
                            }
                        }
                    } else {
                        DispatchQueue.main.async {
                            if let message = APIError.responseError(response: response) {
                                completion(nil, APIError.message(reason: message))
                                self.errorMessage = message
                            } else {
                                completion(nil, APIError.unknown)
                                self.errorMessage = "Unknown error."
                            }
                            self.showAlert = true
                        }
                    }
                }
            }.resume()
            
        } catch let error as NSError {
            print("Failed to load: \(error.localizedDescription)")
        }
    }
}
