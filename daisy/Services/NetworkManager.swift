//
//  NetworkManager.swift
//  daisy
//
//  Created by Galina on 16/04/2020.
//  Copyright © 2020 Galina FABIO. All rights reserved.
//

import Foundation
import Combine

class NetworkManager: ObservableObject {
    
    @Published var fetchStatus: FetchStatus = .failure
    
    enum FetchStatus {
        case fetching
        case success
        case failure
    }
    // used to store `AnyCancellable`, without keeping this reference alive, the network publisher will terminate immediately
    private var disposables = Set<AnyCancellable>()
    
    private var apiPublisher: AnyPublisher<[String: Item], Never>?
    private var apiCancellable: AnyCancellable? {
        willSet {
            apiCancellable?.cancel()
        }
    }
   
    //"/lists/01E5Z9PGSW3ZKZ6PHT4FJVYGC3/items"
    //public let publisher = PassthroughSubject<[Item],Never>()
    
    @Published var items: [Item] = []
    //var items = [Item]()
//    {
//        willSet {
//            publisher.send(newValue)
//        }
//    }
    var items2D = [[Item]]()
    @Published var isPostingFinished = false
    
    let apiLink: String = UserDefaults.standard.string(forKey: "apiLink") ?? ""
    let token: String = UserDefaults.standard.string(forKey: "token") ?? ""
    
    func updateItemsFromDB(urlString: String) {
        self.genericFetch(urlString: urlString) { (items: ItemResults) in
            self.items = items.items
            self.items2D = getGridItemData(items: items.items)
        }
    }
    
    func getURL(urlString: String) -> String {
        if apiLink != "" {
            return apiLink + urlString
        }
        
        return urlString
    }
    
    func genericFetch<T: Decodable>(urlString: String, completion: @escaping (T) -> ()) {
             
        if apiLink != "" {
            if let url = URL(string: apiLink + urlString) {
                let session = URLSession(configuration: .default)
                
                var request = URLRequest(url: url)
                request.setValue("Bearer " + token, forHTTPHeaderField: "Authorization")
                let task = session.dataTask(with: request) { (data, response, error) in
                    guard let httpResponse = response as? HTTPURLResponse,
                        (200...299).contains(httpResponse.statusCode) else {
                            // self.handleServerError(response)
                         //   print(response)
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
        }
    }
    
    func addItemN(listID: String, body: [String: Any]) -> AnyPublisher<Item?, APIError> {
        return DaisyService.postData(endpoint: .items(id: listID), body: body)
    }
    
    func addItem09(listID: String, title: String, image: String, url: String, price: String, description: String) {
         let body: [String: Any] = [
            "title": title,
            "image": image,
            "url": url,
            "price": Double(price) ?? 0,
            "description": description,
            "status": 1]
        
        let it = DaisyService.postRequestItem(endpoint: .items(id: listID), body: body)
        it
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { print($0) },
                  receiveValue: { print("Received value \($0)")})
            .store(in: &disposables)
    }
    
    
    func addItem(listID: String, body: [String: Any], completion: @escaping (Item) -> ()) {
        
        guard let apiURL = URL(string: apiLink + "lists/\(listID)/items") else { return }
            
        do {
            // make sure this JSON is in the format we expect
            let finalBody = try JSONSerialization.data(withJSONObject: body)
            
            var request = URLRequest(url: apiURL)
            request.httpMethod = "POST"
            request.httpBody = finalBody
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.setValue("Bearer " + token, forHTTPHeaderField: "Authorization")
            
            URLSession.shared.dataTask(with: request) { (data, response, error) in
                guard let _ = data else { return }
                if let httpResponse = response as? HTTPURLResponse {
                    if httpResponse.statusCode == 201 {
                        self.updateItemsFromDB(urlString: "lists/\(listID)/items")

                        if let safeData = data {
                            do {
                                let dec = JSONDecoder()
                               // dec.keyDecodingStrategy = .convertFromSnakeCase
                                let newItem = try dec.decode(Item.self, from: safeData)
                                completion(newItem)
                            } catch let jsonErr {
                                print("Failed to decode, \(jsonErr)")
                            }
                        }

                    } else {
                        print("statusCode: \(httpResponse.statusCode)")
                    }

                }
            }
            .resume()
            
        } catch let error as NSError {
            print("Failed to load: \(error.localizedDescription)")
        }
    }
}
