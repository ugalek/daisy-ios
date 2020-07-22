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
    @Published var authenticated = false
    @Published var errorMessage = ""
    @Published var showAlert = false
    
    func login(email: String, password: String) {
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
            
            URLSession.shared.dataTask(with: request) { (data, response, error) in
                if let error = error {
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
                                UserDefaults.standard.set(finalData.token, forKey: "token")
                                print(finalData.token)
                            }
                        } catch {
                            DispatchQueue.main.async {
                                self.errorMessage = "Cannot decode server message"
                            }
                        }
                    } else {
                        DispatchQueue.main.async {
                            self.errorMessage = "Unauthorized. StatusCode: \(httpResponse.statusCode)"
                        }
                    }
                    
                }
            }.resume()
            
        } catch let error as NSError {
            print("Failed to load: \(error.localizedDescription)")
        }
    }
}
