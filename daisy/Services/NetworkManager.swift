//
//  NetworkManager.swift
//  daisy
//
//  Created by Galina on 16/04/2020.
//  Copyright © 2020 Galina FABIO. All rights reserved.
//

import Foundation

class NetworkManager: ObservableObject {
    //"/lists/01E5Z9PGSW3ZKZ6PHT4FJVYGC3/items"
  
    func genericFetch<T: Decodable>(urlString: String, completion: @escaping (T) -> ()) {
        let apiLink: String = UserDefaults.standard.string(forKey: "apiLink") ?? ""
        let token: String = UserDefaults.standard.string(forKey: "token") ?? ""
        
        if apiLink != "" {
            if let url = URL(string: apiLink + urlString) {
                let session = URLSession(configuration: .default)
                
                var request = URLRequest(url: url)
                request.setValue("Bearer " + token, forHTTPHeaderField: "Authorization")
                print(token)
                let task = session.dataTask(with: request) { (data, response, error) in
                    guard let httpResponse = response as? HTTPURLResponse,
                        (200...299).contains(httpResponse.statusCode) else {
                            // self.handleServerError(response)
                          //  print(response)
                            return
                    }
                    
                    guard let mime = response?.mimeType, mime == "application/json" else {
                        print("Wrong MIME type!")
                        return
                    }
                    
                    if error == nil {
                        if let safeData = data {
                            do {
                                let model = try JSONDecoder().decode(T.self, from: safeData)
                                completion(model)
                            } catch let jsonErr {
                                print("Failed to decode, \(jsonErr)")
                            }
                        }
                    }
                }
                task.resume()
            }
        }
    }
}
