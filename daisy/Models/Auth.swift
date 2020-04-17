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
    let expired_at, token: String
}

class HttpAuth: ObservableObject {
    var didChange = PassthroughSubject<HttpAuth, Never>()
    @Published var authenticated = false {
        didSet {
            didChange.send(self)
        }
    }
    
    func checkDetails(email: String, password: String) {
        guard let url = URL(string: "http://localhost:3000/api/v1/auth") else { return }
        
        let body: [String: String] = ["email": email, "password": password]
        
        do {
            // make sure this JSON is in the format we expect
            let finalBody = try JSONSerialization.data(withJSONObject: body)
            
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.httpBody = finalBody
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            
            URLSession.shared.dataTask(with: request) { (data, response, error) in
                guard let data = data else { return }
                if let httpResponse = response as? HTTPURLResponse {
                    if httpResponse.statusCode == 200 {
                        do {
                            let finalData = try JSONDecoder().decode(ServerMessage.self, from: data)
                            print(finalData)
                            DispatchQueue.main.async {
                                self.authenticated = true
                            }
                        } catch {
                            print("Cannot decode server message")
                        }
                    } else {
                        print("Unauthorized")
                        print("statusCode: \(httpResponse.statusCode)")
                    }
                    
                }
            }.resume()
            
        } catch let error as NSError {
            print("Failed to load: \(error.localizedDescription)")
        }
    }
}
