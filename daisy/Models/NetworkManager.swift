//
//  NetworkManager.swift
//  daisy
//
//  Created by Galina on 16/04/2020.
//  Copyright © 2020 Galina FABIO. All rights reserved.
//

import Foundation

class NetworkManager: ObservableObject {
    
    @Published var items = [Item]()
    
    func fetchData() {
        if let url = URL(string: "http://localhost:3000/api/v1/lists/01E5Z9PGSW3ZKZ6PHT4FJVYGC3/items") {
            let session = URLSession(configuration: .default)
            let task = session.dataTask(with: url) { (data, response, error) in
                if error == nil {
                    let decoder = JSONDecoder()
                    if let safeData = data {
                        do {
                            let results = try decoder.decode(Results.self, from: safeData)
                            DispatchQueue.main.async {
                                self.items = results.items
                            }
                        } catch {
                            print(error)
                        }
                    }
                }
            }
            task.resume()
        }
    }
}
