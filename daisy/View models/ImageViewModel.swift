//
//  ImageViewModel.swift
//  daisy
//
//  Created by Galina on 13/07/2020.
//  Copyright © 2020 Galina FABIO. All rights reserved.
//

import UIKit
import Combine

class ImageViewModel: ObservableObject {
    @Published var images: [ImageResponse] = []
    
    public let userID: String
    
    // used to store `AnyCancellable`, without keeping this reference alive, the network publisher will terminate immediately
    private var disposables = Set<AnyCancellable>()
    
    public init(userID: String) {
        self.userID = userID
        
        if images.isEmpty {
            fetchData()
        }
    }
    
    private func fetchData() {
        DaisyService.getRequest(endpoint: .images(userID: userID))
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { _ in },
                  receiveValue: { response in
                    self.images.append(contentsOf: response)
            })
            .store(in: &disposables)
    }
    
    func uploadImage(image: UIImage?, completionHandler: @escaping (_ imageUploaded: Bool) -> Void) {
        if let image = image {
            DaisyService.uploadImageRequest(endpoint: .image, image: image)
                .receive(on: DispatchQueue.main)
                .sink(receiveCompletion: { (completion) in
                    switch completion {
                    case .finished:
                        completionHandler(true)
                    case .failure(_):
                        completionHandler(false)
                    }
                },
                receiveValue: {
                    self.images.append($0)
                })
                .store(in: &disposables)
        }
    }
}
